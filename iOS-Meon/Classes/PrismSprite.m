//
//  PrismSprite.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/12/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "PrismSprite.h"
#import "tile.h"
#import "SpriteSheet.h"


@implementation PrismSprite

- (void)updateFrames
{
    if (!self.isDirty) return;
    NSString *imageName = nil;
    
    int ligthId = (self.light > 0) ? 1 : 0;
    switch (self.type) {
        case kTilePrismS:
            imageName = [NSString stringWithFormat:@"prismS-%d", ligthId];
            break;
        case kTilePrismE:
            imageName = [NSString stringWithFormat:@"prismE-%d", ligthId];
            break;
        case kTilePrismW:
            imageName = [NSString stringWithFormat:@"prismW-%d", ligthId];
            break;
        case kTilePrismN:
            imageName = [NSString stringWithFormat:@"prismN-%d", ligthId];
            break;
        default:
            break;
    }
    [self.spriteSheet updateSprite:self forKey:imageName frameCount:self.framesCount];

    
    self.dirty = NO;
}


@end
