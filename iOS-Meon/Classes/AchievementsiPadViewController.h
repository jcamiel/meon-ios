//
//  AchievementsiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/31/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModaliPadViewController.h"

@class AchievementiPadCell;

@interface AchievementsiPadViewController : ModaliPadViewController<UITableViewDelegate, 
                                                            UITableViewDataSource>

@property (nonatomic, weak) IBOutlet AchievementiPadCell *genericCell;
@property (nonatomic, strong) NSArray *achievements;
@property (nonatomic, strong) UIFont *cellFont;
@property (nonatomic, strong) NSDictionary *achievementsDescription;

@end

