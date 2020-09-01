APP_STL := gnustl_static
NDK_TOOLCHAIN_VERSION=4.9

APP_CPPFLAGS := -std=c++11 -frtti -fexceptions
APP_LDFLAGS := -latomic
APP_ABI := armeabi-v7a arm64-v8a x86

APP_PLATFORM := android-16

APP_DEBUG := $(strip $(NDK_DEBUG))
ifeq ($(APP_DEBUG),1)
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DNDEBUG
  APP_OPTIM := release
endif