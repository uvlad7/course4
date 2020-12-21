#include <iostream>
#include <vector>

using namespace std;

int main() {
    int32_t cacheSize, n, hit = 0, oldestValue;
    int16_t associativity, lineSize, bankNumber, oldestPos;
    cin >> cacheSize >> associativity >> lineSize >> n;
    int32_t address, lineNumber, tag, linePos, bankSize = cacheSize / (lineSize * associativity);
    vector<pair</*time*/int32_t, /*tag*/int32_t>> cache(/*lines count*/ cacheSize / lineSize,
                                                                        make_pair(-1, -1));
    for (int32_t time = 0; time < n; ++time) {
        cin >> address;
        tag = address / lineSize;
        lineNumber = tag % bankSize;
        tag /= bankSize;
        oldestValue = n;
        for (bankNumber = 0; bankNumber < associativity; ++bankNumber) {
            linePos = bankNumber * bankSize + lineNumber;
            if (cache[linePos].second == tag) {
                hit++;
                cache[linePos].first = time;
                break;
            }
            if (oldestValue > cache[linePos].first) {
                oldestValue = cache[linePos].first;
                oldestPos = bankNumber;
            }
        }
        if (bankNumber == associativity) {
            linePos = oldestPos * bankSize + lineNumber;
            cache[linePos].first = time;
            cache[linePos].second = tag;
        }
    }
    cout << hit << " " << n - hit << "\n";
    return 0;
}
