//
//  AchievementCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 12/10/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "AchievementCell.h"
#import "Achievement.h"

@implementation AchievementCell

#pragma mark - init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


#pragma mark - dealloc



- (void)setAchievement:(Achievement*)newAchievement
{
	_achievement = newAchievement;
	self.labelImageView.image = [UIImage imageNamed:_achievement.labelFileName];
	
    self.iconImageView.image = newAchievement.completed ?
        [UIImage imageNamed:self.achievement.iconFileName] :
        [UIImage imageNamed:@"Achievements/locked.png"];
}



@end
