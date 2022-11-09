//
//  UIView+Helper.m
//  Created by Jean-Christophe Amiel on 6/23/09.
//  MBLKit

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#import "UIView+Helper.h"


@implementation UIView (Helper)


- (CGFloat)x {
    return self.frame.origin.x;
}


- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}


- (CGFloat)width {
    return self.frame.size.width;
}


- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}


- (CGFloat)height {
    return self.frame.size.height;
}


- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


- (CGFloat)y {
    return self.frame.origin.y;
}


- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


- (CGFloat)scale {
    // TODO: make scale
    return 1.0f;
}


- (void)setScale:(CGFloat)scale {
    self.transform = CGAffineTransformMakeScale(scale, scale);
}


- (void)setFrameOrigin:(CGPoint)point {
    CGRect frame = self.frame;
    self.frame = CGRectMake(point.x, point.y, frame.size.width, frame.size.height);
}


#pragma mark - Alignment


- (void)snapFrameToPixel {
    CGRect frame = self.frame;
    CGFloat x = floorf(frame.origin.x);
    CGFloat y = floorf(frame.origin.y);
    CGFloat width = ceilf(frame.size.width);
    CGFloat height = ceilf(frame.size.height);
    self.frame = CGRectMake(x, y, width, height);
}


#pragma mark - Bounding box debug color

- (void)setBorderColor:(UIColor *)color show:(BOOL)show {
    if (show) {
        self.layer.borderColor = [color CGColor];
        self.layer.borderWidth = 1.0f;
    }
    else {
        self.layer.borderColor = nil;
        self.layer.borderWidth = 0.0f;
    }
}


- (BOOL)showsBorder {
    return ((self.layer.borderColor != nil) && (self.layer.borderWidth > 0));
}


- (void)setShowsRedBorder:(BOOL)show {
    [self setBorderColor:[UIColor redColor] show:show];
}


- (void)setShowsGreenBorder:(BOOL)show {
    [self setBorderColor:[UIColor greenColor] show:show];
}


- (void)setShowsPurpleBorder:(BOOL)show {
    [self setBorderColor:[UIColor purpleColor] show:show];
}


- (void)setShowsOrangeBorder:(BOOL)show {
    [self setBorderColor:[UIColor orangeColor] show:show];
}


- (void)setShowsBlueBorder:(BOOL)show {
    [self setBorderColor:[UIColor blueColor] show:show];
}


- (BOOL)showsRedBorder {
    return [self showsBorder];
}


- (BOOL)showsGreenBorder {
    return [self showsBorder];
}


- (BOOL)showsPurpleBorder {
    return [self showsBorder];
}


- (BOOL)showsOrangeBorder {
    return [self showsBorder];
}


- (BOOL)showsBlueBorder {
    return [self showsBorder];
}


- (void)alignWithVerticalCenterOf:(UIView *)aView {
    CGPoint ptToAlign = self.center;
    ptToAlign.y = aView.center.y;

    // snap to pixel boundary (only foe @1x screens)
    BOOL isRetina = ([UIScreen mainScreen].scale == 1.0);
    BOOL isHeightEven = ((int)floor([self height]) % 2) == 1;
    if (isRetina && isHeightEven) {
        ptToAlign.y = floor(ptToAlign.y) + 0.5;
    }

    self.center = ptToAlign;
}


- (void)alignWithHorizontalCenterOf:(UIView *)aView {
    CGPoint ptToAlign = self.center;
    ptToAlign.x = aView.center.x;

    // snap to pixel boundary (only foe @1x screens)
    BOOL isRetina = ([UIScreen mainScreen].scale == 1.0);
    BOOL isWidthEven = ((int)floor([self width]) % 2) == 1;
    if (isRetina && isWidthEven) {
        ptToAlign.x = floor(ptToAlign.x) + 0.5;
    }

    self.center = ptToAlign;
}


- (void)alignWithLeftSideOf:(UIView *)aView {
    [self alignWithLeftSideOf:aView offset:0];
}


- (void)alignWithRightSideOf:(UIView *)aView {
    [self alignWithRightSideOf:aView offset:0];
}


- (void)alignWithBottomSideOf:(UIView *)aView {
    [self alignWithBottomSideOf:aView offset:0];
}


- (void)alignWithTopSideOf:(UIView *)aView {
    [self alignWithTopSideOf:aView offset:0];
}


- (void)alignWithLeftSideOf:(UIView *)aView offset:(CGFloat)offset {
    self.x = aView.x + offset;
}


- (void)alignWithRightSideOf:(UIView *)aView offset:(CGFloat)offset {
    self.x = aView.x + aView.width - self.width - offset;
}


- (void)alignWithBottomSideOf:(UIView *)aView offset:(CGFloat)offset {
    self.y = aView.y + aView.height - self.height - offset;
}


- (void)alignWithTopSideOf:(UIView *)aView offset:(CGFloat)offset {
    self.y = aView.y + offset;
}


- (void)space:(CGFloat)space fromTopSideOf:(UIView *)aView {
    self.y = aView.y - space - self.height;
}


- (void)space:(CGFloat)space fromBottomSideOf:(UIView *)aView {
    self.y = aView.y + aView.height + space;
}


- (void)space:(CGFloat)space fromRightSideOf:(UIView *)aView {
    self.x = aView.x + aView.width + space;
}


- (void)space:(CGFloat)space fromLeftSideOf:(UIView *)aView {
    self.x = aView.x - space - self.width;
}


- (NSUInteger)subviewIndex {
    return [self.superview.subviews indexOfObject:self];
}


@end
