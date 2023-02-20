#include <vector>
void merge(int* A, int p, int q, int r) {
    int nl = q - p + 1;
    int nr = r - q;
    std::vector<int> L(nl, 0), R(nr, 0);
    for (int i = 0; i < nl; ++i) {
        L[i] = A[p + i];
    }
    for (int j = 0; j < nr; ++j) {
        R[j] = A[q + j + 1];
    }

    int i = 0, j = 0, k = p;
    while (i < nl && j < nr) {
        if (L[i] <= R[j]) {
            A[k] = L[i];
            i = i + 1;
        } else {
            A[k] = R[j];
            j = j + 1;
        }
        k = k + 1;
    }

    while (i < nl) {
        A[k] = L[i];
        i = i + 1;
        k = k + 1;
    }
    while (j < nr) {
        A[k] = R[j];
        j = j + 1;
        k = k + 1;
    }
}

void merge_sort(int* A, int p, int r) {
    if (p >= r) {
        return;
    }

    int q = (p + r) / 2;
    merge_sort(A, p, q);
    merge_sort(A, q + 1, r);

    merge(A, p, q, r);
}

#include <algorithm>
#include <iostream>
#include <random>
const int NUMS = 10;
int main() {
    /* generate randoms */
    std::random_device seeder;
    const auto seed{seeder.entropy() ? seeder() : time(nullptr)};
    std::mt19937 engine{static_cast<std::mt19937::result_type>(seed)};
    std::uniform_int_distribution<int> distribution{1, 1000000};
    auto generator{std::bind(distribution, engine)};
    std::vector<int> input_ints(NUMS);
    generate(begin(input_ints), end(input_ints), generator);

    // inputs
    std::cout << "before merge_sort:" << std::endl;
    for (int i = 0; i < NUMS; ++i) {
        std::cout << input_ints[i] << " " << std::endl;
    }

    merge_sort(input_ints.data(), 0, NUMS - 1);
    std::cout << "after  merge_sort:" << std::endl;
    for (int i = 0; i < NUMS; ++i) {
        std::cout << input_ints[i] << " " << std::endl;
    }
    return 0;
}