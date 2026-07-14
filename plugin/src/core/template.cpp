//
// Created by peachy on 7/3/26.
//

#include "template.hpp"
#include <opencv4/opencv2/opencv.hpp>
#include <spdlog/spdlog.h>
#include <ranges>
void Template::load(const std::string& path)
{
    cv::Mat templ = cv::imread(
        path,
        cv::IMREAD_UNCHANGED);
    if (templ.empty())
    {
        spdlog::error("Couldn't load template: {}", path);
        return;
    }

    if (templ.channels() == 3) {
        cv::cvtColor(templ, templ, cv::COLOR_BGR2GRAY);
    } else if (templ.channels() == 4) {
        cv::cvtColor(templ, templ, cv::COLOR_BGRA2GRAY);
    }

    /*auto roi = Region::getRect(imageRoi, templ.cols, templ.rows);
    templ = templ(roi);*/

    spdlog::info("Loaded template successfully!!");

    if (!use_contours) return;

    //binarize it!
    //cv::threshold(templ, templ, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);

    //find the contours..
    std::vector<std::vector<cv::Point>> temp_contours;
    cv::findContours(templ, temp_contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

    if (!temp_contours.empty()) {
    	const auto max_c = *std::max_element(temp_contours.begin(), temp_contours.end(),
	   [](const auto& c1, const auto& c2) {
	       return cv::contourArea(c1) < cv::contourArea(c2);
	   });
        contours = max_c;
    }

    spdlog::info("Found contours successfully!!");
    
}
