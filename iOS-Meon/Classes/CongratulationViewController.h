//
//  CongratulationViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/1/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"


@protocol CongratulationViewControllerDelegate;


@interface CongratulationViewController : ModalViewController

@property (nonatomic, weak) id<CongratulationViewControllerDelegate> delegate;
@property (nonatomic, strong) UIImageView *titleView;
@property (nonatomic, strong) UIImageView *meon0;
@property (nonatomic, strong) UIImageView *meon1;
@property (nonatomic, strong) UIImageView *meon2;
@property (nonatomic, strong) UIImageView *meon3;
@property (nonatomic, strong) UIImageView *meon4;
@property (nonatomic, strong) UIImageView *meon5;
@property (nonatomic, strong) UIImageView *meon6;
@property (nonatomic, strong) UIImageView *meon7;
@property (nonatomic, strong) UIImageView *meon8;


- (IBAction)onGoToMainMenu:(id)sender;

@end


@protocol CongratulationViewControllerDelegate
-(void)congratulationDidTapGoToMainMenu:(CongratulationViewController*)controller;
-(void)congratulationDidTapBuyFullVersion:(CongratulationViewController*)controller;

@end