//
//  SolverAnimator.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/3/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "CMAnimator.h"
#import "SolverAnimator.h"
#import "Common.h"
#import "CMType.h"
#import "GameManager.h"
#import "NSData+Base64.h"
#import "tile.h"
#import "Sprite.h"
#import <QuartzCore/QuartzCore.h>
#import "Level.h"

@interface SolverAnimator ()

@property (nonatomic, assign) int animationsCount;

@end

@implementation SolverAnimator

- (void)start
{
	[super start];
	
	uint8 *lights = self.level.lights;
	uint32 *cells = self.level.cells;
    CGFloat cellWidth = self.level.cellWidthInPoint;
	
	int i=0, colSrc=0, rowSrc=0, colDst=0, rowDst=0,maxCol, minCol, maxRow, minRow, nbItem;
	int row, col, indexSrc, indexDst;
	
	// get the solutions
	NSString *compressedStr = self.level.solutionString;
	
	
	NSData* data= [NSData dataFromBase64String:compressedStr];
	uint8* dataPtr = (uint8*)data.bytes;
	if (!dataPtr) return;
	
	int bitLen = 8;
	int version = *dataPtr++;
    int theme = 0;
    if (version == 0){
        DebugLog(@"version 0 - no extra header");
    }
    else if (version == 1){
        theme = *dataPtr++;
    }
	
	// hide the lights
	memset(lights, 0, 12*12*sizeof(uint8));
	[self.level updateLightSprites];
	[self.level updateObjectSpritesForceRedraw:YES];
	
	for(i=0; i < 12*12; i++)
		cells[i] = kTilePlain;
	
	unsigned int byte=*dataPtr++, bit=0, tile=0;
	
	for(row=0; row < 10; row++){
		for(col=0; col < 10; col++){
			bit = byte & 1;
			if (bitLen > 1){
				bitLen--;
				byte = byte >>1;
			}
			else{
				byte = *dataPtr++;
				bitLen = 8;
			}
			if (!bit){
				if (col > maxCol) maxCol = col;
				if (col < minCol) minCol = col;
				if (row > maxRow) maxRow = row;
				if (row < minRow) minRow = row; 
			}
			cells[ (col+1) + 12*(row+1) ] = (bit!=0) ? kTilePlain : kTileVoid;
		}
	}
	
	// Item count
	// ---
	nbItem = *dataPtr++; //count
	dataPtr += 4; // hints
	
	self.animationsCount = 0;
	
	// copy the object sprites dictionnary
	NSMutableDictionary* oldObjectSprites = self.level.objectSprites;
	NSMutableDictionary* newObjectSprites = [NSMutableDictionary dictionary];
	
	//
	// create sprite object
	for(i=0; i < nbItem; i++){
		
		byte = *dataPtr++;
		colDst = (byte & 0xF)+1;
		rowDst = ((byte>>4) & 0xF)+1;
		tile = *dataPtr++;
		indexDst = colDst + 12 * rowDst;
		cells[indexDst] = tile;
		
		// get this object
		Sprite* theSprite;
		for(Sprite* sprite in [oldObjectSprites allValues]){
			if (sprite.type == tile){
				theSprite = sprite;
				break;
			}
		}
		
		// get old position
		colSrc = (int)(theSprite.center.x / cellWidth);
		rowSrc = (int)(theSprite.center.y / cellWidth);
		indexSrc = colSrc + 12 * rowSrc;

		// add this object to the new directory and remove it from the old one
		[oldObjectSprites removeObjectForKey:@(indexSrc)];
		newObjectSprites[@(indexDst)] = theSprite;
		
		if (!theSprite.moveable){
			theSprite.center = (CGPoint){(colDst * cellWidth) + (cellWidth/2), 
                                        (rowDst * cellWidth) + (cellWidth/2)};
			continue;
		} 		
		
		
		// add animations and update gameManager
		if (indexSrc != indexDst){
			CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
			moveAnimation.fromValue = [NSValue valueWithCGPoint:theSprite.center];
			theSprite.center = (CGPoint){(colDst * cellWidth) + (cellWidth/2), 
                (rowDst * cellWidth) + (cellWidth/2)};
            
			moveAnimation.toValue = [NSValue valueWithCGPoint:theSprite.center];
			moveAnimation.delegate = self;
			self.animationsCount++;
			[theSprite.layer addAnimation:moveAnimation forKey:@"position"];
			
		}
	}
	
	// set the new object directory
	self.level.objectSprites = newObjectSprites;
	
	// no animation, redraw the canvas
	if (!self.animationsCount){
        [self.level updateLightsAndObjects];
        [self stop];
	}
	

}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	self.animationsCount--;

	if (!self.animationsCount){
        [self.level updateLightsAndObjects];
		[self stop];
	}
}


@end
