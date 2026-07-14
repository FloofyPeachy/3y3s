//
// Created by peachy on 7/3/26.
//

#ifndef INC_3Y3S_TST_DEFINITION_HPP
#define INC_3Y3S_TST_DEFINITION_HPP
#include "template.hpp"

#include <map>
#include <string>
#include <opencv2/imgproc.hpp>

class Template;
struct Region {
    Region() : x_ratio(0), y_ratio(0), w_ratio(1), h_ratio(1) {}
    Region(float x_ratio, float y_ratio, float w_ratio, float h_ratio)
        : x_ratio(x_ratio),
          y_ratio(y_ratio),
          w_ratio(w_ratio),
          h_ratio(h_ratio)
    {
    }

    float x_ratio;
    float y_ratio;
    float w_ratio;
    float h_ratio;

    static cv::Rect getRect(const Region& r, int frameWidth, int frameHeight) {
        return cv::Rect(
            r.x_ratio * frameWidth,
            r.y_ratio * frameHeight,
            r.w_ratio * frameWidth,
            r.h_ratio * frameHeight
        );
    }
};

struct SearchArea
{
	cv::Point start;
	cv::Point charSize;
	int characterCount;
	std::map<int, Template> templates;
};

struct Optimizations {
	double scaleFactor;
};
class Preset
{
    public:
    std::string name;
    std::string description;
    std::string game;
	std::vector<SearchArea> searchAreas;
	Optimizations optimizations;

};

struct Cabinet {
	std::array<int, 8> score;
};

#endif //INC_3Y3S_TST_DEFINITION_HPP
