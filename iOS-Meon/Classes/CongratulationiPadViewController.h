//
//  CongratulationiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/22/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CongratulationiPadViewControllerDelegate;

@interface CongratulationiPadViewController : UIViewController
@property (nonatomic, weak) id<CongratulationiPadViewControllerDelegate> delegate;
@end

@protocol CongratulationiPadViewControllerDelegate<NSObject>
- (void)congratulationiPadDidTapGoToMenu:(CongratulationiPadViewController*)controller;
- (void)congratulationiPadDidTapBuyFullVersion:(CongratulationiPadViewController*)controller;
@end