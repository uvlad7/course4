#include "utils.h"
double time_diff(chrono::time_point<high_resolution_clock> time_start, chrono::time_point<high_resolution_clock> time_end)
{
  return chrono::duration<double, milli>(time_end - time_start).count();
}
