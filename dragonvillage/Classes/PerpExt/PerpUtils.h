#ifndef _PerpUtils_H_
#define _PerpUtils_H_

#include "cocos2d.h"

using namespace cocos2d;
using namespace std;

class PerpUtils
{
public:
    static unsigned char *GetEncrypedFileData(const char *path);
    static void XorEncrypt(const char *path, const char *tar);
};

#endif
