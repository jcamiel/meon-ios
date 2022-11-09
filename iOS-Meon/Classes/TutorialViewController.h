//
//  TutorialViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/15/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GameManager;


@protocol TutorialViewControllerDelegate;

@interface TutorialViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UIImageView *meonView;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundView;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, assign, getter=isRunningFitToTextAnimation) BOOL runningFitToTextAnimation;
@property (nonatomic, assign, getter=isRunningExpandViewAnimation) BOOL runningExpandViewAnimation;

@property (nonatomic, weak) id<TutorialViewControllerDelegate> delegate;
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *bigFont;


- (void)loadFirstPage;
- (void)expandViewAnimated:(BOOL)animated;
- (void)nextPage;
- (void)loadPage:(NSInteger)page inSection:(NSInteger)section;
- (void)fitToTextAnimated:(BOOL)animated;

@end


@protocol TutorialViewControllerDelegate
-(void)tutorialDidChangePage:(TutorialViewController*)controller;
-(void)tutorialDidChangeSection:(TutorialViewController*)controller;
-(void)tutorialDidFinish:(TutorialViewController*)controller;
@end