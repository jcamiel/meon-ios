//
//  UIFont+Helper.h
//  MBLKit
//
//  Created by Jean-Christophe Amiel on 13/01/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Helper)

- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width lineNumber:(NSInteger)lineNumber;
- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width;
- (CGFloat)widthForText:(NSString *)text;
- (CGSize)sizeForText:(NSString *)text;

@end
