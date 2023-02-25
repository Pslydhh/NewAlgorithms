#include <algorithm>
#include <iostream>
#include <vector>

struct Rank {
    int left_rank;
    int right_rank;
    int index;
};

class compareLeftAndRightRank {
public:
    bool operator()(const Rank& a, const Rank& b) {
        if (a.left_rank != b.left_rank) {
            return a.left_rank < b.left_rank;
        } else {
            return a.right_rank < b.right_rank;
        }
    }
};

void make_ranks(std::vector<Rank>* substr_rank, std::vector<int>* rank, int n) {
    int r = 1;
    (*rank)[(*substr_rank)[0].index] = r;
    for (int i = 1; i < n; ++i) {
        if ((*substr_rank)[i].left_rank != (*substr_rank)[i - 1].left_rank ||
            (*substr_rank)[i].right_rank != (*substr_rank)[i - 1].right_rank) {
            r = r + 1;
        }
        (*rank)[(*substr_rank)[i].index] = r;
    }
}

void compute_suffix_array(char* T, int n, std::vector<int>* SA) {
    std::vector<Rank> substr_rank;
    substr_rank.resize(n);
    std::vector<int> rank;
    rank.resize(n);

    for (int i = 0; i < n; ++i) {
        substr_rank[i].left_rank = int(T[i]);
        if (i < (n - 1)) {
            substr_rank[i].right_rank = int(T[i + 1]);
        } else {
            substr_rank[i].right_rank = 0;
        }
        substr_rank[i].index = i;
    }
    // Actually, radix sort can sort through first running countng sort basd on right-rank then 
    // running counting sort based on left-rank.
    std::stable_sort(std::begin(substr_rank), std::end(substr_rank), compareLeftAndRightRank());
    int l = 2;
    while (l < n) {
        make_ranks(&substr_rank, &rank, n);
        for (int i = 0; i < n; ++i) {
            substr_rank[i].left_rank = rank[i];
            if (i + l < n) {
                substr_rank[i].right_rank = rank[i + 1];
            } else {
                substr_rank[i].right_rank = 0;
            }
            substr_rank[i].index = i;
        }
        std::stable_sort(std::begin(substr_rank), std::end(substr_rank), compareLeftAndRightRank());
        l = l * 2;
    }
    for (int i = 0; i < n; ++i) {
        (*SA)[i] = substr_rank[i].index;
    }
}

int main() {
    char* a("ratatat");
    std::vector<int> SA;
    SA.resize(7);
    compute_suffix_array(a, 7, &SA);
    for (int i = 0; i < 7; ++i) {
        std::cout << SA[i] + 1 << std::endl;
    }
    return 0;
}
