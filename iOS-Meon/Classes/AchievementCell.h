//
//  AchievementCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 12/10/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Achievement;

@interface AchievementCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIImageView *labelImageView;
@property (nonatomic, strong) Achievement *achievement;
@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

@end
