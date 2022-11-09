//
//  CMAnimator.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/7/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMAnimator : NSObject

@property (nonatomic, weak) CALayer *superLayer;
@property (nonatomic, assign, getter=isRunning) BOOL running;

- (void)start;
- (void)stop;
- (void)setAnimatorDidStopSelector:(SEL)selector withDelegate:(id)delagate;
- (void)setAnimatorDidStartSelector:(SEL)selector withDelegate:(id)delegate;
+ (id)animator;


@end

