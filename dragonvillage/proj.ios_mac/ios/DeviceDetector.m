//
//  DeviceDetector.m
//  DragonVillageM
//
//  Created by PerpleLab on 2017. 8. 15..
//
//

#import "DeviceDetector.h"
#import <sys/utsname.h>

@implementation DeviceDetector

+ (NSString *)deviceName {
    struct utsname u;
    uname(&u);

    if (!strcmp(u.machine, "iPhone1,1")) {
        return @"iPhone";
    } else if (!strcmp(u.machine, "iPhone1,2")) {
        return @"iPhone 3G";
    } else if (!strcmp(u.machine, "iPhone2,1")) {
        return @"iPhone 3GS";
    } else if (!strcmp(u.machine, "iPhone3,1") ||
               !strcmp(u.machine, "iPhone3,3")) {
            return @"iPhone 4";
    } else if (!strcmp(u.machine, "iPhone4,1")) {
        return @"iPhone 4S";
    } else if (!strcmp(u.machine, "iPhone5,1") ||
               !strcmp(u.machine, "iPhone5,2")) {
        return @"iPhone 5";
    } else if (!strcmp(u.machine, "iPhone5,3") ||
               !strcmp(u.machine, "iPhone5,4")) {
        return @"iPhone 5c";
    } else if (!strcmp(u.machine, "iPhone6,1") ||
               !strcmp(u.machine, "iPhone6,2")) {
        return @"iPhone 5s";
    } else if (!strcmp(u.machine, "iPhone7,1")) {
        return @"iPhone 6 Plus";
    } else if (!strcmp(u.machine, "iPhone7,2")) {
        return @"iPhone 6";
    } else if (!strcmp(u.machine, "iPhone8,1")) {
        return @"iPhone 6s";
    } else if (!strcmp(u.machine, "iPhone8,2")) {
        return @"iPhone 6s Plus";
    } else if (!strcmp(u.machine, "iPhone8,4")) {
        return @"iPhone SE";
    } else if (!strcmp(u.machine, "iPhone9,1") ||
               !strcmp(u.machine, "iPhone9,3")) {
        return @"iPhone 7";
    } else if (!strcmp(u.machine, "iPhone9,2") ||
               !strcmp(u.machine, "iPhone9,4")) {
        return @"iPhone 7 Plus";
    } else if (!strcmp(u.machine, "iPad1,1")) {
        return @"iPad";
    } else if (!strcmp(u.machine, "iPad2,1") ||
               !strcmp(u.machine, "iPad2,2") ||
               !strcmp(u.machine, "iPad2,3") ||
               !strcmp(u.machine, "iPad2,4")) {
        return @"iPad 2";
    } else if (!strcmp(u.machine, "iPad2,5") ||
               !strcmp(u.machine, "iPad2,6") ||
               !strcmp(u.machine, "iPad2,7")) {
        return @"iPad mini";
    } else if (!strcmp(u.machine, "iPad3,1") ||
               !strcmp(u.machine, "iPad3,2") ||
               !strcmp(u.machine, "iPad3,3")) {
        return @"iPad (3rd)";
    } else if (!strcmp(u.machine, "iPad3,4") ||
               !strcmp(u.machine, "iPad3,5") ||
               !strcmp(u.machine, "iPad3,6")) {
        return @"iPad (4th)";
    } else if (!strcmp(u.machine, "iPad4,1") ||
               !strcmp(u.machine, "iPad4,2") ||
               !strcmp(u.machine, "iPad4,3")) {
        return @"iPad Air";
    } else if (!strcmp(u.machine, "iPad4,4") ||
               !strcmp(u.machine, "iPad4,5") ||
               !strcmp(u.machine, "iPad4,6")) {
        return @"iPad mini 2";
    } else if (!strcmp(u.machine, "iPad4,7") ||
               !strcmp(u.machine, "iPad4,8") ||
               !strcmp(u.machine, "iPad4,9")) {
        return @"iPad mini 3";
    } else if (!strcmp(u.machine, "iPad5,1") ||
               !strcmp(u.machine, "iPad5,2")) {
        return @"iPad mini 4";
    } else if (!strcmp(u.machine, "iPad5,3") ||
               !strcmp(u.machine, "iPad5,4")) {
        return @"iPad Air 2";
    } else if (!strcmp(u.machine, "iPad6,3") ||
               !strcmp(u.machine, "iPad6,4")) {
        return @"iPad Pro (9.7)";
    } else if (!strcmp(u.machine, "iPad6,7") ||
               !strcmp(u.machine, "iPad6,8")) {
        return @"iPad Pro (12.9)";
    } else if (!strcmp(u.machine, "iPad6,11") ||
               !strcmp(u.machine, "iPad6,12")) {
        return @"iPad (5th)";
    } else if (!strcmp(u.machine, "iPod1,1")) {
        return @"iPod touch";
    } else if (!strcmp(u.machine, "iPod2,1")) {
        return @"iPod touch (2nd)";
    } else if (!strcmp(u.machine, "iPod3,1")) {
        return @"iPod touch (3rd)";
    } else if (!strcmp(u.machine, "iPod4,1")) {
        return @"iPod touch (4th)";
    } else if (!strcmp(u.machine, "iPod5,1")) {
        return @"iPod touch (5th)";
    } else if (!strcmp(u.machine, "iPod7,1")) {
        return @"iPod touch (6th)";
    }

    return [NSString stringWithFormat:@"unknown(%s)",u.machine];
}

@end
