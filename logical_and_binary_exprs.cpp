#include <immintrin.h>
#include <string.h>

#include <iostream>
#include <queue>
#include <vector>

typedef struct Row {
    int a;
    int b;
} Row;

// In my computer, the latest version of simd instructor is  SSE2, so I take it.
// but in product environment, we can use latest version of AVX.
int32_t PACKED_SIZE_OF_SSE2 = 4;

enum LOGICAL_TYPE { AND = 0, OR = 2 };

enum ARITHMITIC_TYPE { GE = 0, LT = 1, EQ = 2 };

template <LOGICAL_TYPE op>
void logical_expr(int32_t* column_result_first, int32_t* column_result_second,
                  int32_t* column_logical_result, int32_t num) {
    int num_in_chunks = num / PACKED_SIZE_OF_SSE2 * PACKED_SIZE_OF_SSE2;
    int i = 0;

    for (; i < num_in_chunks; i += PACKED_SIZE_OF_SSE2) {
        __m128i vec_first = _mm_load_si128(
            reinterpret_cast<const __m128i*>((&column_result_first[i])));
        __m128i vec_second = _mm_load_si128(
            reinterpret_cast<const __m128i*>((&column_result_second[i])));
        __m128i simdAnd2;

        // use SSE2 instructor to compute more effiency
        if constexpr (op == AND) {
            simdAnd2 = _mm_and_si128(vec_first, vec_second);
        } else if constexpr (op == OR) {
            simdAnd2 = _mm_or_si128(vec_first, vec_second);
        }

        memcpy(column_logical_result + i, &simdAnd2, sizeof(__m128i));
    }

    // process unpacked datas.
    for (; i < num; ++i) {
        if constexpr (op == AND) {
            column_logical_result[i] =
                (column_result_first[i] & column_result_second[i]);
        } else if constexpr (op == OR) {
            column_logical_result[i] =
                (column_result_first[i] | column_result_second[i]);
        }
    }
}

template <ARITHMITIC_TYPE op>
void arithmetic_compare_expr(int32_t* column_data, int32_t* column_expr_result,
                             int32_t num, int32_t constant) {
    __m128i comp2 = _mm_set_epi32(constant, constant, constant, constant);
    __m128i comp3 = _mm_set_epi32(1, 1, 1, 1);

    int num_in_chunks = num / PACKED_SIZE_OF_SSE2 * PACKED_SIZE_OF_SSE2;
    int i = 0;
    for (; i < num_in_chunks; i += PACKED_SIZE_OF_SSE2) {
        __m128i vec =
            _mm_load_si128(reinterpret_cast<const __m128i*>((&column_data[i])));
        __m128i simdAnd2;

        // use SSE2 instructor to compute more effiency
        if constexpr (op == GE) {
            simdAnd2 = _mm_cmplt_epi32(vec, comp2);
            simdAnd2 = _mm_xor_si128(simdAnd2, comp3);
        } else if constexpr (op == LT) {
            simdAnd2 = _mm_cmplt_epi32(vec, comp2);
        } else if constexpr (op == EQ) {
            simdAnd2 = _mm_cmpeq_epi32(vec, comp2);
        }

        memcpy(column_expr_result + i, &simdAnd2, sizeof(__m128i));
    }

    // process unpacked datas.
    for (; i < num; ++i) {
        if constexpr (op == GE) {
            if (column_data[i] >= constant) {
                column_expr_result[i] = 1;
            }
        } else if constexpr (op == LT) {
            if (column_data[i] < constant) {
                column_expr_result[i] = 1;
            }
        } else if constexpr (op == EQ) {
            if (column_data[i] == constant) {
                column_expr_result[i] = 1;
            }
        }
    }
}

/*
 * This is our core method.
 * At first,  we collect a and b at rows into a seperate column, because It enable memory cached more effiency.
 * second,    as there are 2 types of operations: arithmetic(>=,<,==) and logical(&&, ||), so we define two template
 *            methods: arithmetic_compare_expr and logical_expr, to compute more effiency through SIMD instructor(__m128i).
 * third,     with sorted rows, we just omit operations on column a to compute more effiency 
 */
void compute_binary_operations_on_range(
    const Row* rows, int start, int end, bool should_compare_a,
    std::vector<int32_t>& filter_of_result) {
    std::vector<int32_t> first_column;
    int nrows = end - start + 1;
    first_column.resize(nrows);
    for (int i = 0; i < nrows; ++i) {
        first_column[i] = rows[start + i].b;
    }

    std::vector<int32_t> second_column;
    second_column.resize(nrows);
    for (int i = 0; i < nrows; ++i) {
        second_column[i] = rows[start + i].a;
    }

    // process case of b >= 10
    std::vector<int32_t> first_column_ge_result;
    first_column_ge_result.resize(nrows, 0);
    arithmetic_compare_expr<GE>(first_column.data(),
                                first_column_ge_result.data(), nrows, 10);

    // process case of b < 500000
    std::vector<int32_t> first_column_lt_result;
    first_column_lt_result.resize(nrows, 0);
    arithmetic_compare_expr<LT>(first_column.data(),
                                first_column_lt_result.data(), nrows, 500000);

    // process case of a == 10
    std::vector<int32_t> second_column_eq0_result;
    if (should_compare_a) {
        second_column_eq0_result.resize(nrows, 0);
        arithmetic_compare_expr<EQ>(second_column.data(),
                                    second_column_eq0_result.data(), nrows, 10);
    }

    // process case of a == 200
    std::vector<int32_t> second_column_eq1_result;
    if (should_compare_a) {
        second_column_eq1_result.resize(nrows, 0);
        arithmetic_compare_expr<EQ>(
            second_column.data(), second_column_eq1_result.data(), nrows, 200);
    }

    // process case of a == 3000
    std::vector<int32_t> second_column_eq2_result;
    if (should_compare_a) {
        second_column_eq2_result.resize(nrows, 0);
        arithmetic_compare_expr<EQ>(
            second_column.data(), second_column_eq2_result.data(), nrows, 3000);
    }

    // process case of b >= 10 and b < 50000
    std::vector<int32_t> first_logical_expr_result;
    if (!should_compare_a) {
        filter_of_result.resize(nrows, 0);
        logical_expr<AND>(first_column_ge_result.data(),
                          first_column_lt_result.data(),
                          filter_of_result.data(), nrows);
    } else {
        first_logical_expr_result.resize(nrows, 0);
        logical_expr<AND>(first_column_ge_result.data(),
                          first_column_lt_result.data(),
                          first_logical_expr_result.data(), nrows);
    }

    // process case of a == 10 || a == 200
    std::vector<int32_t> second_logical_expr_result;
    if (should_compare_a) {
        second_logical_expr_result.resize(nrows, 0);
        logical_expr<OR>(second_column_eq0_result.data(),
                         second_column_eq1_result.data(),
                         second_logical_expr_result.data(), nrows);
    }

    // process case of (a == 10 || a == 200) || a == 3000
    std::vector<int32_t> third_logical_expr_result;
    if (should_compare_a) {
        third_logical_expr_result.resize(nrows, 0);
        logical_expr<OR>(second_logical_expr_result.data(),
                         second_column_eq2_result.data(),
                         third_logical_expr_result.data(), nrows);
    }

    // process case of (b >= 10 && b < 500000) && (a == 10 || a == 200) || a ==
    // 3000)
    std::vector<int32_t> fourth_logical_expr_result;
    if (should_compare_a) {
        filter_of_result.resize(nrows, 0);
        logical_expr<AND>(first_logical_expr_result.data(),
                          third_logical_expr_result.data(),
                          filter_of_result.data(), nrows);
    }
}

void task1(const Row* rows, int nrows) {
    std::cout << "output of task1: " << std::endl;

    std::vector<int32_t> filter_of_result;
    compute_binary_operations_on_range(rows, 0, nrows - 1, true,
                                       filter_of_result);
    for (int i = 0; i < nrows; ++i) {
        if (filter_of_result[i]) {
            std::cout << rows[i].a << "," << rows[i].b << std::endl;
        }
    }
}

// find left bound at this sorted rows with target.
int left_bound(const Row* rows, int nrows, int target) {
    int left = 0, right = nrows - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (rows[mid].a < target) {
            left = mid + 1;
        } else if (rows[mid].a > target) {
            right = mid - 1;
        } else if (rows[mid].a == target) {
            right = mid - 1;
        }
    }

    return left;
}

// find right bound at this sorted rows with target.
int right_bound(const Row* rows, int nrows, int target) {
    int left = 0, right = nrows - 1;
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (rows[mid].a < target) {
            left = mid + 1;
        } else if (rows[mid].a > target) {
            right = mid - 1;
        } else if (rows[mid].a == target) {
            left = mid + 1;
        }
    }

    return right;
}

void task2(const Row* rows, int nrows) {
    std::cout << "output of task2: " << std::endl;

    // first part: output the result when a == 10
    {
        // left bound for a == 10
        int left_bound_index = left_bound(rows, nrows, 10);
        if (left_bound_index >= nrows) {
            return;
        }
        // right_bound for a == 10
        int right_bound_index = right_bound(rows, nrows, 10);
        if (right_bound_index < 0 || right_bound_index < left_bound_index) {
            return;
        }

        std::vector<int32_t> filter_of_result;
        compute_binary_operations_on_range(
            rows, left_bound_index, right_bound_index, false, filter_of_result);
        for (int i = left_bound_index; i <= right_bound_index; ++i) {
            if (filter_of_result[i - left_bound_index]) {
                std::cout << rows[i].a << "," << rows[i].b << std::endl;
            }
        }
    }

    // second part: output the result when a == 200
    {
        // left bound for a == 200
        int left_bound_index = left_bound(rows, nrows, 200);
        if (left_bound_index >= nrows) {
            return;
        }
        // right_bound for a == 200
        int right_bound_index = right_bound(rows, nrows, 200);
        if (right_bound_index < 0 || right_bound_index < left_bound_index) {
            return;
        }

        std::vector<int32_t> filter_of_result;
        compute_binary_operations_on_range(
            rows, left_bound_index, right_bound_index, false, filter_of_result);
        for (int i = left_bound_index; i <= right_bound_index; ++i) {
            if (filter_of_result[i - left_bound_index]) {
                std::cout << rows[i].a << "," << rows[i].b << std::endl;
            }
        }
    }

    // third part: output the result when a == 3000
    {
        // left bound for a ==  3000
        int left_bound_index = left_bound(rows, nrows, 3000);
        if (left_bound_index >= nrows) {
            return;
        }
        // right_bound for a == 3000
        int right_bound_index = right_bound(rows, nrows, 3000);
        if (right_bound_index < 0 || right_bound_index < left_bound_index) {
            return;
        }

        std::vector<int32_t> filter_of_result;
        compute_binary_operations_on_range(
            rows, left_bound_index, right_bound_index, false, filter_of_result);
        for (int i = left_bound_index; i <= right_bound_index; ++i) {
            if (filter_of_result[i - left_bound_index]) {
                std::cout << rows[i].a << "," << rows[i].b << std::endl;
            }
        }
    }
}

struct PackedResult {
public:
    PackedResult(std::vector<Row>* sorted_result, int index):sorted_result(sorted_result), index(index) {}
    bool has_next() {
        return index < sorted_result->size();
    }
    
    std::vector<Row>* sorted_result;
    int index;
};

struct PackedResultHeap {
public:
    PackedResultHeap(const std::vector<PackedResult*>& packed_results): internal_vector(packed_results) {
        heapify();
    }
    
    // as we know, this heap just hold 3 elements, so we just heapify 0(top) element.
    void heapify() {
        int smallest = 0;
        PackedResult* smallest_result = internal_vector[smallest];
        PackedResult* smallest_result_candicate1 = internal_vector[1];
        PackedResult* smallest_result_candicate2 = internal_vector[2];
        
        if (smallest_result->has_next()) {
            if (smallest_result_candicate1->has_next()) {
                if ((*smallest_result->sorted_result)[smallest_result->index].b > (*smallest_result_candicate1->sorted_result)[smallest_result_candicate1->index].b) {
                    smallest = 1;
                }
            }
            if (smallest_result_candicate2->has_next()) {
                smallest_result = internal_vector[smallest];
                if ((*smallest_result->sorted_result)[smallest_result->index].b > (*smallest_result_candicate2->sorted_result)[smallest_result_candicate2->index].b) {
                    smallest = 2;
                }
            }
        } else {
            if (smallest_result_candicate1->has_next() && smallest_result_candicate2->has_next()) {
                if ((*smallest_result_candicate1->sorted_result)[smallest_result_candicate1->index].b > (*smallest_result_candicate2->sorted_result)[smallest_result_candicate2->index].b) {
                    smallest = 2;
                } else {
                    smallest = 1;
                }
            } else if (smallest_result_candicate1->has_next()) {
                smallest = 1;
            } else {
                smallest = 2;
            }
        }
        
        if (smallest != 0) {
            PackedResult* smallest_result = internal_vector[smallest];
            internal_vector[smallest] = internal_vector[0];
            internal_vector[0] = smallest_result;
        }
    }
    
    Row top() {
        PackedResult* smallest_result = internal_vector[0];
        return (*smallest_result->sorted_result)[smallest_result->index];
    }
    
    void pop() {
        PackedResult* smallest_result = internal_vector[0];
        ++smallest_result->index;
        heapify();
    }
    
    bool has_next() {
        PackedResult* smallest_result = internal_vector[0];
        return smallest_result->index < smallest_result->sorted_result->size();
    }
    
    std::vector<PackedResult*> internal_vector;
};

/*
 * task3 is like task2, but collect Rows from result instead of output it
 * directly, and into a priority_queue, then get smallest element based on b
 * column from this priority_queue one by one.
 */
void task3(const Row* rows, int nrows) {
    std::cout << "output of task3: " << std::endl;

    //std::priority_queue<Row, std::vector<Row>, cmp> pq;
    std::vector<Row> soted_result_a_equal_10;
    {
        // left bound for a == 10;
        int left_bound_index = left_bound(rows, nrows, 10);
        if (left_bound_index >= nrows) {
            return;
        }
        // right_bound for a == 10;
        int right_bound_index = right_bound(rows, nrows, 10);
        if (right_bound_index < 0 || right_bound_index < left_bound_index) {
            return;
        }

        std::vector<int32_t> filter_of_result;
        compute_binary_operations_on_range(
            rows, left_bound_index, right_bound_index, false, filter_of_result);
        for (int i = left_bound_index; i <= right_bound_index; ++i) {
            if (filter_of_result[i - left_bound_index]) {
                soted_result_a_equal_10.emplace_back(rows[i]);
            }
        }
    }

    std::vector<Row> soted_result_a_equal_200;
    {
        // left bound for a == 200;
        int left_bound_index = left_bound(rows, nrows, 200);
        if (left_bound_index >= nrows) {
            return;
        }
        // right_bound for a == 200;
        int right_bound_index = right_bound(rows, nrows, 200);
        if (right_bound_index < 0 || right_bound_index < left_bound_index) {
            return;
        }

        std::vector<int32_t> filter_of_result;
        compute_binary_operations_on_range(
            rows, left_bound_index, right_bound_index, false, filter_of_result);
        for (int i = left_bound_index; i <= right_bound_index; ++i) {
            if (filter_of_result[i - left_bound_index]) {
                soted_result_a_equal_200.emplace_back(rows[i]);
            }
        }
    }

    std::vector<Row> soted_result_a_equal_3000;
    {
        // left bound for a ==  3000;
        int left_bound_index = left_bound(rows, nrows, 3000);
        if (left_bound_index >= nrows) {
            return;
        }
        // right_bound for a == 3000;
        int right_bound_index = right_bound(rows, nrows, 3000);
        if (right_bound_index < 0 || right_bound_index < left_bound_index) {
            return;
        }

        std::vector<int32_t> filter_of_result;
        compute_binary_operations_on_range(
            rows, left_bound_index, right_bound_index, false, filter_of_result);
        for (int i = left_bound_index; i <= right_bound_index; ++i) {
            if (filter_of_result[i - left_bound_index]) {
                soted_result_a_equal_3000.emplace_back(rows[i]);
            }
        }
    }

    PackedResult packed_result_a_equal_10(&soted_result_a_equal_10, 0);
    PackedResult packed_result_a_equal_200(&soted_result_a_equal_200, 0);
    PackedResult packed_result_a_equal_3000(&soted_result_a_equal_3000, 0);
    
    // construct a heap use PackedResult
    std::vector<PackedResult*> packed_result_heap = { &packed_result_a_equal_10, &packed_result_a_equal_200, &packed_result_a_equal_10 };
    PackedResultHeap heap(packed_result_heap);
    
    while(heap.has_next()) {
        Row row = heap.top();
        std::cout << row.a << "," << row.b << std::endl;
        heap.pop();
    }
}

int main() {
    Row sorted_rows[] = {
        { 10, 31 },
        { 10, 720000000 },
        { 200, 22 },
        { 200, 33 },
        { 1500, 12 },
        { 1500, 34 },
        { 3000, 5 },
    };
    
    task2(sorted_rows, sizeof(sorted_rows) / sizeof(Row));
    task3(sorted_rows, sizeof(sorted_rows) / sizeof(Row));
    
    return 0;
}
