//
//  PlayMenuViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/1/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayMenuViewControllerDelegate;
@class GameManager;

@interface PlayMenuViewController : UIViewController

@property (nonatomic, weak) id<PlayMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) GameManager *gameManager;

- (IBAction)playClassic:(id)sender;
- (IBAction)playTimeAttack:(id)sender;
- (IBAction)playWorld:(id)sender;
- (IBAction)back:(id)sender;


@end

@protocol PlayMenuViewControllerDelegate

- (void)playMenuDidSelectPlayClassic:(PlayMenuViewController*)controller;
- (void)playMenuDidSelectPlayTimeAttack:(PlayMenuViewController *)controller;
- (void)playMenuDidSelectPlayWorld:(PlayMenuViewController*)controller;
- (void)playMenuDidSelectBack:(PlayMenuViewController*)controller;

@end