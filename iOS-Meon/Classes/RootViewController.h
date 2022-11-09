//
//  RootViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright Manbolo 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AchievementsViewController.h"
#import "CongratulationiPadViewController.h"
#import "CongratulationViewController.h"
#import "EditorViewController.h"
#import "MainMenuiPadViewController.h"
#import "MainMenuViewController.h"
#import "OptionsViewController.h"
#import "PlayiPadViewController.h"
#import "PlayViewController.h"
#import "ScoresViewController.h"
#import "TimeAttackViewController.h"

@class GameManager;

@interface RootViewController : UIViewController<
// iPhone Protocols
    MainMenuViewControllerDelegate,
    PlayViewControllerDelegate,
    TimeAttackViewControllerDelegate,
    CongratulationViewControllerDelegate,
    OptionsViewControllerDelegate,
    ScoresViewControllerDelegate,
	AchievementsViewControllerDelegate,
	EditorViewControllerDelegate,
// iPad Protocols
    MainMenuiPadViewControllerDelegate,
    PlayiPadViewControllerDelegate,
    CongratulationiPadViewControllerDelegate>

@property (nonatomic, copy) NSString *previousViewControllerName;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, strong) NSMutableDictionary *controllers;
- (UIViewController*)loadViewController:(NSString*)viewController;


@end

