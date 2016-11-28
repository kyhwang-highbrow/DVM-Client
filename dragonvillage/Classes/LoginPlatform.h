#ifndef __LOGIN_PLATFORM_H__
#define __LOGIN_PLATFORM_H__

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
// @shipping build
#define SHIPPING_BUILD
#endif


#endif