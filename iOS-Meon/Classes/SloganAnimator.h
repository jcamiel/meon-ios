//
//  SloganAnimator.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAnimator.h"

@interface SloganAnimator : CMAnimator

@property (nonatomic, strong) CALayer *sloganLayer;
@property (nonatomic, assign) BOOL isUsingSuperSuperLayerWidth;


@end
