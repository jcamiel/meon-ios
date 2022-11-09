//
//  AchievementViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 11/14/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AchievementViewController;
@class Achievement;

@protocol AchievementViewControllerDelegate
- (void)achievementViewControllerDidDismiss:(AchievementViewController*)controller;
@end


@interface AchievementViewController : UIViewController

@property (nonatomic, weak) id<AchievementViewControllerDelegate> delegate;
@property (nonatomic, strong) Achievement *achievement;
@property (nonatomic, strong) IBOutlet UIImageView *labelImageView;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) NSDictionary *achievementsDescription;
@end
