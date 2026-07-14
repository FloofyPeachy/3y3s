/*
Threey3s
Copyright (C) 2026 FloofyPeachy peachy@peachmaster.dev

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program. If not, see <https://www.gnu.org/licenses/>
*/

#include "CabinetScoreOutput.hpp"
#include "FrameProcessor.hpp"
#include "GameStatus.hpp"
#include "Vision.hpp"
#include "core/PresetLoader.hpp"
#include "core/definition.hpp"

#include <obs-module.h>
#include <plugin-support.h>
#include <spdlog/spdlog.h>

OBS_DECLARE_MODULE()
OBS_MODULE_USE_DEFAULT_LOCALE(PLUGIN_NAME, "en-US")

struct filter_state {
	obs_source_t *context;
	FrameProcessor processor;
	std::optional<Preset> preset;
	std::thread thread;
	Cabinet cabinet;
	int speed;
	int frameCount;
};

std::vector<Cabinet *> cabinetStore;
std::mutex storeMutex;

CabinetScoreOutput output;
std::thread outputThread;

void fp_worker(filter_state *state)
{
	state->processor.process_loop(&state->preset, &state->cabinet);
}

void process_loop2()
{
	CabinetScoreOutput::networkWorker = std::thread([]() { CabinetScoreOutput::run_network_thread(); });

	CabinetScoreOutput::networkWorker.detach();
	while (true) {
		{
			std::lock_guard lock(storeMutex);
			output.loop(cabinetStore);
			/*for (Cabinet* cab : cabinetStore) {
				if (!cab) continue;

				// Access score via pointer arrow ->
				auto& score = cab->score;

				spdlog::info("cab {} :{} {} {} {} {} {} {} {}", cabIdx,
					     score[0], score[1], score[2], score[3],
					     score[4], score[5], score[6], score[7]);
				cabIdx++;
			}*/
		}

		std::this_thread::sleep_for(std::chrono::milliseconds(16));
	}
}
static void try_load_preset(filter_state* state, obs_data_t *settings)
{
	const std::string path = obs_data_get_string(settings, "preset_path");

	if (path.empty()) {
		obs_data_set_string(settings, "preset_desc", "No preset loaded. Try loading one.");
		return;
	}

	try {
		state->preset = PresetLoader::load(path);
		obs_data_set_string(settings, "preset_desc", (std::string(
				"Name: ") + state->preset.value().name + "\n"
				"Description: " + state->preset.value().description + "\n"
				"Game: " + state->preset.value().game
				).c_str());
	} catch (const std::invalid_argument& e) {
		obs_data_set_string(settings, "preset_desc", (std::string("Couldn't load preset: ") + e.what()).c_str());
		state->preset.reset();
	}



}

void *filter_create([[maybe_unused]] obs_data_t *settings, [[maybe_unused]] obs_source_t *source)
{
	auto *state = new filter_state();
	state->context = source;
	state->processor.running = true;
	state->thread = std::thread(fp_worker, state);

	try_load_preset(state, settings);


	{
		std::lock_guard<std::mutex> lock(storeMutex);
		cabinetStore.push_back(&state->cabinet);
	}

	obs_log(LOG_INFO, "frame processor created!");
	const int leSpeed = static_cast<int>(obs_data_get_int(settings, "processing_speed"));
	state->speed = leSpeed;

	return state;
}



static void filter_destroy([[maybe_unused]] void *data) {}

const char *filter_get_name([[maybe_unused]] void *type_data)
{
	return "threey3s Frame Processor";
}

static struct obs_source_frame *filter_video(void *data, struct obs_source_frame *frame)
{
	auto *le_state = static_cast<filter_state *>(data);

	if (le_state->frameCount % le_state->speed != 0) {
		le_state->frameCount++;
		return frame;
	}

	cv::Mat gray_allocated;

	if (frame->format == VIDEO_FORMAT_I420 || frame->format == VIDEO_FORMAT_NV12) {
		cv::Mat native_wrapped =
			cv::Mat(frame->height, frame->width, CV_8UC1, frame->data[0], frame->linesize[0]);
		gray_allocated = native_wrapped.clone();
	} else if (frame->format == VIDEO_FORMAT_BGRA || frame->format == VIDEO_FORMAT_RGBA) {
		const auto color = cv::Mat(frame->height, frame->width, CV_8UC4, frame->data[0], frame->linesize[0]);
		cv::cvtColor(color, gray_allocated, cv::COLOR_BGRA2GRAY);
	} else {
		return frame;
	}
	cv::resize(gray_allocated, gray_allocated, cv::Size{1280, 720}, 0, 0, cv::INTER_AREA);
	cv::resize(gray_allocated, gray_allocated, cv::Size{0, 0}, 1,
		   1, cv::INTER_AREA);
	le_state->processor.add_frame(Vision::preprocess(gray_allocated));
	le_state->frameCount++;
	return frame;
}
bool path_updated(void *priv, [[maybe_unused]]  obs_properties_t *props, obs_property_t *property, obs_data_t *settings) {

	if (const char *property_name = obs_property_name(property); strcmp(property_name, "preset_path") == 0) {
		try_load_preset(static_cast<filter_state *>(priv), settings);
	}

	return true; // Return true to trigger UI refresh
}


static obs_properties_t *filter_get_properties([[maybe_unused]] void *data)
{
	auto *filData = static_cast<filter_state *>(data);
	obs_properties_t *props = obs_properties_create();

	obs_property_t *p = obs_properties_add_path(props,
				"preset_path",     // The internal name for the setting
				obs_module_text("Preset"), // Display name (localized)
				OBS_PATH_DIRECTORY,             // Tells OBS it's a directory picker
				nullptr,                        // Filter (unused for directory)
				nullptr                         // Default path
	);
	obs_property_set_modified_callback2(p, path_updated, filData);

	obs_properties_add_text(props, "preset_desc", "", OBS_TEXT_INFO);

	obs_properties_add_int_slider(props, "processing_speed", "Speed", 1, 5, 1);
	obs_properties_add_text(
			props, "speed_desc",
			"How often to process frames (source_fps / speed). Lower values get better performance, but uses more processing power.",
			OBS_TEXT_INFO);
	return props;
}
static void filter_get_defaults(obs_data_t *settings)
{
	obs_data_set_default_int(settings, "processing_speed", 3);
}

static void filter_update(void *data, obs_data_t *settings)
{
	auto *filData = static_cast<filter_state *>(data);
	const int leSpeed = static_cast<int>(obs_data_get_int(settings, "processing_speed"));

	filData->speed = leSpeed;
}

struct obs_source_info frame_filter{
	.id = "threey3s-processor",
	.type = OBS_SOURCE_TYPE_FILTER,
	.output_flags = OBS_SOURCE_VIDEO,
	.get_name = filter_get_name,
	.create = filter_create,
	.destroy = filter_destroy,
	.get_defaults = filter_get_defaults,
	.get_properties = filter_get_properties,
	.update = filter_update,
	.filter_video = filter_video,
};

bool obs_module_load(void)
{
	obs_register_source(&frame_filter);
	obs_log(LOG_INFO, "threey3s loaded successfully (version %s)", PLUGIN_VERSION);
	outputThread = std::thread(process_loop2);
	return true;
}

void obs_module_unload(void)
{
	obs_log(LOG_INFO, "plugin unloaded");
}
