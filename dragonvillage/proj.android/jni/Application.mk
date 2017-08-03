APP_STL := gnustl_shared
NDK_TOOLCHAIN_VERSION=4.9

APP_CPPFLAGS := -frtti -fexceptions -DCC_ENABLE_CHIPMUNK_INTEGRATION=1 -std=c++11 -fsigned-char
APP_LDFLAGS := -latomic
APP_ABI := armeabi armeabi-v7a x86

APP_PLATFORM := android-16

APP_DEBUG := $(strip $(NDK_DEBUG))
ifeq ($(APP_DEBUG),1)
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=1
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DNDEBUG
  APP_OPTIM := release
endif