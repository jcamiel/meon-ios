//
//  NSString+Constant.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/23/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//

#import "NSString+Constant.h"

@implementation NSString (Constant)

+ (NSString*)stringFromUIInterfaceOrientation:(UIInterfaceOrientation)constant
{
    switch (constant) {
        case UIInterfaceOrientationPortrait:
            return @"UIInterfaceOrientationPortrait";
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"UIInterfaceOrientationPortraitUpsideDown";
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return @"UIInterfaceOrientationLandscapeLeft";
            break;
        case UIInterfaceOrientationLandscapeRight:
            return @"UIInterfaceOrientationLandscapeRight";
            break;
        case UIInterfaceOrientationUnknown:
            return @"UIInterfaceOrientationUnknown";
            break;

    }
    return nil;
}

@end
