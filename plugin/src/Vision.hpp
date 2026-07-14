//
// Created by peachy on 7/4/26.
//

#ifndef THREEY3S_VISION_HPP
#define THREEY3S_VISION_HPP
#include "core/definition.hpp"

#include <opencv2/core/mat.hpp>

class Vision {
	public:
	static cv::Mat preprocess(cv::Mat mat);
	static std::array<int, 8> usePreset(cv::Mat input, Preset preset);
};

#endif //THREEY3S_VISION_HPP
