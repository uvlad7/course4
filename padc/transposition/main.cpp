#include <iostream>
#include <vector>

#define block_size 32

using namespace std;

vector<int> generate_input(int n, int seed) {
    vector<int> d(n * n);
    for (size_t i = 0; i < d.size(); ++i) {
        d[i] = seed;
        seed = ((long long) seed * 197 + 2017) & 987654;
    }
    return d;
}

long long get_hash(const vector<int>& d) {
    const long long MOD = 987654321054321LL;
    const long long MUL = 179;

    long long result_value = 0;
    for (size_t i = 0; i < d.size(); ++i)
        result_value = (result_value * MUL + d[i]) & MOD;
    return result_value;
}

int main() {
    int n, seed, k, i_min, j_min, side;
    cin >> n >> seed >> k;
    auto matrix = generate_input(n, seed);
    for (int _ = 0; _ < k; ++_) {
        cin >> i_min >> j_min >> side;
        
    }
    cout << get_hash(matrix) << "\n";
    return 0;
}
