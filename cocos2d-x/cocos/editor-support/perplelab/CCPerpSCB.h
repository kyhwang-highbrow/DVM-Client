#ifndef _CCPerpSCB_H_
#define _CCPerpSCB_H_

#include "cocos2d.h"

class PerpSCB : public cocos2d::Ref
{
public:
	PerpSCB(char *ptr)
		: m_ptr(ptr)
	{
	}
	~PerpSCB()
	{
		if (m_ptr) delete [] m_ptr;
	}

	inline char *ptr() { return m_ptr; }
private:
	char *m_ptr;
};

#endif
