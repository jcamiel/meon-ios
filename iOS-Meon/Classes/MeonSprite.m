//
//  MeonSprite.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/31/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MeonSprite.h"
#import "tile.h"
#import "Common.h"
#include "UIView+Helper.h"
#import "SimpleAudioEngine.h"
#import "SpriteSheet.h"


@implementation MeonSprite

#pragma mark - init / dealloc

-(instancetype)init
{
    self = [super init];
    if (self){
        self.layer.zPosition = 1.0f;
        self.layer.opaque = YES;
        self.soundEnabled = NO;
    }
    return self;
}



- (void)updateFrames
{
    if (!self.dirty) return;
    uint32_t color = (self.light >= 5) ? self.light / 5 : self.light; 
    
	// update the image frame
    NSString *spriteBaseName = (self.type >= kTileGreenMeonS) && (self.type <= kTileGreenMeonE) ?
        [NSString stringWithFormat:@"meon%d-0-0",self.type - kTileGreenMeonS] :
        [NSString stringWithFormat:@"meon%d-%d-%d",self.type - kTileGreenMeonS,color,self.direction];
    
    [self.spriteSheet updateSprite:self forKey:spriteBaseName frameCount:self.framesCount];

    // play sound
    if (self.soundEnabled && color && (self.type >= kTileWhiteMeon)) {
        //1=white, 2=red, 3=yellow, 4=blue
        BOOL goodLight = ((self.type == kTileWhiteMeon) && (color==1) ) ||
            ((self.type == kTileRedMeon) && (color==2) ) ||
            ((self.type == kTileYellowMeon) && (color==3) ) ||
            ((self.type == kTileBlueMeon) && (color==4) );
        
        NSString *effectName = (goodLight == YES) ? 
            [NSString stringWithFormat:@"Sounds/happy%d.caf", color] : @"Sounds/sad.caf";
        [[SimpleAudioEngine sharedEngine] playEffect:effectName];
    }
    
    self.dirty = NO;
    
}


- (void)setType:(unsigned int)type
{
    [super setType:type];
    self.moveable = (self.type >= kTileGreenMeonS) && (self.type <= kTileGreenMeonE);
    self.dirty = YES;
}


- (NSUInteger)framesCount
{
     uint32_t color = self.light >= 5 ? self.light / 5 : self.light; 

    BOOL isiPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

    if ((isiPad && ([[UIScreen mainScreen] scale] > 1)) ||
        ([[UIScreen mainScreen] scale] > 2)){
        return 1;
    }
    else {
         // color color of the light 1=white, 2=red, 3=yellow, 4=blue
        if (self.type == kTileWhiteMeon){
            if ((color != 0) && (color != 1))
                return 4;
            else {
                return 1;
            }
        }
        else if (self.type == kTileBlueMeon){
            if ((color != 0) && (color != 4))
                return 4;
            else {
                return 1;
            }
        }
        else if (self.type == kTileYellowMeon){
            if ((color != 0) && (color != 3))
                return 4;
            else {
                return 1;
            }
        }
        else if (self.type == kTileRedMeon){
            if ((color != 0) && (color != 2))
                return 4;
            else {
                return 1;
            }
        }
    }
    return 1;
}



@end
