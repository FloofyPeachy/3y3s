//
// Created by peachy on 7/4/26.
//

#include "FrameProcessor.hpp"

#include "GameStatus.hpp"
#include "Vision.hpp"
void FrameProcessor::init(filter_state *in_state)
{
	this->state = in_state;
}
void FrameProcessor::add_frame(cv::Mat frame)
{
	if (frame.empty()) return;

	{
		std::lock_guard<std::mutex> lock(queue_mutex);
		if (this->frame_queue.size() < 2) {
			frame_queue.push(std::move(frame));
			queue_rdy.notify_one();
		}
	}
}
void FrameProcessor::process_loop(std::optional<Preset>* preset, Cabinet* cabinet)
{

	while (this->running) {
		{
			std::unique_lock<std::mutex> lock(this->queue_mutex);
			this->queue_rdy.wait(lock, [this]() { return !this->frame_queue.empty() || !this->running; });

			if (!preset->has_value()) continue;
			if (!this->running && this->frame_queue.empty()) {
				break;
			}

			const cv::Mat frame = std::move(this->frame_queue.front());
			this->frame_queue.pop();
			cabinet->score = Vision::usePreset(frame, preset->value());


		}
	}
}