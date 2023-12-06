#include <fstream>
#include <iostream>

using namespace std;

void printLast10Lines(const char* fileName) {
    const int K = 10;
    ifstream file(fileName);
    string L[K];
    int size = 0;

    while(file.peek() != EOF) {
        getline(file, L[size % K]);
        size++;
    }

    int start = size > K ? (size % K) : 0;
    int count = min(K, size);

    for (int i = 0; i < count; i++) {
        cout << L[(start + i) % K] <<endl;
    }
} 

int main() {
    cout << "begin: " << endl;
    string test_file = "testc++program.txt";
    printLast10Lines(test_file.c_str());
    cout << "end" << endl;
    return 0;
}
