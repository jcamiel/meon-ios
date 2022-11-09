//
//  CMButton+Meon.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/01/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import "CMButton.h"

typedef NS_ENUM(NSUInteger, CMButtonMeonStyle) {
    CMButtonMeonStyleNormal,
    CMButtonMeonStyleNoBackground,
};


@interface CMButton (Meon)

+ (CMButton *)buttonWithStyle:(CMButtonMeonStyle)style;
- (void)applyStyle:(CMButtonMeonStyle)style;
    
@end
