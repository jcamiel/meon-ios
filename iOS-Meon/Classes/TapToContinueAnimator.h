//
//  TapToContinueAnimator.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAnimator.h"

@interface TapToContinueAnimator : CMAnimator

@property (nonatomic, strong) CALayer *clickToContinueLayer;
@property (nonatomic, assign) CGFloat marginBottom;

@end
