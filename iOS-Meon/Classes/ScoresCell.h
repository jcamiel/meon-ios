//
//  ScoresCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 8/20/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScoresCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *userLabel;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *indexLabel;
@property (nonatomic, assign) NSInteger index;

@end
