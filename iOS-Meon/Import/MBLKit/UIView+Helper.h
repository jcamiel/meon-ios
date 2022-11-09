//
//  UIView+Helper.h
//  Created by Jean-Christophe Amiel on 6/23/09.
//  MBLKit


#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

@interface UIView (Helper) 

@property CGFloat x;
@property CGFloat y;
@property CGFloat width;
@property CGFloat height;
@property CGFloat scale;
@property BOOL showsRedBorder;
@property BOOL showsGreenBorder;
@property BOOL showsPurpleBorder;
@property BOOL showsOrangeBorder;
@property BOOL showsBlueBorder;



- (void)setFrameOrigin:(CGPoint)point;
- (NSUInteger)subviewIndex;


- (void)alignWithVerticalCenterOf:(UIView*)aView;
- (void)alignWithHorizontalCenterOf:(UIView*)aView;
- (void)snapFrameToPixel;
- (void)alignWithVerticalCenterOf:(UIView*)aView;
- (void)alignWithHorizontalCenterOf:(UIView*)aView;
- (void)alignWithLeftSideOf:(UIView*)aView;
- (void)alignWithRightSideOf:(UIView*)aView;
- (void)alignWithBottomSideOf:(UIView*)aView;
- (void)alignWithTopSideOf:(UIView*)aView;
- (void)alignWithLeftSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)alignWithRightSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)alignWithBottomSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)alignWithTopSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)alignWithVerticalCenterOf:(UIView*)aView;
- (void)alignWithHorizontalCenterOf:(UIView*)aView;
- (void)alignWithLeftSideOf:(UIView*)aView;
- (void)alignWithRightSideOf:(UIView*)aView;
- (void)alignWithBottomSideOf:(UIView*)aView;
- (void)alignWithTopSideOf:(UIView*)aView;
- (void)alignWithLeftSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)alignWithRightSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)alignWithBottomSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)alignWithTopSideOf:(UIView*)aView offset:(CGFloat)offset;
- (void)space:(CGFloat)space fromTopSideOf:(UIView*)aView;
- (void)space:(CGFloat)space fromBottomSideOf:(UIView*)aView;
- (void)space:(CGFloat)space fromRightSideOf:(UIView*)aView;
- (void)space:(CGFloat)space fromLeftSideOf:(UIView*)aView;






@end
