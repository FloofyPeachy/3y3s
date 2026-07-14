#include "CabinetScoreOutput.hpp"

#include "core/definition.hpp"

#include <vector>
#include <algorithm>
#include <spdlog/spdlog.h>


using MySocket = uWS::WebSocket<false, true, int>;


static std::vector<MySocket*> connected_clients;

std::vector<Cabinet*> CabinetScoreOutput::cabinetStore2;


long long CabinetScoreOutput::lastValidScore1 = 0;
long long CabinetScoreOutput::delta1 = 0;
int CabinetScoreOutput::p1Strikes = 0;
long long CabinetScoreOutput::lastValidScore2 = 0;
long long CabinetScoreOutput::delta2 = 0;
int CabinetScoreOutput::p2Strikes = 0;

std::thread CabinetScoreOutput::networkWorker;


long long CabinetScoreOutput::combine_digits_strict(const std::array<int, 8> &digits, const int length,
					       const bool fill_empty_with_zero) {
	long long total = 0;
	for (int i = 0; i < length; ++i) {
		if (digits.at(i) == -1) {
			if (fill_empty_with_zero) {
				total = (total * 10) + 0;
			} else {
				return -1;
			}
		} else {
			total = (total * 10) + digits.at(i);
		}
	}
	return total;
}

uWS::Loop* CabinetScoreOutput::networkLoop = nullptr;
void CabinetScoreOutput::run_network_thread()
{
	CabinetScoreOutput::networkLoop = uWS::Loop::get();

	uWS::App()
	.ws<int>("/*", {
	    .open = [](auto *ws) {

		connected_clients.push_back(ws);
		spdlog::info("Client connected. Total clients: {}", connected_clients.size());
	    },
	    .message = []([[maybe_unused]] auto *ws, [[maybe_unused]] std::string_view message, [[maybe_unused]] uWS::OpCode opCode) {

	    },
	    .close = []([[maybe_unused]] auto *ws, [[maybe_unused]] int code, [[maybe_unused]] std::string_view message) {

		connected_clients.erase(
		    std::remove(connected_clients.begin(), connected_clients.end(), ws),
		    connected_clients.end()
		);
		spdlog::info("Client disconnected. Total clients: {}", connected_clients.size());
	    }
	})
	.listen(9001, [](auto *token) {
	    if (token) spdlog::info("Server listening on port 9001");
	    else spdlog::error("Failed to listen on port 9001");
	})
	.run();
}

void CabinetScoreOutput::loop(std::vector<Cabinet*> store)
{
	cabinetStore2 = std::move(store);
	if (cabinetStore2.size() != 2) return;
	long long rawScore1 = combine_digits_strict(cabinetStore2[0]->score, 8, false);
	long long rawScore2 = combine_digits_strict(cabinetStore2[1]->score, 8, false);

	delta1 = rawScore1 - lastValidScore1;
	delta2 = rawScore2 - lastValidScore2;
	// track Player 1, weird edge case handling
	if (rawScore1 <= 10000000) {

		if (delta1 >= 0 && delta1 < 35000 && rawScore1 >= lastValidScore1) {
			lastValidScore1 = rawScore1;
			p1Strikes = 0; // Reset strikes on a clean read
		} else {
			p1Strikes++;

			if (p1Strikes >= 5) {
				lastValidScore1 = rawScore1;
				p1Strikes = 0;
			}
		}
	}

	// track Player 2, weird edge case handling
	if (rawScore2 <= 10000000) {
		if (delta2 >= 0 && delta2 < 35000 && rawScore2 >= lastValidScore2) {
			lastValidScore2 = rawScore2;
			p2Strikes = 0;
		} else {
			p2Strikes++;
			if (p2Strikes >= 5) {
				lastValidScore2 = rawScore2;
				p2Strikes = 0;
			}
		}
	}

	//if (rawScore1 <= 10000000 /*&& rawScore1 >= lastValidScore1*/) lastValidScore1 = rawScore1;
	//if (rawScore2 <= 10000000/* && rawScore2 >= lastValidScore1*/) lastValidScore2 = rawScore2;




	int diff = static_cast<int>(lastValidScore1 - lastValidScore2);


	constexpr size_t total_size = sizeof(lastValidScore1) + sizeof(lastValidScore2) + sizeof(diff);
	std::array<std::uint8_t, total_size> byte_array;

	size_t offset = 0;
	std::memcpy(byte_array.data() + offset, &lastValidScore1, sizeof(lastValidScore1));
	offset += sizeof(lastValidScore1);

	std::memcpy(byte_array.data() + offset, &lastValidScore2, sizeof(lastValidScore2));
	offset += sizeof(lastValidScore2);

	std::memcpy(byte_array.data() + offset, &diff, sizeof(diff));

	std::string payload(reinterpret_cast<char*>(byte_array.data()), byte_array.size());
	if (CabinetScoreOutput::networkLoop) {
		CabinetScoreOutput::networkLoop->defer([payload = std::move(payload)]() {

		    std::string_view payload_view(payload.data(), payload.size());

		    for (auto* client : connected_clients) {
			client->send(payload_view, uWS::OpCode::BINARY);
		    }
		});
	}
}