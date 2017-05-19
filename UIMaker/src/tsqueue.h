#pragma once

#include <queue>
#include <thread>
#include <mutex>
#include <condition_variable>

template <typename T>
class tsqueue
{
public:

	void clear()
	{
		std::unique_lock<std::mutex> mlock(mutex_);
		while (!queue_.empty())
		{
			queue_.pop();
		}
	}

	bool pop(T& item)
	{
		std::unique_lock<std::mutex> mlock(mutex_);
		while (queue_.empty())
		{
			if (cond_.wait_for(mlock, std::chrono::milliseconds(1)) == std::cv_status::timeout) return false;
		}
		item = queue_.front();
		queue_.pop();
		return true;
	}

	void push(const T& item)
	{
		std::unique_lock<std::mutex> mlock(mutex_);
		queue_.push(item);
		mlock.unlock();
		cond_.notify_one();
	}

	void push(T&& item)
	{
		std::unique_lock<std::mutex> mlock(mutex_);
		queue_.push(std::move(item));
		mlock.unlock();
		cond_.notify_one();
	}

private:
	std::queue<T> queue_;
	std::mutex mutex_;
	std::condition_variable cond_;
};

