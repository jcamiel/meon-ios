//
//  UIView+AutoLayout.m
//  MBLKit
//
//  Created by Jean-Christophe Amiel on 24/09/14.
//  Copyright (c) 2014 Manbolo. All rights reserved.
//

#import "UIView+AutoLayout.h"

@implementation UIView (AutoLayout)

- (NSArray *)centerInSuperview {
    NSArray *horizontalConstraints = [self centerHorizontallyInSuperview];
    NSArray *verticalConstraints = [self centerVerticallyInSuperview];

    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:horizontalConstraints];
    [constraints addObjectsFromArray:verticalConstraints];
    return [NSArray arrayWithArray:constraints];
}


- (NSArray *)centerHorizontallyInSuperviewConstant:(CGFloat)constant {
    NSLayoutConstraint *c;
    c = [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:constant];
    [self.superview addConstraint:c];
    return @[c];
}


- (NSArray *)centerHorizontallyInSuperview {
    return [self centerHorizontallyInSuperviewConstant:0];
}


- (NSArray *)centerVerticallyInSuperview {
    return [self centerVerticallyInSuperviewConstant:0];
}


- (NSArray *)centerVerticallyInSuperviewConstant:(CGFloat)constant {
    NSLayoutConstraint *c;
    c = [NSLayoutConstraint constraintWithItem:self
                                     attribute:NSLayoutAttributeCenterY
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.superview
                                     attribute:NSLayoutAttributeCenterY
                                    multiplier:1
                                      constant:constant];
    [self.superview addConstraint:c];
    return @[c];
}


- (void)setWidthRatioInSuperview:(CGFloat)scale {
    [self setWidthRatioInSuperview:scale constant:0];
}


// TODO: changer le signe de la constante.
- (void)setWidthRatioInSuperview:(CGFloat)scale constant:(CGFloat)constant {

    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:scale
                                                                constant:constant]];
}


- (void)setHeightRatioInSuperview:(CGFloat)scale {
    [self setHeightRatioInSuperview:scale constant:0];
}


- (void)setHeightRatioInSuperview:(CGFloat)scale constant:(CGFloat)constant {
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.superview
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:scale
                                                                constant:constant]];
}


- (void)fillSuperview {
    [self fillSuperviewHorizontally];
    [self fillSuperviewVertically];
}


- (void)fillSuperviewHorizontally {
    UIView *aView = self;
    [aView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[aView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(aView)]];
}


- (void)fillSuperviewVertically {
    UIView *aView = self;
    [aView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[aView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(aView)]];
}


- (void)equalWidthWith:(UIView *)view {
    [self equalWidthWith:view constant:0];
}


- (void)equalWidthWith:(UIView *)view constant:(CGFloat)constant {
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:constant]];
}


- (NSArray *)equalWidth:(CGFloat)width {
    UIView *aView = self;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:aView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:width];
    [self addConstraint:constraint];
    return @[constraint];
}


- (NSArray *)maximizeWidth:(CGFloat)width {
    UIView *aView = self;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:aView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationLessThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:width];
    [self addConstraint:constraint];
    return @[constraint];
}


- (NSArray *)equalHeight:(CGFloat)height {
    UIView *aView = self;

    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:aView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:height];

    [self addConstraint:constraint];

    return @[constraint];
}


- (void)equalHeightWith:(UIView *)view {
    [self equalHeightWith:view constant:0];
}


- (void)equalHeightWith:(UIView *)view constant:(CGFloat)constant {
    [self.superview addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1
                                                                constant:constant]];
}


- (NSArray *)setTopSpaceInSuperview:(CGFloat)top {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:top];
    [self.superview addConstraint:constraint];
    return @[constraint];
}


- (NSArray *)setLeftSpaceInSuperview:(CGFloat)left {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:left];
    [self.superview addConstraint:constraint];
    return @[constraint];
}


@end
