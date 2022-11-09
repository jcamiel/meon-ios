//
//  CMButton+Meon.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/01/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import "CMButton+Meon.h"

#import "UIColor+Helper.h"

@implementation CMButton (Meon)

+ (CMButton *)buttonWithStyle:(CMButtonMeonStyle)style {

    CMButton *button = [[CMButton alloc] init];
    [button applyStyle:style];
    return button;
}


- (void)applyStyle:(CMButtonMeonStyle)style {
    self.extendedLabel.font = [UIFont fontWithName:@"BradyBunchRemastered" size:30];
    self.extendedLabel.textColor = [UIColor colorWithHexCode:0x00ffff];
    self.extendedLabel.strokeSize = 3;
    self.extendedLabel.strokeColor = [UIColor colorWithHexCode:0x0600ff];
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 4, 0);
    
    if (style != CMButtonMeonStyleNoBackground) {
        UIImage *image = [UIImage imageNamed:@"ButtonBackgroundOff"];
        [self setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    [self invalidateIntrinsicContentSize];
}


@end
