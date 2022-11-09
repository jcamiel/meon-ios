//
//  UIDevice+Helper.h
//  zApps
//
//  Created by Jean-Christophe Amiel on 11/26/11.
//  Copyright (c) 2011 Orange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Helper)

- (BOOL)isSystemVersionGreaterOrEqualThan:(NSString*)version;
- (NSString*)hardwareModelAndVersion;
- (NSString *)hardwareModel;
- (NSString *)hardwareModelString;


@end
