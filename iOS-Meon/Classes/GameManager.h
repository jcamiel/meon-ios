//
//  GameManager.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "CMType.h"
#import "GameCenterManager.h"
#import "tile.h"
#import <Foundation/Foundation.h>
@class Sprite, BoardStore, SolverAnimator, Level;

typedef enum  {
    kGameModeClassic = 0,
    kGameModeTimeAttackFlash = 1,
    kGameModeTimeAttackMedium = 2,
    kGameModeTimeAttackMarathon = 3,
    kGameModeWorld = 4,
    kGameModeEditor = 5
} GameMode;

NSString *const GameManagerUpdateAchievements;
NSString *const GameManagerNewLevelFromiCloud;

#define kEffectsVolume 1.0f
#define kBackgroundMusicVolume 1.0f

@interface GameManager : NSObject

@property (nonatomic, strong) NSArray *tutorialItems;
@property (nonatomic, strong) Level *currentLevel;
@property (nonatomic, assign) NSInteger levelsWithoutHintCount;
@property (nonatomic, strong) BoardStore *boardStore;
@property (nonatomic, strong) NSMutableDictionary *sessions;
@property (nonatomic, assign) NSUInteger level;
@property (nonatomic, assign) NSUInteger levelMaximum;
@property (nonatomic, assign) NSUInteger levelMaximumiCloud;
@property (nonatomic, readonly) NSUInteger levelLimit;
@property (nonatomic, assign) GameMode mode;
@property (nonatomic, assign) NSUInteger counter;
@property (nonatomic, assign) NSUInteger tutorialPageIndex;
@property (nonatomic, assign) NSUInteger tutorialSectionIndex;
@property (nonatomic, copy) NSString *currentViewController;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) GameCenterManager *gameCenterManager;
@property (weak, nonatomic, readonly) NSString *gameBundleId;
@property (nonatomic, readonly) NSInteger score;
@property (weak, nonatomic, readonly) NSURL *buyURL;
@property (weak, nonatomic, readonly) NSURL *reviewsURL;
@property (nonatomic, assign) BOOL hasAudioBeenInitialized;
@property (nonatomic, assign) BOOL enableiCloudSynchronisation;


- (void)loadLevel;
- (NSUInteger)numberOfSectionForTutorial;
- (NSUInteger)numberOfPageInSectionForTutorial:(NSInteger)section;
- (void)serialize;
- (void)unserialize;
+ (NSString *)stringFromGameMode:(GameMode)mode;
+ (GameMode)gameModeFromString:(NSString *)modeStr;
- (void)setSavedLevel:(NSUInteger)level;
- (void)resetCounter;
- (void)didSolveNewLevel:(NSUInteger)level;
- (NSUInteger)levelMaximumForGameMode:(GameMode)aMode;
- (NSString *)musicPathForControllerName:(NSString *)controllerName;
- (NSString *)tutorialTextAtSection:(NSInteger)section page:(NSInteger)page;
- (NSArray *)highlightedTextsAtSection:(NSInteger)section page:(NSInteger)page;
- (NSString *)appStoreURLString;




@end
