//
//  UIView+AutoLayout.h
//  MBLKit
//
//  Created by Jean-Christophe Amiel on 24/09/14.
//  Copyright (c) 2014 Manbolo. All rights reserved.
//
#import <UIKit/UIKit.h>


@interface UIView (AutoLayout)

- (NSArray *)centerHorizontallyInSuperview;
- (NSArray *)centerHorizontallyInSuperviewConstant:(CGFloat)constant;
- (NSArray *)centerVerticallyInSuperview;
- (NSArray *)centerVerticallyInSuperviewConstant:(CGFloat)constant;
- (NSArray *)centerInSuperview;

- (void)setWidthRatioInSuperview:(CGFloat)scale;
- (void)setWidthRatioInSuperview:(CGFloat)scale constant:(CGFloat)constant;
- (void)setHeightRatioInSuperview:(CGFloat)scale;
- (void)setHeightRatioInSuperview:(CGFloat)scale constant:(CGFloat)constant;
- (void)fillSuperview;
- (void)fillSuperviewHorizontally;
- (void)fillSuperviewVertically;
- (void)equalWidthWith:(UIView *)view;
- (void)equalWidthWith:(UIView *)view constant:(CGFloat)constant;
- (NSArray *)equalWidth:(CGFloat)width;
- (void)equalHeightWith:(UIView *)view;
- (void)equalHeightWith:(UIView *)view constant:(CGFloat)constant;
- (NSArray *)equalHeight:(CGFloat)height;
- (NSArray *)maximizeWidth:(CGFloat)width;

- (NSArray *)setTopSpaceInSuperview:(CGFloat)top;
- (NSArray *)setLeftSpaceInSuperview:(CGFloat)left;




@end
