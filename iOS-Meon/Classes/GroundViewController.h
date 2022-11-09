//
//  GroundViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/13/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Level, GroundView;


@protocol GroundViewControllerDelegate;

@interface GroundViewController : UIViewController

@property (nonatomic, weak) id<GroundViewControllerDelegate> delegate;
@property (nonatomic, strong) Level *level;
@property (nonatomic, strong) GroundView *groundView;
@property (nonatomic, assign, getter = isTouchesInteractionEnabled) BOOL touchesInteractionEnabled;
@property (nonatomic, strong) UIView *rasterizedGroundView;

- (void)rasterizeGroundView;


@end



@protocol GroundViewControllerDelegate
- (void)groundViewLevelDidCompleted:(GroundViewController*)controller;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end