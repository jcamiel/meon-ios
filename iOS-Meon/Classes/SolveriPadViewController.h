//
//  SolveriPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/31/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ModaliPadViewController.h"
@class SolveriPadViewController;
@class OHAttributedLabel;

@protocol SolveriPadViewControllerDelegate <ModaliPadViewControllerDelegate>
- (void)solveriPadDidSelectBuy:(SolveriPadViewController*)controller;
- (void)solveriPadDidDisappear:(SolveriPadViewController*)controller;
@end


@interface SolveriPadViewController : ModaliPadViewController

@property (nonatomic, copy) NSString *productId;
@property (nonatomic, weak) id<SolveriPadViewControllerDelegate> delegate;
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *bigFont;
@property (nonatomic, strong) UIButton *unlockButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;
@property (nonatomic, strong) UIView *thankyouView;
@property (nonatomic, strong) UILabel *thankyouLabel;
@property (nonatomic, strong) UILabel *connectedView;
@property (nonatomic, strong) UILabel *connectingView;
@property (nonatomic, strong) UILabel *errorView;




@end


