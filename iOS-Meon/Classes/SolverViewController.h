//
//  SolverViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/5/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"
@protocol SolverViewControllerDelegate;


@interface SolverViewController : ModalViewController

@property (nonatomic, strong) UIImageView *thankyouView;
@property (nonatomic, strong) UILabel *errorView;
@property (nonatomic, strong) UILabel *connectedView;
@property (nonatomic, strong) UILabel *connectingView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, weak) id<SolverViewControllerDelegate> delegate;
@property (nonatomic, strong) UIButton *unlockButton;
@property (nonatomic, strong) UILabel *thankyouLabel;
@property (nonatomic, copy) NSString *productId;
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *bigFont;
- (IBAction)cancel:(id)sender;
- (IBAction)buy:(id)sender;

@end


@protocol SolverViewControllerDelegate
- (void)solverDidSelectBuy:(SolverViewController*)controller;
- (void)solverDidSelectCancel:(SolverViewController*)controller;
- (void)solverDidDisappear:(SolverViewController*)controller;
@end