#include <chrono>

using namespace std;

typedef chrono::high_resolution_clock high_resolution_clock;
typedef chrono::milliseconds ms;

double time_diff(chrono::time_point<high_resolution_clock> time_start, chrono::time_point<high_resolution_clock> time_end);
