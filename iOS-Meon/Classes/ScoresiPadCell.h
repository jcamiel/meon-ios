//
//  ScoresiPadCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/29/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoresiPadCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *indexLabel;
@property (nonatomic, assign) NSInteger index;


@end
