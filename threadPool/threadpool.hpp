#ifndef THREADPOOL_HPP
#define THREADPOOL_HPP

#include <condition_variable>
#include <cstdint>
#include <functional>
#include <future>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>

class ThreadPool {
private:
    // storage for threads and tasks
    std::vector<std::thread> threads;
    std::queue<std::function<void(void)>> tasks;

    // primitives for signaling
    std::mutex mutex;
    std::condition_variable cv;

    // the state of the thread pool
    bool stop_pool;
    uint32_t active_threads;
    const uint32_t capacity;
    // custom task factory
    template <typename Func, typename... Args,
              typename Rtrn = typename std::result_of<Func(Args...)>::type>
    auto make_task(Func&& func, Args&&... args) -> std::packaged_task<Rtrn(void)> {
        auto aux = std::bind(std::forward<Func>(func), std::forward<Args>(args)...);
        return std::packaged_task<Rtrn(void)>(aux);
    }

    // will be executed before execution of a task
    void before_task_hook() { active_threads++; }

    // will be executed after execution of a task
    void after_task_hook() { active_threads--; }

public:
    ThreadPool(uint64_t capacity_)
            : stop_pool(false),     // pool is running
              active_threads(0),    // no work to be done
              capacity(capacity_) { // remember size
        // this function is executed by the threads
        auto wait_loop = [this]() -> void {
            // wait forever
            while (true) {
                // this is a placeholder task
                std::function<void(void)> task;
                { // lock this section for waiting
                    std::unique_lock<std::mutex> unique_lock(mutex);

                    auto predicate = [this]() -> bool { return (stop_pool) || !(tasks.empty()); };

                    cv.wait(unique_lock, predicate);

                    if (stop_pool && tasks.empty()) return;

                    task = std::move(tasks.front());
                    tasks.pop();
                    before_task_hook();
                }

                task();

                {
                    std::lock_guard<std::mutex> lock_guard(mutex);
                    after_task_hook();
                }
            }
        };

        for (uint64_t id = 0; id < capacity; id++) {
            threads.emplace_back(wait_loop);
        }
    }

    ~ThreadPool() {
        {
            std::lock_guard<std::mutex> lock_guard(mutex);
            stop_pool = true;
        }

        cv.notify_all();

        for (auto& thread : threads) thread.join();
    }

    template <typename Func, typename... Args,
              typename Rtrn = typename std::result_of<Func(Args...)>::type>
    auto enqueue(Func&& func, Args&&... args) -> std::future<Rtrn> {
        auto task = make_task(func, args...);
        auto future = task.get_future();
        auto task_ptr = std::make_shared<decltype(task)>(std::move(task));

        {
            std::lock_guard<std::mutex> lock_guard(mutex);
            if (stop_pool) throw std::runtime_error("enqueue on stopped ThreadPool");
            auto payload = [task_ptr]() -> void { task_ptr->operator()(); };
            tasks.emplace(payload);
        }

        cv.notify_one();
        return future;
    }
};

#endif
