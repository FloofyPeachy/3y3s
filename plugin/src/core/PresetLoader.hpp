//
// Created by peachy on 7/4/26.
//

#ifndef THREEY3S_PRESETLOADER_HPP
#define THREEY3S_PRESETLOADER_HPP
#include "definition.hpp"

class PresetLoader {
public:
	static Preset load(std::string path_to_dir);
};

#endif //THREEY3S_PRESETLOADER_HPP
