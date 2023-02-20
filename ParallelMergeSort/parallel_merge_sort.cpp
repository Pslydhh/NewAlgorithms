#include <algorithm>
#include <iostream>
#include <random>
#include <vector>
#include "../threadPool/threadpool.hpp"
const int MAX_THREADS = 100;
const int NUMS = 10;

ThreadPool TP(MAX_THREADS);

struct data_in_p_merge_aux {
    int* A;
    int p1;
    int r1;
    int p2;
    int r2;
    int* B;
    int p3;
};

int find_split_point(int* A, int p, int r, int x) {
    int low = p;
    int high = r + 1;
    while (low < high) {
        int mid = (low + high) / 2;
        if (x <= A[mid]) {
            high = mid;
        } else {
            low = mid + 1;
        }
    }
    return low;
}

void p_merge_aux(int* A, int p1, int r1, int p2, int r2, int* B, int p3) {
    if (p1 > r1 && p2 > r2) {
        return;
    }
    if (r1 - p1 < r2 - p2) {
        std::swap(p1, p2);
        std::swap(r1, r2);
    }
    int q1 = (p1 + r1) / 2;
    int x = A[q1];
    int q2 = find_split_point(A, p2, r2, x);
    int q3 = p3 + (q1 - p1) + (q2 - p2);
    B[q3] = x;

    auto recursive_aux = [&](data_in_p_merge_aux args) {
        return p_merge_aux(args.A, args.p1, args.r1, args.p2, args.r2, args.B, args.p3);
    };

    std::vector<std::future<void>> futures;

    data_in_p_merge_aux left{A, p1, q1 - 1, p2, q2 - 1, B, p3};
    futures.emplace_back(std::move(TP.enqueue(recursive_aux, left)));
    data_in_p_merge_aux right{A, q1 + 1, r1, q2, r2, B, q3 + 1};
    futures.emplace_back(std::move(TP.enqueue(recursive_aux, right)));

    // sync for spawns
    for (auto& future : futures) {
        future.get();
    }
}

void p_merge(int* A, int p, int q, int r) {
    std::vector<int> B(r - p + 1, 0);
    p_merge_aux(A, p, q, q + 1, r, B.data(), 0);
    for (int i = p; i <= r; ++i) {
        A[i] = B[i - p];
    }
}
struct data_in_p_merge_sort {
    int* A;
    int p;
    int r;
};

void p_merge_sort(int* A, int p, int r) {
    if (p >= r) {
        return;
    }

    int q = (p + r) / 2;
    auto recursive_sort = [&](data_in_p_merge_sort args) {
        return p_merge_sort(args.A, args.p, args.r);
    };

    std::vector<std::future<void>> futures;

    data_in_p_merge_sort left{A, p, q};
    // spawn p-merge-sort(A, p, q);
    futures.emplace_back(std::move(TP.enqueue(recursive_sort, left)));
    data_in_p_merge_sort right{A, q + 1, r};
    // spawn p-merge-sort(A, q + 1,r);
    futures.emplace_back(std::move(TP.enqueue(recursive_sort, right)));

    // sync for spawns
    for (auto& future : futures) {
        future.get();
    }

    p_merge(A, p, q, r);
}

int main() {
    /* generate randoms */
    std::random_device seeder;
    const auto seed{seeder.entropy() ? seeder() : time(nullptr)};
    std::mt19937 engine{static_cast<std::mt19937::result_type>(seed)};
    std::uniform_int_distribution distribution{1, 1000000};
    auto generator{std::bind(distribution, engine)};
    std::vector<int> input_ints(NUMS);
    generate(begin(input_ints), end(input_ints), generator);

    // inputs
    std::cout << "before parallel_merge_sort:" << std::endl;
    for (int i = 0; i < NUMS; ++i) {
        std::cout << input_ints[i] << " " << std::endl;
    }

    p_merge_sort(input_ints.data(), 0, NUMS - 1);
    std::cout << "after  parallel_merge_sort:" << std::endl;
    for (int i = 0; i < NUMS; ++i) {
        std::cout << input_ints[i] << " " << std::endl;
    }
    return 0;
}