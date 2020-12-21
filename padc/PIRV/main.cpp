#include "utils.h"
#include "matrix_multiply.h"

using namespace std;

const string USAGE = "./multiply -n <rows> -m <cols> -r <block_size> [-o <out_file>='output.txt']";

int main(int argc, char *argv[])
{
  if (argc < 7)
  {
    cerr << "Error. Usage is:" << endl;
    cerr << USAGE << endl;
    return 1;
  }

  int n, m, block_size;
  string filename = "output.txt";

  for (int i = 1; i < argc; i += 2)
  {
    if (string(argv[i]) == "-n")
    {
      n = atoi(argv[i + 1]);
    }
    else if (string(argv[i]) == "-m")
    {
      m = atoi(argv[i + 1]);
    }
    else if (string(argv[i]) == "-r")
    {
      block_size = atoi(argv[i + 1]);
    }
    else if (string(argv[i]) == "-o")
    {
      filename = argv[i + 1];
    }
    else
    {
      cerr << USAGE << endl;
      return 1;
    }
  }
  fstream fout;
  fout.open(filename, fstream::out | fstream::app);
  omp_set_dynamic(0);
  omp_set_num_threads(4);

  arr_1d a = generate_random_matrix(n, m);
  arr_1d b = generate_random_matrix(m, n);
  arr_2d c(n, vector<int>(n, 0));

  fout << block_size << " ";

  for (int par_loop_num = 0; par_loop_num <= 2; par_loop_num++)
  {
    auto start = high_resolution_clock::now();
    if (block_size == 1)
    {
      point_multiply(a, b, c, par_loop_num, n, m, n);
    }
    else
    {
      block_multiply(a, b, c, block_size, par_loop_num, n, m, n);
    }
    fout << time_diff(start, high_resolution_clock::now()) << " ";
  }
  fout << endl;
  return 0;
}
