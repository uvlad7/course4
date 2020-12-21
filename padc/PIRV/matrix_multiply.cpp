#include "matrix_multiply.h"

int random_number()
{
  return (rand() % 200) - 100;
}

arr_1d flatten(const arr_2d &orig)
{
  arr_1d ret;
  for (const auto &v : orig)
    ret.insert(ret.end(), v.begin(), v.end());
  return ret;
}

arr_1d generate_random_matrix(ulong rows, ulong cols)
{
  arr_2d v(rows, vector<int>(cols));
  for (int i = 0; i < rows; i++)
  {
    for (int j = 0; j < cols; j++)
    {
      v[i][j] = random_number();
    }
  }
  return flatten(v);
}

ostream &print_matrix(arr_2d &v)
{
  for (int i = 0; i < v.size(); i++)
  {
    for (int j = 0; j < v[i].size(); j++)
    {
      cout << v[i][j] << " ";
    }
    cout << endl;
  }

  return cout;
}

void point_multiply(arr_1d &a, arr_1d &b, arr_2d &res, int par_loop_num, ulong n1, ulong n2, ulong n3)
{
#pragma omp parallel for if (par_loop_num == 1)
  for (int i = 0; i < n1; i++)
  {
#pragma omp parallel for if (par_loop_num == 2)
    for (int j = 0; j < n3; j++)
    {
      for (int k = 0; k < n2; k++)
      {
        res[i][j] += a[i * n2 + k] * b[k * n3 + j];
      }
    }
  }
  return;
}

void block_multiply(arr_1d &a, arr_1d &b, arr_2d &res, int block_size, int par_loop_num, ulong n1, ulong n2, ulong n3)
{
  ulong q1 = n1 / block_size;
  ulong q2 = n3 / block_size;
  ulong q3 = n2 / block_size;

#pragma omp parallel for if (par_loop_num == 1)
  for (int i1 = 0; i1 < q1; i1++)
  {
#pragma omp parallel for if (par_loop_num == 2)
    for (int j1 = 0; j1 < q2; j1++)
    {
      for (int k1 = 0; k1 < q3; k1++)
      {
        for (int i2 = 0; i2 < block_size; i2++)
        {
          int i = i1 * block_size + i2;
          for (int j2 = 0; j2 < block_size; j2++)
          {
            int j = j1 * block_size + j2;
            for (int k2 = 0; k2 < block_size; k2++)
            {
              int k = k1 * block_size + k2;
              res[i][j] += a[i * n2 + k] * b[k * n3 + j];
            }
          }
        }
      }
    }
  }
  return;
}
