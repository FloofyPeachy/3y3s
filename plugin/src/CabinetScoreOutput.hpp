// Inside CabinetScoreOutput.hpp
#include <App.h>

struct Cabinet;
class CabinetScoreOutput {
public:
	static std::vector<Cabinet*> cabinetStore2;
	static long long lastValidScore1;
	static long long lastValidScore2;

	static uWS::Loop* networkLoop;
	static void broadcast_payload(std::string_view payload);
	static std::thread networkWorker;
	static long long delta1;
	static long long delta2;
	static int p1Strikes;
	static int p2Strikes;
	static long long combine_digits_strict(const std::array<int, 8> &digits, const int length,
						       const bool fill_empty_with_zero);
	static void run_network_thread();
	static void loop(std::vector<Cabinet *> store);
};