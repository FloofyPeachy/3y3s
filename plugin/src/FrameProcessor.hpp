//
// Created by peachy on 7/4/26.
//

#ifndef THREEY3S_FRAMEQUEUE_HPP
#define THREEY3S_FRAMEQUEUE_HPP
#include "GameStatus.hpp"
#include "core/definition.hpp"

#include <opencv2/opencv.hpp>
#include <condition_variable>
#include <thread>

struct filter_state;
class FrameProcessor {
public:
	void init(filter_state* in_state);
	std::mutex queue_mutex;
	std::condition_variable queue_rdy;
	std::queue<cv::Mat> frame_queue;
	//std::atomic<bool> is_running;
	filter_state* state;
	bool running;

	void add_frame(cv::Mat frame);
	void process_loop(std::optional<Preset> *preset, Cabinet *cabinet);

};

#endif //THREEY3S_FRAMEQUEUE_HPP
