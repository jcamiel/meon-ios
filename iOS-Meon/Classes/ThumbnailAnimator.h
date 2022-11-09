//
//  ThumbnailAnimator.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CMAnimator.h"

@interface ThumbnailAnimator : CMAnimator

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, assign) CGRect thumbnailFrameFrom;
@property (nonatomic, assign) CGRect thumbnailFrameTo;
@property (nonatomic, strong) CALayer *thumbnailLayer;
@property (nonatomic, strong) CALayer *backgroundLayer;

@end
