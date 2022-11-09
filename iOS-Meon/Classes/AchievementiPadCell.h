//
//  AchievementiPadCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/31/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Achievement;

@interface AchievementiPadCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic, strong) IBOutlet UIImageView *labelImageView;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

- (void)setAchievement:(Achievement*)newAchievement;

@end
