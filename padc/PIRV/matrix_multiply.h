#include <iostream>
#include <vector>
#include <fstream>
#include <random>
#include "omp.h"

using namespace std;

typedef vector<int> arr_1d;
typedef vector<vector<int>> arr_2d;
typedef unsigned long ulong;

int random_number();

arr_1d flatten(const arr_2d &orig);
arr_1d generate_random_matrix(ulong rows, ulong cols);

ostream &print_matrix(arr_2d &v);

void point_multiply(arr_1d &a, arr_1d &b, arr_2d &res, int par_loop_num, ulong n1, ulong n2, ulong n3);
void block_multiply(arr_1d &a, arr_1d &b, arr_2d &res, int block_size, int par_loop_num, ulong n1, ulong n2, ulong n3);
