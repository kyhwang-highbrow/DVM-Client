#ifndef __AZMODEL__AZID__
#define __AZMODEL__AZID__

#include <ctime>

namespace azModel {

	class AzID
	{
	private:
		static unsigned long long _prev_id;
		static time_t _2014_sec;

	public:
		static long long genID()
		{
			time_t timer;
			time(&timer);

			unsigned long long current_id;
//			unsigned long long current_id = static_cast<unsigned long long>(timer - _2014_sec) << 16;
//			if ((current_id & 0xffffffffffff0000) <= (_prev_id & 0xffffffffffff0000))
			{
				current_id = _prev_id + 1;
			}

			_prev_id = current_id;

			return current_id;
		}

		static const AzID INVALID;

		AzID() : _value(genID()) {}
		AzID(unsigned long long v) : _value(v) {}
		~AzID() {}

		inline AzID operator = (const AzID& rtid)
		{
			_value = rtid._value;
			return *this;
		}
		inline bool operator < (const AzID& rtid) const
		{
			return _value < rtid._value;
		}
		inline bool operator > (const AzID& rtid) const
		{
			return _value > rtid._value;
		}
		inline bool operator == (const AzID& rtid) const
		{
			return _value == rtid._value;
		}
		inline bool operator != (const AzID& rtid) const
		{
			return _value != rtid._value;
		}

		inline long long getValue() const
		{
			return _value;
		}

	private:
		unsigned long long _value;
	};


}

#endif//__AZMODEL__AZID__
