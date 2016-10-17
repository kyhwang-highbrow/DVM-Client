LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

subdirs := $(LOCAL_PATH)/main/Android.mk \
           $(LOCAL_PATH)/../../../libraries/pati/prebuilt/android/Android.mk

include $(subdirs)
