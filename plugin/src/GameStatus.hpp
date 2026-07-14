//
// Created by peachy on 7/4/26.
//

#ifndef THREEY3S_GAMESTATUS_HPP
#define THREEY3S_GAMESTATUS_HPP
#include <array>

class GameStatus {
public:
	std::array<int, 8> cabOneScore = {-1, -1, -1, -1, -1, -1, -1, -1};
	std::array<int, 8> cabTwoScore = {-1, -1, -1, -1, -1, -1, -1, -1};
};

#endif //THREEY3S_GAMESTATUS_HPP
