//
//  GameOverViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/20/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardStore.h"
@class GameManager, CMBitmapNumberView;

@protocol GameOverViewControllerDelegate;

@interface GameOverViewController : UIViewController<UITextFieldDelegate, BoardStoreDelegate> 

@property (nonatomic, strong) UITextField *userNameField;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIActivityIndicatorView *submitIndicatorView;
@property (nonatomic, weak) id<GameOverViewControllerDelegate> delegate;
@property (nonatomic, strong) CMBitmapNumberView *maxScoreView;
@property (nonatomic, strong) CALayer *stampLayer;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) NSMutableArray *labels;

- (IBAction)submitScore:(id)sender;
- (IBAction)replay:(id)sender;
- (void)gameOverViewControllerviewWillAppear:(BOOL)animated;
- (void)gameOverViewControllerDidAppear:(BOOL)animated;
- (void)addCurrentScoreToHighscore;


@end

@protocol GameOverViewControllerDelegate
- (void)gameOverDidCompletedAnimation:(GameOverViewController*)controller;
- (void)gameOverDidSelectReplay:(GameOverViewController*)controller;
@end