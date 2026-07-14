//
// Created by peachy on 7/4/26.
//

#include "Vision.hpp"

#include <opencv2/imgproc.hpp>
#include <spdlog/spdlog.h>
cv::Mat Vision::preprocess(cv::Mat mat)
{
	cv::GaussianBlur(mat, mat, cv::Size(3, 3), 0);
	return mat;
}
std::array<int, 8> Vision::usePreset([[maybe_unused]] cv::Mat input, [[maybe_unused]] Preset preset)
{
	cv::rotate(input, input, cv::ROTATE_90_CLOCKWISE);

	 std::array presetMatch = {-1, -1, -1, -1, -1, -1, -1, -1};
	int areaIdx = 0;
	for (const auto &[start, charSize, characterCount, templates] : preset.searchAreas) {
		if (characterCount == 0) {
			//gotta be for presence.
			cv::Mat area_mat = input(cv::Rect{
				start.x, start.y, charSize.x, charSize.y
			});
			cv::threshold(area_mat, area_mat, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
			cv::resize(area_mat, area_mat, charSize, cv::INTER_LINEAR);

			//get the contours..
			if (area_mat.empty()) break;
			std::vector<std::vector<cv::Point>> contours;
			cv::findContours(area_mat, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

			if (contours.empty()) break;

			auto live_contour = *std::ranges::max_element(contours,
				     [](const auto& c1, const auto& c2) { return cv::contourArea(c1) < cv::contourArea(c2); });
			double score = cv::matchShapes(live_contour, templates.at(0).contours, cv::CONTOURS_MATCH_I1, 0);
			if (score > 1.3) return presetMatch;
			continue;

		}

		for (int i = 0; i < characterCount; ++i) {

			cv::Mat area_mat = input(cv::Rect2d{
				(start.x + (charSize.x * i)) * preset.optimizations.scaleFactor,
					start.y * preset.optimizations.scaleFactor,
				charSize.x * preset.optimizations.scaleFactor,
				charSize.y * preset.optimizations.scaleFactor,
			});
			cv::threshold(area_mat, area_mat, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
			//cv::resize(area_mat, area_mat, charSize, cv::INTER_LINEAR);

			//get the contours..
			if (area_mat.empty()) break;

			std::vector<std::vector<cv::Point>> contours;
			cv::findContours(area_mat, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

			if (contours.empty() || contours.at(0).size() < 5) break; //if theres nothing in it, or theres too little contours, don't use it.

			auto live_contour = *std::ranges::max_element(contours,
				     [](const auto& c1, const auto& c2) { return cv::contourArea(c1) < cv::contourArea(c2); });
			int best_id = -1;
			double best_score = 999.0;
			for (const auto& [id, tmpl] : templates) {
				double score = cv::matchShapes(live_contour, tmpl.contours, cv::CONTOURS_MATCH_I1, 0);
				if (score < best_score) {
					best_score = score;
					best_id = id;
				}
			}
			presetMatch[i + (areaIdx * 4)] = best_id;
		}

		areaIdx++;
	}
	//spdlog::info("{} {} {} {} {} {} {} {}", presetMatch[0], presetMatch[1], presetMatch[2], presetMatch[3],presetMatch[4], presetMatch[5], presetMatch[6], presetMatch[7] );
	return presetMatch;
}

