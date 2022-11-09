//
//  Level.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 3/10/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMType.h"
#import "Sprite.h"
#import "tile.h"

NSString *const kLevelOriginalKey;
NSString *const kLevelSolutionKey;
NSString *const kEmptyLevelString;


@class GroundView;

@interface Level : NSObject {
    @private
	uint32 _cells[12*12];
	uint8 _lights[12*12];
}

@property (nonatomic, assign, getter=isLoaded) BOOL loaded;
@property (nonatomic, assign) NSUInteger theme;
@property (nonatomic, readonly) uint32 *cells;
@property (nonatomic, readonly) uint8 *lights;
@property (nonatomic, strong) NSMutableDictionary *objectSprites;
@property (nonatomic, strong) NSMutableArray *lightSprites;
@property (nonatomic, strong) NSMutableArray *hintsSprites;
@property (nonatomic, strong) UIView *layoutView;
@property (nonatomic, readonly) uint8 meonTotal;
@property (nonatomic, readonly) uint8 meonReached;
@property (nonatomic, copy) NSString *originalString;
@property (nonatomic, copy) NSString *solutionString;
@property (nonatomic, assign, getter=isPublished) BOOL published;
@property (nonatomic, assign) CGFloat cellWidthInPoint;
@property (nonatomic, assign, readonly) CGFloat levelWidthInPoint;
@property (nonatomic, assign, readonly) CGFloat levelDeltaXInPoint;


- (BOOL)containsUnusedTool;
- (Sprite*)nearestSprite:(CGPoint)pt inRadius:(CGFloat)radius meonFiltered:(BOOL)filtered;
- (uint32)tileAtCol:(int)col row:(int)row;
- (void)setTile:(kTileType)tile col:(int)col row:(int)row;
- (void)removeSprites;
- (void)updateLightSprites;
- (void)updateObjectSpritesForceRedraw:(BOOL)forceRedraw;
- (void)computeLightWay;
- (void)moveSprite:(Sprite*)sprite colSrc:(int)colSrc rowSrc:(int)rowSrc colDst:(int)colDst rowDst:(int)rowDst;
- (BOOL)isCompleted;
- (NSString*)string;
- (void)loadFromString:(NSString*)compressedStr;
- (void)loadFromString:(NSString*)compressedStr centerView:(BOOL)centerView;
- (void)loadFromString:(NSString*)compressedStr centerView:(BOOL)centerView createSprites:(BOOL) createSprites;
- (int)firstFreeTileIndex;
- (void)createObjectSprite:(kTileType)tile col:(int)col row:(int)row;
- (void)deleteObjectSprite:(kTileType)tile col:(int)col row:(int)row;
- (void)shuffleObjects:(BOOL)updateSprites;
- (void)printCells;
- (void)printLights;
- (void)updateLightsAndObjects;
- (void)generateHintsSprites;
- (void)empty;



@end

