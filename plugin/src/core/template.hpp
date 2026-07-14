//
// Created by peachy on 7/3/26.
//

#ifndef INC_3Y3S_TST_TEMPLATE_HPP
#define INC_3Y3S_TST_TEMPLATE_HPP
#include <string>
#include <opencv2/core/mat.hpp>

#include "definition.hpp"

class Template
{
public:
    explicit Template(bool use_contours)
        : use_contours(use_contours)
    {
    }

    cv::Mat data{};
    double tolerance{};
    bool use_contours;
    std::vector<cv::Point> contours;

    void load(const std::string &path);
    void compare();
};


#endif //INC_3Y3S_TST_TEMPLATE_HPP
