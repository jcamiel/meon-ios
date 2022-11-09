//
//  UIDevice+Helper.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 11/26/11.
//  Copyright (c) 2011 Orange. All rights reserved.
//

#import "UIDevice+Helper.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation UIDevice (Helper)

- (BOOL)isSystemVersionGreaterOrEqualThan:(NSString*)version
{
    NSString *currSysVer = [self systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:version options:NSNumericSearch] 
                               != NSOrderedAscending);
    return osVersionSupported;
}

- (NSString *)hardwareModelAndVersion
{
    NSString *device = [NSString stringWithFormat:@"%@-%@",
                        [[UIDevice currentDevice] hardwareModel],
                        [[UIDevice currentDevice] systemVersion]];
    NSString *pn = [device stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return pn;
}

- (NSString *)hardwareModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = @(machine);
    free(machine);
    return platform;
}

- (NSString *)hardwareModelString
{
    NSString *platform = [self hardwareModel];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}
@end
