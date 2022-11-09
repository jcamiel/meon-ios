//
//  AchievementiPadCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/31/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//

#import "AchievementiPadCell.h"
#import "Achievement.h"
#import "UIView+Helper.h"

@implementation AchievementiPadCell


#pragma mark - dealloc



- (void)setAchievement:(Achievement*)newAchievement
{
    NSString *labelName = newAchievement.labelFileName; 
    self.labelImageView.image = [UIImage imageNamed:labelName];
    [self.labelImageView sizeToFit];
    self.labelImageView.x = 120;
    
    NSString *iconName = newAchievement.iconFileName;
	self.iconImageView.image = newAchievement.completed ?
        [UIImage imageNamed:iconName] : [UIImage imageNamed:@"Achievements/locked.png"];


}
@end
