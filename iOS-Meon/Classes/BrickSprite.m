//
//  BrickSprite.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/13/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "BrickSprite.h"
#import "SpriteSheet.h"
#import "tile.h"


@implementation BrickSprite

- (void)updateFrames {
    if (!self.isDirty) {
        return;
    }

    NSString *imageName = nil;
    int ligthId = (self.light > 0) ? 1 : 0;

    switch (self.type) {
    case kTileBrickRed:
    case kTileBrickYellow:
    case kTileBrickBlue: {
        imageName = [NSString stringWithFormat:@"brick%1d-%d",
                     (self.type - kTileBrickRed), ligthId];
        break;
    }
    default:
        break;
    }

    [self.spriteSheet updateSprite:self
                            forKey:imageName
                        frameCount:self.framesCount];


    self.dirty = NO;
}

@end
