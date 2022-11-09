//
//  MirrorSprite.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/26/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "MirrorSprite.h"
#import "tile.h"
#import "UIView+Helper.h"
#import "Common.h"
#import "SpriteSheet.h"


@implementation MirrorSprite

- (void)updateFrames
{
    if (!self.isDirty) return;
    NSString *imageName = [NSString stringWithFormat:@"mirror%1d-%1d",
                           self.type-kTileMirror1+1,
                           self.light];
    
    [self.spriteSheet updateSprite:self forKey:imageName frameCount:self.framesCount];

    self.dirty = NO;
}


@end
