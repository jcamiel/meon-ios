//
//  CMLevelViewCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 04/04/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import "CMLevelViewCell.h"

#import "THLabel.h"
#import "UIColor+Helper.h"

@interface CMLevelViewCell ()

@property (nonatomic, copy) NSArray *textColors;
@property (nonatomic, copy) NSArray *strokeColors;

@end

@implementation CMLevelViewCell

- (void)awakeFromNib {
    self.levelLabel.font = [UIFont fontWithName:@"BradyBunchRemastered" size:38];
    self.levelLabel.strokeSize = 2;
    self.levelLabel.letterSpacing = 1.8;
    self.textColors = @[
        [UIColor colorWithHexCode:0x00ffff],
        [UIColor colorWithHexCode:0x81ef51],
        [UIColor colorWithHexCode:0xff30f7],
        [UIColor colorWithHexCode:0xffa600],
        [UIColor colorWithHexCode:0xff554a],
    ];
    self.strokeColors = @[
        [UIColor colorWithHexCode:0x0600ff],
        [UIColor colorWithHexCode:0x006400],
        [UIColor colorWithHexCode:0x6b247b],
        [UIColor colorWithHexCode:0xff0000],
        [UIColor colorWithHexCode:0x9e2831],
    ];
}


- (void)setLevel:(NSInteger)level {
    _level = level;
    self.levelLabel.text = [NSString stringWithFormat:@"%ld", _level];

    NSInteger index = (level / 10 ) % 5;
    self.levelLabel.textColor = self.textColors[index];
    self.levelLabel.strokeColor = self.strokeColors[index];
}


- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];

    self.contentView.layer.opacity = (highlighted) ? 0.5 : 1;
}


@end
