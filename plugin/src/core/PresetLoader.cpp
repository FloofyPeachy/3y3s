//
// Created by peachy on 7/4/26.
//

#include "PresetLoader.hpp"
#include <filesystem>
#include <map>
#include <nlohmann/json.hpp>
#include <iostream>
#include <fstream>
std::vector<std::filesystem::__cxx11::directory_entry> get_files_sorted(const std::string& path_to_dir)
{
	std::vector<std::filesystem::__cxx11::directory_entry> files;

	if (std::filesystem::exists(path_to_dir) && std::filesystem::is_directory(path_to_dir))
	{
		for (const auto& entry : std::filesystem::directory_iterator(path_to_dir))
		{
			if (entry.is_regular_file()) files.push_back(entry);
		}
	}

	std::sort(files.begin(), files.end(), [](const auto& a, const auto& b)
	{
	    return a.path() < b.path();
	});
	return files;
}

Preset PresetLoader::load(std::string path_to_dir)
{
	//validate the files.
	if (!std::filesystem::is_directory(path_to_dir)) throw std::invalid_argument("Path is not a directory or doesn't exist.");
	if (!std::filesystem::is_directory(path_to_dir + "/templates")) throw std::invalid_argument("Templates directory doesn't exist.");
	if (!std::filesystem::is_directory(path_to_dir + "/templates/state")) throw std::invalid_argument("State template directory doesn't exist.");
	if (!std::filesystem::exists(path_to_dir + "/preset.json")) throw std::invalid_argument("Preset file doesn't exist.");\

	//validate the json.
	std::string name;
	std::string description;
	std::string game;
	std::vector<SearchArea> searchAreas;

	std::ifstream file(path_to_dir + "/preset.json");
	if (!file.is_open()) {
		throw std::invalid_argument("Couldn't open preset file.");
	}
	std::map<int, Template> templates = {};

	for (size_t id = 0; const auto& entry : get_files_sorted(path_to_dir  + "/templates"))
	{
		auto t = Template{true};
		t.load(entry.path());
		templates.insert({id, t});
		id++;
	}
	auto presence = Template{true};
	presence.load(path_to_dir  + "/templates/state/presence.png");
	std::map<int, Template> presenceList = {};

	presenceList.insert({0, presence});

	try {
		nlohmann::json data = nlohmann::json::parse(file);
		name = data.at("name");
		description = data.at("description");
		game = data.at("game");
		if (data.contains("searchAreas") && data["searchAreas"].is_array()) {
			for (auto& el : data["searchAreas"].items())
			{
				searchAreas.push_back({{el.value().at("x").get<int>(), el.value().at("y").get<int>()}, {el.value().at("charX").get<int>(), el.value().at("charY").get<int>()}, el.value().at("charCount").get<int>(), el.value().at("charCount").get<int>() == 0 ? presenceList : templates});
			}

		}
	} catch (const nlohmann::json::parse_error& e) {
		throw std::invalid_argument("Invalid preset.json file.");
	} catch (const nlohmann::detail::out_of_range) {
		throw std::invalid_argument("Invalid preset.json file.");
	}


	return Preset{.name = name,
			       .description = description,
			       .game = game,
			       .searchAreas = searchAreas,
			       .optimizations = {1}};
}