#include <iostream>
#include "matrix_multiply.h"

void assert(bool exp, const string &msg)
{
  if (!exp)
  {
    cout << msg;
    exit(EXIT_FAILURE);
  }
}

arr_2d &reset_vec(arr_2d &old_vec)
{
  for (auto &i : old_vec)
    fill(i.begin(), i.end(), 0);
  return old_vec;
}

int main()
{
  std::cout << "Test";
  arr_1d a = flatten(arr_2d{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}});

  arr_1d b = flatten(arr_2d{{1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}});
  arr_2d res = arr_2d(4, vector<int>(4));
  arr_2d exp_res = {{90, 100, 110, 120},
                    {202, 228, 254, 280},
                    {314, 356, 398, 440},
                    {426, 484, 542, 600}};
  assert(a == b, "Vector compare doesn\'t work");
  point_multiply(a, b, res, 0, 4, 4, 4);

  assert(res == exp_res, "4x4 point multiplication failed");

  res = reset_vec(res);
  point_multiply(a, b, res, 1, 4, 4, 4);
  assert(res == exp_res, "4x4 point parallel(first loop) multiplication failed");

  res = reset_vec(res);
  point_multiply(a, b, res, 2, 4, 4, 4);
  assert(res == exp_res, "4x4 point parallel(second loop) multiplication failed");

  res = reset_vec(res);
  block_multiply(a, b, res, 2, 0, 4, 4, 4);
  print_matrix(res);
  print_matrix(exp_res);
  assert(res == exp_res, "4x4 point block multiplication failed");

  res = reset_vec(res);
  block_multiply(a, b, res, 2, 1, 4, 4, 4);
  assert(res == exp_res, "4x4 point parallel block(first loop) multiplication failed");

  res = reset_vec(res);
  block_multiply(a, b, res, 2, 2, 4, 4, 4);
  assert(res == exp_res, "4x4 point parallel block(second loop) multiplication failed");

  res = reset_vec(res);
  block_multiply(a, b, res, 2, 3, 4, 4, 4);
  assert(res == exp_res, "4x4 point parallel block with inappropriate block multiplication failed");

  arr_1d a_rect = flatten(arr_2d{{1, 2, 3, 4}, {5, 6, 7, 8}});

  arr_1d b_rect = flatten(arr_2d{{1, 2}, {3, 4}, {5, 6}, {7, 8}});
  arr_2d res_rect = arr_2d(2, vector<int>(2));
  arr_2d exp_res_rect = arr_2d{{50, 60}, {114, 140}};
  block_multiply(a_rect, b_rect, res_rect, 2, 3, 2, 4, 2);
  assert(res_rect == exp_res_rect, "Rectangle block multiplication failed");
}
