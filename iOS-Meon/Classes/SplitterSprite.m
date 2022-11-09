//
//  SplitterSprite.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/24/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "SplitterSprite.h"
#import "tile.h"
#import "Common.h"
#import "SpriteSheet.h"


@implementation SplitterSprite

- (void)updateFrames
{
    if (!self.isDirty) return;
    
    uint32_t color = self.light >= 5 ? self.light / 5 : self.light; 
    NSString *imageName = nil;
	switch (self.type) {
		case kTileSplitterS:
			imageName = [NSString stringWithFormat:@"splitterS-%d", color];
			break;
		case kTileSplitterW:
			imageName = [NSString stringWithFormat:@"splitterW-%d", color];
			break;
		case kTileSplitterN:
			imageName = [NSString stringWithFormat:@"splitterN-%d", color];
			break;
		case kTileSplitterE:
			imageName = [NSString stringWithFormat:@"splitterE-%d", color];
			break;
	}
    [self.spriteSheet updateSprite:self forKey:imageName frameCount:self.framesCount];
        
    self.dirty = NO;
}

@end
