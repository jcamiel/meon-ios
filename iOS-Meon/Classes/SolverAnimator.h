//
//  SolverAnimator.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/3/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMAnimator.h"
@class GameManager, Level;

@interface SolverAnimator : CMAnimator

@property (nonatomic, strong) Level *level;


@end
