//
//  BuildConfig.h
//  Moloco
//
//  MolocoAds
//

#pragma once

#define MOLOCO_VERSION_NUMBER        20150523
#define MOLOCO_VERSION_STRING        @"ios-20150523-moloco"

#define MOLOCO_CONST(NAME)           kMLC##NAME
#define MOLOCO_CLASS(NAME)           Moloco##NAME
#define MOLOCO_DELEGATE_METHOD(NAME) moloco##NAME
#define MOLOCO_METHOD(NAME)          moloco##NAME

#ifndef __clang__
#ifndef __has_extension
#define __has_extension(E) 0
#endif
#endif

#if __has_extension(attribute_deprecated_with_message)
#define MOLOCO_DEPRECATED(MSG) __attribute__((deprecated(MSG)))
#else
#define MOLOCO_DEPRECATED(MSG) __attribute__((deprecated))
#endif
