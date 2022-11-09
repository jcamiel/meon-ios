//
//  Level.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 3/10/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "Level.h"

#import <QuartzCore/QuartzCore.h>
#import "BrickSprite.h"
#import "CGPointUtil.h"
#import "GroundView.h"
#import "LightSprite.h"
#import "MeonSprite.h"
#import "MirrorSprite.h"
#import "NSData+Base64.h"
#import "PrismSprite.h"
#import "SplitterSprite.h"
#import "Sprite.h"
#import "SpriteSheet.h"
#import "SpriteSheetManager.h"
#import "UIView+Helper.h"
#import "algorithm.h"
#import "tile.h"

NSString *const kLevelOriginalKey = @"original";
NSString *const kLevelSolutionKey = @"solution";
NSString *const kEmptyLevelString = @"AQD/BxhggAEGGGCAAf4PAO8A7wA=";


@interface Level ()

@property (nonatomic, readwrite) uint8 meonTotal;
@property (nonatomic, readwrite) uint8 meonReached;
@property (nonatomic, assign, readwrite) CGFloat levelWidthInPoint;
@property (nonatomic, assign, readwrite) CGFloat levelDeltaXInPoint;


@end

@implementation Level

#pragma mark - init / dealloc

- (id)init {
    self = [super init];
    if (self) {

        BOOL isDeviceiPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

        self.cellWidthInPoint = isDeviceiPad ? 60.0f : 30.0f;

        self.objectSprites = [[NSMutableDictionary alloc] init];
        self.lightSprites = [[NSMutableArray alloc] init];

        self.hintsSprites = [[NSMutableArray alloc] init];
        self.loaded = NO;
        self.published = NO;


    }
    return self;
}

#pragma mark - Accessor

- (uint32)tileAtCol:(int)col row:(int)row {
    if ((col < 0) || (col > 11) || (row < 0) || (row > 11)) {
        return kTilePlain;
    }
    int index = col + 12*row;
    return self.cells[index];
}

- (void)setTile:(kTileType)tile col:(int)col row:(int)row {
    int index = col + 12*row;

    // remove the
    [self deleteObjectSprite:self.cells[index] col:col row:row];

    // if it's a new object
    if (tile >= kTileGreenMeonS) {
        [self createObjectSprite:tile col:col row:row];
    }
    else {
        self.cells[index] = tile;
    }
}

- (int)firstFreeTileIndex {
    int index = 0;
    while (self.cells[index] != kTileVoid) {
        index++;
    }
    return index;
}

- (uint8 *)lights {
    return (uint8 *)_lights;
}

- (uint32 *)cells {
    return (uint32 *)_cells;
}

- (void)moveSprite:(Sprite *)sprite
            colSrc:(int)colSrc
            rowSrc:(int)rowSrc
            colDst:(int)colDst
            rowDst:(int)rowDst {
    if ((colSrc < 0) || (colSrc > 11) || (rowSrc < 0) || (rowSrc > 11) ||
        ((colSrc == colDst) && (rowSrc == rowDst))) {
        return;
    }

    int indexSrc = colSrc + 12 * rowSrc;
    int indexDst = colDst + 12 * rowDst;

    if (sprite) {
        self.objectSprites[@(indexDst)] = sprite;
    }
    else {
        DebugLog(@"Error");
    }

    [self.objectSprites removeObjectForKey:@(indexSrc)];

    self.cells[indexDst] = sprite.type;
    self.cells[indexSrc] = kTileVoid;

    [self updateLightsAndObjects];
}

- (void)setLayoutView:(GroundView *)aNewLayoutView {
    for(Sprite * sprite in [self.objectSprites allValues]) {
        sprite.superlayer = aNewLayoutView.layer;
    }
    for(Sprite * sprite in self.lightSprites) {
        sprite.superlayer = aNewLayoutView.layer;
    }
    for(Sprite * sprite in self.hintsSprites) {
        sprite.superlayer = aNewLayoutView.layer;
    }
    _layoutView = aNewLayoutView;
    if ([self.layoutView isKindOfClass:[GroundView class]]) {
        [(GroundView *)self.layoutView setTheme : self.theme];
    }
}

- (Sprite *)createSprite:(unsigned int)tile
                     col:(int)col
                     row:(int)row
              debugColor:(UIColor *)color {
    color = nil;
    Sprite * sprite = nil;
    switch (tile) {
    case kTileVoid: {
        sprite = [[LightSprite alloc] init];
        break;
    }
    case kTileGreenMeonS:
    case kTileGreenMeonW:
    case kTileGreenMeonN:
    case kTileGreenMeonE: {
        sprite = [[MeonSprite alloc] init];
        break;
    }
    case kTileRedMeon:
    case kTileYellowMeon:
    case kTileBlueMeon:
    case kTileWhiteMeon: {
        sprite = [[MeonSprite alloc] init];
        break;
    }
    case kTileBrickRed:
    case kTileBrickYellow:
    case kTileBrickBlue: {
        sprite = [[BrickSprite alloc] init];
        break;
    }
    case kTileMirror1:
    case kTileMirror2: {
        sprite = [[MirrorSprite alloc] init];
        break;
    }
    case kTileSplitterS:
    case kTileSplitterW:
    case kTileSplitterN:
    case kTileSplitterE: {
        sprite = [[SplitterSprite alloc] init];
        break;
    }
    case kTilePrismS:
    case kTilePrismW:
    case kTilePrismN:
    case kTilePrismE: {
        sprite = [[PrismSprite alloc] init];
        break;
    }
    default: {
        sprite = [[Sprite alloc] init];
    }
    break;
    }

    SpriteSheetManager *spriteSheetManager = [SpriteSheetManager sharedSpriteSheetManager];
    sprite.spriteSheet = [spriteSheetManager defaultSpriteSheet];
    sprite.center = (CGPoint){(col * self.cellWidthInPoint) + (self.cellWidthInPoint/2),
                              (row * self.cellWidthInPoint) + (self.cellWidthInPoint/2)};
    sprite.type = tile;
    sprite.light = 0;
    sprite.superlayer = self.layoutView.layer;
    if (color) {
        sprite.layer.borderColor = [color CGColor];
        sprite.layer.borderWidth = 1.0f;
    }


    return sprite;
}

- (void)createObjectSprite:(kTileType)tile col:(int)col row:(int)row {
    unsigned int key = col + 12*row;
    self.cells[ key ] = tile;

    Sprite * sprite = [self createSprite:tile col:col row:row debugColor:[UIColor redColor]];
    if ((tile >= kTileWhiteMeon) && (tile <= kTileBlueMeon)) {
        self.meonTotal++;
    }
    self.objectSprites[@((int)key)] = sprite;
}

- (void)deleteObjectSprite:(kTileType)tile col:(int)col row:(int)row {
    unsigned int key = col + 12*row;
    self.cells[ key ] = kTileVoid;

    if ((tile >= kTileWhiteMeon) && (tile <= kTileBlueMeon)) {
        self.meonTotal--;
    }

    Sprite *sprite = self.objectSprites[@((int)key)];
    sprite.superlayer = nil;

    [self.objectSprites removeObjectForKey:@((int)key)];
}

- (void)loadFromString:(NSString *)compressedStr {
    [self loadFromString:compressedStr centerView:YES createSprites:YES];
}

- (void)loadFromString:(NSString *)compressedStr
            centerView:(BOOL)centerView {
    [self loadFromString:compressedStr centerView:centerView createSprites:YES];

}

- (void)loadFromString:(NSString *)compressedStr
            centerView:(BOOL)centerView
         createSprites:(BOOL)createSprites {

    NSInteger i, row, col, nbItem, minCol = NSIntegerMax, maxCol = 0, minRow = NSIntegerMax, maxRow = 0;
    Sprite * sprite = nil;

    [self removeSprites];

    self.loaded = NO;
    self.meonReached = 0;
    self.meonTotal = 0;
    for(i = 0; i < 12*12; i++)
        self.cells[i] = kTilePlain;

    // create the moveable sprite
    self.objectSprites = [NSMutableDictionary dictionary];

    NSData * data = [NSData dataFromBase64String:compressedStr];
    uint8 * dataPtr = (uint8 *)data.bytes;
    if (!dataPtr) {return; }
    int bitLen = 8;
    int version = *dataPtr++;
    if (version == 0) {
        DebugLog(@"version 0 - no extra header");
    }
    else if (version == 1) {
        DebugLog(@"version 1 - demux extra header");
        self.theme = *dataPtr++;
    }

    unsigned int byte = *dataPtr++, bit = 0, tile = 0;

    for(row = 0; row < 10; row++) {
        for(col = 0; col < 10; col++) {
            bit = byte & 1;
            if (bitLen > 1) {
                bitLen--;
                byte = byte >>1;
            }
            else {
                byte = *dataPtr++;
                bitLen = 8;
            }
            if (!bit) {
                if (col > maxCol) {maxCol = col; }
                if (col < minCol) {minCol = col; }
                if (row > maxRow) {maxRow = row; }
                if (row < minRow) {minRow = row; }
            }

            self.cells[ (col+1) + 12*(row+1) ] = (bit != 0) ? kTilePlain : kTileVoid;
        }
    }

    // Item count
    // ---
    nbItem = *dataPtr++; //count

    // First hint
    // ---
    byte = *dataPtr++; //row+col 1st hint
    row = ((byte>>4) & 0xF)+1;
    col = (byte & 0xF) + 1;
    tile = *dataPtr++;
    if (tile) {
        sprite = [self createSprite:tile
                                col:(int)col
                                row:(int)row
                         debugColor:[UIColor greenColor]];
        sprite.hidden = YES;
        [self.hintsSprites addObject:sprite];
    }

    // Second hint
    // ---
    byte = *dataPtr++; //row+col 1st hint
    row = ((byte>>4) & 0xF)+1;
    col = (byte & 0xF) + 1;
    tile = *dataPtr++;
    if (tile) {
        sprite = [self createSprite:tile
                                col:(int)col
                                row:(int)row
                         debugColor:[UIColor greenColor]];
        sprite.hidden = YES;
        [self.hintsSprites addObject:sprite];
    }

    //
    // create sprite object
    for(i = 0; i < nbItem; i++) {

        byte = *dataPtr++;
        col = (byte & 0xF)+1;
        row = ((byte>>4) & 0xF)+1;
        tile = *dataPtr++;

        [self createObjectSprite:(kTileType)tile col:(int)col row:(int)row];
    }

    self.levelWidthInPoint = (maxCol-minCol+1) * self.cellWidthInPoint;
    self.levelDeltaXInPoint = (minCol + 1) * self.cellWidthInPoint;

    [self computeLightWay];
    [self updateLightSprites];
    [self updateObjectSpritesForceRedraw:NO];


    self.loaded = YES;

}

- (void)printCells {
    int row = 0;
    for(row = 0; row < 12; row++) {
        DebugLog(@"%d %d %d %d %d %d %d %d %d %d %d %d",
                 self.cells[0 + 12*row],
                 self.cells[1 + 12*row],
                 self.cells[2 + 12*row],
                 self.cells[3 + 12*row],
                 self.cells[4 + 12*row],
                 self.cells[5 + 12*row],
                 self.cells[6 + 12*row],
                 self.cells[7 + 12*row],
                 self.cells[8 + 12*row],
                 self.cells[9 + 12*row],
                 self.cells[10 + 12*row],
                 self.cells[11 + 12*row]);
    }
}

- (void)printLights {
    int row = 0;

    for(row = 0; row < 12; row++) {
        DebugLog(@"%d %d %d %d %d %d %d %d %d %d %d %d",
                 self.lights[0 + 12*row],
                 self.lights[1 + 12*row],
                 self.lights[2 + 12*row],
                 self.lights[3 + 12*row],
                 self.lights[4 + 12*row],
                 self.lights[5 + 12*row],
                 self.lights[6 + 12*row],
                 self.lights[7 + 12*row],
                 self.lights[8 + 12*row],
                 self.lights[9 + 12*row],
                 self.lights[10 + 12*row],
                 self.lights[11 + 12*row]);
    }
}

- (void)computeLightWay {
    int row, col;

    uint8 * currentLights = self.lights;
    memset(currentLights, 0, 12*12*sizeof(uint8));

    self.meonReached = 0;

    for(row = 0; row < 12; row++) {
        for(col = 0; col < 12; col++) {
            int32 index = col + 12*row;
            uint32 tile = self.cells[ index ];
            if ((tile >= kTileGreenMeonS) && (tile <= kTileGreenMeonE)) {
                computeLightWay(self.cells, index, tile, 1, currentLights, &_meonReached);
            }
        }
    }
}

- (BOOL)isCompleted {
    return (self.meonReached == self.meonTotal);
}

#pragma mark -
#pragma mark Sprites Managment

- (void)removeSprites {
    for(Sprite *sprite in [self.objectSprites allValues]) {
        sprite.superlayer = nil;
    }
    [self.objectSprites removeAllObjects];

    for(Sprite *sprite in self.lightSprites) {
        sprite.hidden = YES;
    }

    for(Sprite * sprite in self.hintsSprites) {
        sprite.superlayer = nil;
    }
    [self.hintsSprites removeAllObjects];
}

- (void)updateLightsAndObjects {
    [self computeLightWay];
    [self updateLightSprites];
    [self updateObjectSpritesForceRedraw:NO];

}

- (void)updateLightSprites {
    uint8 *newLights;
    uint8 newLight;
    int index = 0;
    uint32 tile;

    newLights = self.lights;

    int spriteCount = 0;
    Sprite *sprite = nil;

    for(int row = 0; row < 12; row++) {
        for(int col = 0; col < 12; col++) {
            index = col + 12*row;
            newLight = newLights[ index ];
            tile = self.cells[ index ];

            if(!newLight || (tile != kTileVoid)) {
                continue;
            }

            // if not any sprite, create a new one
            if (self.lightSprites.count <= spriteCount) {

                sprite = [self createSprite:kTileVoid
                                        col:col
                                        row:row
                                 debugColor:[UIColor redColor]];
                [self.lightSprites addObject:sprite];
            }
            else {
                sprite = self.lightSprites[spriteCount];
            }

            sprite.type = kTileVoid;
            sprite.light = newLight;
            sprite.hidden = NO;
            sprite.center = (CGPoint){(col * self.cellWidthInPoint) + (self.cellWidthInPoint/2),
                                      (row * self.cellWidthInPoint) + (self.cellWidthInPoint/2)};
            [sprite updateFrames];
            spriteCount++;
        }
    }

    //remove the unused
    for(int i = spriteCount; i < self.lightSprites.count; i++) {
        sprite = self.lightSprites[i];
        //DebugLog(@"reuse sprite %@", sprite);
        sprite.hidden = YES;
    }

    //DebugLog(@"sprite array count= %d", self.lightSprites.count);
}

- (void)updateObjectSpritesForceRedraw:(BOOL)forceRedraw {
    uint8 *newLights;
    uint8 newLight, newDirection;
    int index = 0;

    newLights = self.lights;


    NSNumber *key;
    for(key in self.objectSprites) {
        index = [key intValue];

        Sprite * sprite = self.objectSprites[key];

        if (forceRedraw) {
            sprite.direction = 0;
            sprite.light = 0;
        }

        if ((sprite.type >= kTileWhiteMeon) && (sprite.type <= kTileBlueMeon)) {
            newLight = (newLights[ index ] & 0x7);
            newDirection = newLights[ index ] >> 3;
        }
        else {
            newLight = newLights[ index ];
            newDirection = 0;
        }

        // don't play sound until level is fully
        // loaded
        sprite.soundEnabled = self.loaded;
        sprite.direction = newDirection;
        sprite.light = newLight;
        [sprite updateFrames];

    }
}

- (Sprite *)nearestSprite:(CGPoint)pt inRadius:(CGFloat)radius meonFiltered:(BOOL)filtered {
    CGFloat distMin = radius, dist;
    Sprite *spriteMin = nil;

    for(Sprite * sprite in [self.objectSprites allValues]) {
        if (!sprite.isMoveable && filtered) {
            continue;
        }
        dist = distanceBetweenTwoPoints(pt, sprite.center);
        if (dist < distMin) {
            distMin = dist;
            spriteMin = sprite;
        }
    }

    return spriteMin;
}

- (NSString *)string {
    NSMutableData *data = [NSMutableData data];
    int row, col, index, cell, count = 0;
    unsigned int bit = 0, bitLen = 0;
    unsigned char byte = 0;
    Sprite * sprite = nil;

    //version 1: extra header
    byte = 1;
    [data appendBytes:&byte length:1];

    // theme
    byte = self.theme;
    [data appendBytes:&byte length:1];

    byte = 0;
    for(row = 0; row < 10; row++) {
        for(col = 0; col < 10; col++) {
            index = (col+1) + (row+1) *12;
            cell = self.cells[index];
            if (cell == kTilePlain) {
                bit = 1;
            }
            else {
                bit = 0;
            }

            byte = (bit<<bitLen) + byte;
            bitLen++;
            if (bitLen == 8) {
                [data appendBytes:&byte length:1];
                bitLen = 0;
                byte = 0;
            }

        }
    }

    [data appendBytes:&byte length:1];

    byte = self.objectSprites.count;
    [data appendBytes:&byte length:1];

    byte = 0;

    // hint 0
    if (self.hintsSprites.count) {sprite = self.hintsSprites[0]; }
    col = ((int)(sprite.center.x / self.cellWidthInPoint))-1;
    row = ((int)(sprite.center.y / self.cellWidthInPoint))-1;
    byte = (row << 4) + col;
    [data appendBytes:&byte length:1];
    byte = sprite.type;
    [data appendBytes:&byte length:1];

    // hint 1
    if (self.hintsSprites.count > 1) {sprite = self.hintsSprites[1]; }
    col = ((int)(sprite.center.x / self.cellWidthInPoint))-1;
    row = ((int)(sprite.center.y / self.cellWidthInPoint))-1;
    byte = (row << 4) + col;
    [data appendBytes:&byte length:1];
    byte = sprite.type;
    [data appendBytes:&byte length:1];


    for(row = 0; row < 10; row++) {
        for(col = 0; col < 10; col++) {
            index = (col+1) + (row+1) *12;
            cell = self.cells[index];
            if (cell <= kTilePlain) {continue; }

            byte = ((row<<4)+col);
            [data appendBytes:&byte length:1];
            byte = cell;
            [data appendBytes:&byte length:1];
            count++;

        }
    }

    return [data base64EncodedString];
}

- (BOOL)containsUnusedTool;
{
    BOOL toolNotUsed = NO;
    for(Sprite *sprite in [self.objectSprites allValues]) {
        if (sprite.isMoveable && (sprite.type > kTileBlueMeon) && !sprite.light) {
            toolNotUsed = YES;
            break;
        }
    }
    return toolNotUsed;
}


- (void)shuffleObjects:(BOOL)updateSprites {
    int index = 0, newIndex, col, row;

    // erase all objects
    for(index = 0; index < 144; index++) {
        if ((self.cells[index] != kTilePlain) &&
            ((self.cells[index] < kTileWhiteMeon) || (self.cells[index] > kTileBlueMeon))) {
            self.cells[index] = kTileVoid;
        }
    }

    // shuffle objects
    NSMutableDictionary * newObjectSprites = [NSMutableDictionary dictionary];

    for(NSNumber *key in self.objectSprites) {

        Sprite * sprite = self.objectSprites[key];
        if ((sprite.type >= kTileWhiteMeon) && (sprite.type <= kTileBlueMeon)) {
            newIndex = [key intValue];
        }
        else {
            do {
                newIndex = rand() % 144;
            } while (self.cells[newIndex] != kTileVoid);
        }
        self.cells[newIndex] = sprite.type;
        newObjectSprites[@(newIndex)] = sprite;

        if (updateSprites) {
            col = newIndex % 12;
            row = newIndex / 12;
            sprite.center = CGPointMake((col * self.cellWidthInPoint) + (self.cellWidthInPoint/2),
                                        (row * self.cellWidthInPoint) + (self.cellWidthInPoint/2));
        }
    }

    self.objectSprites = newObjectSprites;

}

- (void)setTheme:(NSUInteger)theme {
    _theme = theme;

    if ([self.layoutView isKindOfClass:[GroundView class]]) {
        [(GroundView *)self.layoutView setTheme : theme];
    }
}

- (void)generateHintsSprites {
    for(Sprite * sprite in self.hintsSprites) {
        sprite.superlayer = nil;
    }
    [self.hintsSprites removeAllObjects];

    // count number of potential hint (all objects that are not
    // Meons
    NSMutableArray * potentialHintsSprites = [NSMutableArray array];
    for(Sprite * sprite in [self.objectSprites allValues]) {
        if ((sprite.type < kTileWhiteMeon) || (sprite.type > kTileBlueMeon)) {
            [potentialHintsSprites addObject:sprite];
        }
    }

    if (!potentialHintsSprites.count) {
        DebugLog(@"problem in object sprites, not possible to create hints");
        return;
    }
    else if (potentialHintsSprites.count == 1) {
        [self.hintsSprites addObject:potentialHintsSprites[0]];
    }
    else if (potentialHintsSprites.count == 2) {
        [self.hintsSprites addObject:potentialHintsSprites[0]];
        [self.hintsSprites addObject:potentialHintsSprites[1]];
    }
    else {
        // can be more generic now!
        Sprite * sprite0 = nil;
        Sprite * sprite1 = nil;

        do {
            NSUInteger index0 = rand() % potentialHintsSprites.count;
            NSUInteger index1 = rand() % potentialHintsSprites.count;
            sprite0 = potentialHintsSprites[index0];
            sprite1 = potentialHintsSprites[index1];
        }
        while (sprite0 == sprite1);

        [self.hintsSprites addObject:sprite0];
        [self.hintsSprites addObject:sprite1];
    }
}

- (void)empty {
    self.published = NO;
    [self loadFromString:kEmptyLevelString];
}

@end
