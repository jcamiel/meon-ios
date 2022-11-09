//
//  LightSprite.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/13/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "LightSprite.h"
#import "SpriteSheet.h"
#import <QuartzCore/QuartzCore.h>

@implementation LightSprite

- (id)init
{
    self = [super init];
    if (self){
        self.layer.opaque = YES;
    }
    return self;
}

- (void)updateFrames
{
    if (!self.isDirty) return;
    
    NSString* imageName = nil;
    if (self.light){
        imageName = [NSString stringWithFormat:@"laser%d",self.light];
    }
    
    [self.spriteSheet updateSprite:self forKey:imageName frameCount:self.framesCount];
    
    self.dirty = NO;
}
@end
