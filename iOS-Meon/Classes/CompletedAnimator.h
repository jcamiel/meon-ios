//
//  CompletedAnimator.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/8/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAnimator.h"

@interface CompletedAnimator : CMAnimator 

@property (nonatomic, strong) UIView *groundView;
@property (nonatomic, strong) UIView *counterView;
@property (nonatomic, strong) UIImage *sloganImage;
@property (nonatomic, strong) CALayer *sloganLayer;
@property (nonatomic, assign) CGFloat ySlogan;
@property (nonatomic, assign) CGPoint counterViewPositionTo;
    

    
@end
