//
//  CMLevelViewCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 04/04/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "THLabel.h"

@interface CMLevelViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet THLabel *levelLabel;
@property (nonatomic, assign) NSInteger level;

@end
