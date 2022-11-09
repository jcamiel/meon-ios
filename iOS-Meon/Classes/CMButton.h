//
//  CMButton.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 04/01/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THLabel.h"

@interface CMButton : UIButton

@property (nonatomic, strong, readonly) THLabel *extendedLabel;

@end
