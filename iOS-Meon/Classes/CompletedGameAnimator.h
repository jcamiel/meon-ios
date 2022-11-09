//
//  CompletedGameAnimator.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/20/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "CMAnimator.h"

@interface CompletedGameAnimator : CMAnimator

@property (nonatomic, strong) UIView *groundView;
@property (nonatomic, copy) NSArray *buttons;
@end
