APP_STL := gnustl_static
NDK_TOOLCHAIN_VERSION=4.9

APP_CPPFLAGS := -frtti -DCC_ENABLE_CHIPMUNK_INTEGRATION=1 -std=c++11 -fsigned-char
APP_LDFLAGS := -latomic
APP_ABI := armeabi armeabi-v7a arm64-v8a x86

APP_SHORT_COMMANDS := true

APP_PLATFORM := android-16

APP_DEBUG := $(strip $(NDK_DEBUG))
ifeq ($(APP_DEBUG),1)
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=1
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DNDEBUG
  APP_OPTIM := release
endif