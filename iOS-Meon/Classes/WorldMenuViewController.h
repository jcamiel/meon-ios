//
//  WorldMenuViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/3/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroundView.h"
#import "GameManager.h"

@class Level, ThumbnailAnimator;
@protocol WorldMenuViewControllerDelegate;

@interface WorldMenuViewController : UIViewController

@property (nonatomic, strong) IBOutlet GroundView *level0View;
@property (nonatomic, weak) id<WorldMenuViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger selectedLevelIndex;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, strong) NSMutableIndexSet *completedLevelIndex;
@property (nonatomic, strong) ThumbnailAnimator *thumbnailAnimator;

- (IBAction)back:(id)sender;

@end



@protocol WorldMenuViewControllerDelegate
- (void)worldMenuDidSelectBack:(WorldMenuViewController*)controller;
- (void)worldMenu:(WorldMenuViewController*)controller didSelectLevelIndex:(NSUInteger)index;
@end