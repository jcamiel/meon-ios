//
//  SpriteSheetManager.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/12/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "SpriteSheetManager.h"
#import "SpriteSheet.h"

@implementation SpriteSheetManager


#pragma mark - Singleton managment

+ (instancetype)sharedSpriteSheetManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - alloc / init
- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)loadSpriteSheetNamed:(NSString*)spriteSheetName
{
    if (!self.spriteSheets){
        self.spriteSheets = [[NSMutableDictionary alloc] init];
    }
    
    if (self.spriteSheets[spriteSheetName]){
        DebugLog(@"spriteSheet named=%@ already loaded", spriteSheetName);
        return;
    }
    
    SpriteSheet *spriteSheet = [[SpriteSheet alloc] init];
    
#ifdef USE_SPRITESHEET    
    // load sprite sheet data
    NSString *spriteSheetDataFilePath = [[NSBundle mainBundle] pathForResource:spriteSheetName 
                                                                    ofType:@"plist"];
    NSDictionary *spriteSheetDataDictionary = [NSDictionary dictionaryWithContentsOfFile:
                                               spriteSheetDataFilePath];
    spriteSheet.dataSource = spriteSheetDataDictionary;
    
    // load sprite sheet image
    NSString *spriteSheetImageName = [NSString stringWithFormat:@"%@.png", spriteSheetName];
    UIImage *spriteSheetImage = [UIImage imageNamed:spriteSheetImageName];
    spriteSheet.imageSource = spriteSheetImage;
#endif
    
    // add spriteSheet to dictionary
    self.spriteSheets[spriteSheetName] = spriteSheet;
}


- (SpriteSheet*)defaultSpriteSheet
{
    NSArray *spriteSheets = [self.spriteSheets allValues];
    if (!spriteSheets.count) return nil;
    
    SpriteSheet *firstSpriteSheet = (SpriteSheet*)spriteSheets[0];
    return firstSpriteSheet;
}



@end
