//
//  AchievementsViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 12/9/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalViewController.h"

@protocol AchievementsViewControllerDelegate;
@class GameManager, AchievementCell;

@interface AchievementsViewController : ModalViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<AchievementsViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, strong) NSArray *achievements;
@property (nonatomic, weak) IBOutlet AchievementCell *genericCell;
@property (nonatomic, strong) UIFont *cellFont;
@property (nonatomic, strong) NSDictionary *achievementsDescription;

@end



@protocol AchievementsViewControllerDelegate
- (void)achievementsDidSelectBack:(AchievementsViewController*)controller;
@end