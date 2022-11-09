//
//  UIColor+Helper.m
//  OrangeButton
//
//  Created by Jean-Christophe Amiel on 11/9/11.
//  Copyright (c) 2011 Orange. All rights reserved.
//

#import "UIColor+Helper.h"

@implementation UIColor (Helper)

+ (UIColor*)colorWithHexCode:(NSUInteger)code
{
    CGFloat r = ((code & 0xFF0000) >> 16)* 1.0 / 255;
    CGFloat g = ((code & 0xFF00) >> 8)  * 1.0 / 255;
    CGFloat b = (code & 0xFF) * 1.0 / 255;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}


@end
