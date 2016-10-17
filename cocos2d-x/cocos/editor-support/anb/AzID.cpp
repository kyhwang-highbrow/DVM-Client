#include "AzID.h"

namespace azModel {
	unsigned long long AzID::_prev_id = 0;
	const AzID AzID::INVALID = AzID(0);

	/*
	struct tm y2k {
	0, 0, 0,   //  sec, min,  hour
	1, 0, 114, // mday, mon,  year
	0, 0, 0,   // wday, yday, isdst
	};
	time_t ms_2014_sec = mktime(&y2k); // 1388502000
	*/
	time_t AzID::_2014_sec = 1388502000;
}

