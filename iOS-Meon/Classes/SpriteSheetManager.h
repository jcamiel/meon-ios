//
//  SpriteSheetManager.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/12/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpriteSheet;

@interface SpriteSheetManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *spriteSheets;

+ (instancetype)sharedSpriteSheetManager;

- (void)loadSpriteSheetNamed:(NSString*)name;
- (SpriteSheet*)defaultSpriteSheet;

@end
