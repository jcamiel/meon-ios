//
//  GameManager.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "GameManager.h"

#import <QuartzCore/QuartzCore.h>

#import "Achievement.h"
#import "BoardStore.h"
#import "Common.h"
#import "Level.h"
#import "LevelManager.h"
#import "SimpleAudioEngine.h"
#import "SpritesheetManager.h"
#import "UIDevice+Helper.h"
#import "algorithm.h"
#import "tile.h"


NSString *const GameManagerUpdateAchievements = @"GameManagerUpdateAchievements";
NSString *const GameManagerNewLevelFromiCloud = @"GameManagerNewLevelFromiCloud";

@interface GameManager ()

@property (nonatomic, readwrite) NSUInteger levelLimit;

@end


@implementation GameManager


#pragma mark - init / dealloc

- (id)init {
    self = [super init];
    if (self) {

        srand((unsigned)time(NULL));
        _enableiCloudSynchronisation = YES;

        if (_enableiCloudSynchronisation) {
            [self registerToiCloud];
        }

        // Initialize Audio engine.
        [self setupAudioEngine];

        // Restore state from disk.
        [self unserialize];

        // Initialize graphics and load sprite sheet.
        SpriteSheetManager *spriteSheetManager = [SpriteSheetManager sharedSpriteSheetManager];
        [spriteSheetManager loadSpriteSheetNamed:@"default"];


        // GameCenter Manager.
        _gameCenterManager = [[GameCenterManager alloc] initWithGameManager:self];
        _gameCenterManager.gameKitIdentifierPrefix = [NSString stringWithFormat:@"%@.", self.gameBundleId];

        // Score store.
        _boardStore = [[BoardStore alloc] initWithBoardNames:
                        @"timeattack.flash",
                        @"timeattack.medium",
                        @"timeattack.marathon", nil];
        _boardStore.gameCenterManager = _gameCenterManager;

        // Tutorial resources.
        NSString *path = [[NSBundle mainBundle] pathForResource:@"tutorial" ofType:@"plist"];
        NSDictionary *tutorialDictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        self.tutorialItems = tutorialDictionary[@"items"];


        // Level management.
        _currentLevel = [[Level alloc] init];

        LevelManager * levelManager = [LevelManager sharedLevelManager];
        [levelManager loadClassicLevels];
    }
    return self;
}


- (void)dealloc {
    [self serialize];
}


- (NSString *)gameBundleId {
#if defined(LITE)
    return @"com.manbolo.meonlite";
#else
    return @"com.manbolo.meon";
#endif
}


- (NSString *)appStoreURLString {
#if defined(LITE)
    return @"http://itunes.apple.com/app/meon/id402357587?mt=8";
#else
    return @"http://itunes.apple.com/app/meon/id400274934?mt=8";
#endif
}


- (NSURL *)buyURL {
    return [NSURL URLWithString:@"http://itunes.apple.com/app/meon/id400274934?mt=8"];
}


- (NSURL *)reviewsURL {
    // On iOS 7 and later, review URL doesn't work any more.
    // Use App Store URL instead as a workaround.
    if ([[UIDevice currentDevice] isSystemVersionGreaterOrEqualThan:@"7.0"]) {
        NSString *urlReview = [self appStoreURLString];
        return [NSURL URLWithString:urlReview];
    }
    else {
#if defined(LITE)
        NSString *urlReview = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=402357587";
#else
        NSString *urlReview = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=400274934";
#endif
        return [NSURL URLWithString:urlReview];
    }
}


- (NSString *)musicPathForControllerName:(NSString *)controllerName {
    if (!controllerName) {
        return nil;
    }

    NSString *universalName = [controllerName stringByReplacingOccurrencesOfString:@"iPad"
                                                                        withString:@""];
    if ([universalName isEqualToString:@"MainMenu"] ||
        [universalName isEqualToString:@"Options"] ||
        [universalName isEqualToString:@"TimeAttack"] ||
        [universalName isEqualToString:@"Scores"] ||
        [universalName isEqualToString:@"Achievements"]) {
        return @"Sounds/intro2_long.caf";
    }
    else if ([universalName isEqualToString:@"BuyGame"] ||
             [universalName isEqualToString:@"Congratulation"]) {
        return @"Sounds/blue.caf";
    }
    else if ([universalName isEqualToString:@"Play"] ||
             [universalName isEqualToString:@"Solver"]) {
        int index = ((self.level / 10) % 5);
        switch (index) {
            case 0:
                return @"Sounds/blue.caf";
                break;
            case 1:
                return @"Sounds/green.caf";
                break;
            case 2:
                return @"Sounds/violet.caf";
                break;
            case 3:
                return @"Sounds/orange.caf";
                break;
            case 4:
                return @"Sounds/corail.caf";
                break;
            default:
                return nil;
                break;
        }
    }
    else {
        DebugLog(@"WARNING: no music for controller name=%@", controllerName);
        return nil;
    }
}


- (void)loadLevel {
    NSString *compressedStr = nil;
    NSString *modeStr = [GameManager stringFromGameMode:self.mode];
    NSString *savedLevel = _sessions[modeStr][@"savedLevel"];
    NSMutableArray * levels = nil;
    NSUInteger level = self.level;

    if (_mode == kGameModeWorld) {
        levels = [[LevelManager sharedLevelManager] worldLevels];
        // TODO: change this
        savedLevel = nil;
    }
    else if (_mode == kGameModeEditor) {
        levels = [[LevelManager sharedLevelManager] editorLevels];
    }
    else {
        levels = [[LevelManager sharedLevelManager] classicLevels];
    }
    if (level >= levels.count) {
        DebugLog(@"Error in level: too much level asked");
        return;
    }

    NSDictionary *dic = levels[level];
    if (!dic || [dic isKindOfClass:[NSNull class]]) {
        DebugLog(@"Error: level %lu in game mode %@ is null", level,
                 [GameManager stringFromGameMode:self.mode]);
        return;
    }

    NSString *solution = dic[kLevelSolutionKey];
    NSString *original = dic[kLevelOriginalKey];

    compressedStr = (savedLevel != nil) ? savedLevel : original;
    _currentLevel.originalString = original;
    _currentLevel.solutionString = solution;
    _currentLevel.theme = ((level / 10) % 5);
    [_currentLevel loadFromString:compressedStr];

    // update tutorial
    _tutorialSectionIndex = (level < [self numberOfSectionForTutorial]) ?
                            level :[self numberOfSectionForTutorial] - 1;
    _tutorialPageIndex = 0;

    [_sessions[modeStr] removeObjectForKey:@"savedLevel"];
}


- (void)setMode:(GameMode)newMode {
    _mode = newMode;
    _counter = 0;
}


#pragma mark - Tutorial
- (NSUInteger)numberOfSectionForTutorial {
    return _tutorialItems.count;
}


- (NSUInteger)numberOfPageInSectionForTutorial:(NSInteger)section {
    NSArray *item = _tutorialItems[section];
    return item.count;
}


- (NSString *)tutorialTextAtSection:(NSInteger)section page:(NSInteger)page {
    NSString *text = nil;
    NSArray *item = _tutorialItems[section];
    if (page < item.count) {
        NSDictionary *tutorialDictionary = item[page];
        text = tutorialDictionary[@"text"];
    }
    return text;
}


- (NSArray *)highlightedTextsAtSection:(NSInteger)section page:(NSInteger)page {
    NSArray *highlights = nil;
    NSArray *item = _tutorialItems[section];
    if (page < item.count) {
        NSDictionary *tutorialDictionary = item[page];
        highlights = tutorialDictionary[@"highlights"];
    }
    return highlights;
}


#pragma mark - serialize / unserialize

- (void)serialize {
    //
    // What is serialize
    // Key / Value
    // "mode" : "classic"
    // "classic.level" : 2                => current level
    // "classic.levelMaximum" : 3         => maximum level reached
    // "classic.savedLevel" : "GVHG..."   => string of saved level
    // "currentViewController" : "Play"   => current view controller type
    // "userName" : "Jicea"               => user name in Time Attack
    // "counter" : 45                     => Time Attack counter
    // "levelsWithoutHintCount" : 3       => continuous level without hont

    NSMutableDictionary * session = nil;

    // game data
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * gameModeName = [GameManager stringFromGameMode:_mode];

    session = _sessions[gameModeName];

    [userDefaults setObject:gameModeName forKey:@"mode"];

    [userDefaults setObject:session[@"level"]
                     forKey:[NSString stringWithFormat:@"%@.level", gameModeName]];

    [userDefaults setObject:session[@"levelMaximum"]
                     forKey:[NSString stringWithFormat:@"%@.levelMaximum", gameModeName]];

    if (_currentLevel.isLoaded) {
        NSString *cells = [_currentLevel string];
        [userDefaults setObject:cells forKey:[NSString stringWithFormat:@"%@.savedLevel", gameModeName]];
    }
    else {
        [userDefaults removeObjectForKey:[NSString stringWithFormat:@"%@.savedLevel", gameModeName]];
    }


    [userDefaults setObject:_currentViewController forKey:@"currentViewController"];

    if (_userName) {
        [userDefaults setObject:_userName forKey:@"userName"];
    }

    [userDefaults setInteger:self.counter forKey:@"counter"];
    [userDefaults setInteger:self.levelsWithoutHintCount forKey:@"levelsWithoutHintCount"];
    [userDefaults synchronize];
}


- (void)unserialize {
    NSMutableDictionary *dictionary = nil;

    // set the defaults value
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    [userDefaults registerDefaults:
     @{@"mode": @"classic",
       @"userName": @"",
       @"counter": @0,
       @"classic.level": @0,
       @"classic.levelMaximum": @120,
       @"editor.level": @0,
       @"editor.levelMaximum": @0,
       @"world.level": @0,
       @"world.levelMaximum": @8,
       @"timeattack.flash.level": @0,
       @"timeattack.flash.levelMaximum": @0,
       @"timeattack.medium.level": @0,
       @"timeattack.medium.levelMaximum": @0,
       @"timeattack.marathon.level": @0,
       @"timeattack.marathon.levelMaximum": @0,
       @"numberOfHints": @2,
       @"currentViewController": @"MainMenu",
       @"enabledSound": @YES,
       @"enabledMusic": @YES,
       @"pauseBetweenLevels": @NO,
       @"enabledParallaxEffect": @YES,
       @"levelForRating": @15}];


    self.sessions = [NSMutableDictionary dictionary];

    dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  [userDefaults objectForKey:@"classic.level"], @"level",
                  [userDefaults objectForKey:@"classic.levelMaximum"], @"levelMaximum",
                  [userDefaults objectForKey:@"classic.savedLevel"], @"savedLevel",
                  nil];
    _sessions[@"classic"] = dictionary;

    dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  [userDefaults objectForKey:@"world.level"], @"level",
                  [userDefaults objectForKey:@"world.savedLevel"], @"savedLevel",
                  nil];
    _sessions[@"world"] = dictionary;


    dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  [userDefaults objectForKey:@"timeattack.flash.level"], @"level",
                  [userDefaults objectForKey:@"timeattack.flash.levelMaximum"], @"levelMaximum",
                  nil];
    _sessions[@"timeattack.flash"] = dictionary;

    dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  [userDefaults objectForKey:@"timeattack.medium.level"], @"level",
                  [userDefaults objectForKey:@"timeattack.medium.levelMaximum"], @"levelMaximum",
                  nil];
    _sessions[@"timeattack.medium"] = dictionary;


    dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  [userDefaults objectForKey:@"timeattack.marathon.level"], @"level",
                  [userDefaults objectForKey:@"timeattack.marathon.levelMaximum"], @"levelMaximum",
                  nil];
    _sessions[@"timeattack.marathon"] = dictionary;


    dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                  [userDefaults objectForKey:@"editor.level"], @"level",
                  [userDefaults objectForKey:@"editor.savedLevel"], @"savedLevel",
                  nil];
    _sessions[@"editor"] = dictionary;


    self.currentViewController = [userDefaults objectForKey:@"currentViewController"];

    // sanitize currentViewController
    NSRange range = [_currentViewController rangeOfString:@"iPad"];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // on iPad, if preferences are saved without an ipad viewcontroller
        // revert to the PlayMenuiPad
        if (range.location == NSNotFound) {
            self.currentViewController = @"MainMenuiPad";
        }
    }
    else {
        // on iPhone, if preferences are saved with an ipad viewcontroller
        // revert to the MainMenu
        if (range.location != NSNotFound) {
            self.currentViewController = @"MainMenu";
        }
    }

    // in 1.4 version, we've remove BuyGameViewController
    if ([_currentViewController isEqualToString:@"BuyGame"]) {
        self.currentViewController = @"MainMenu";
    }



    self.userName = [userDefaults objectForKey:@"userName"];

    NSString * modeStr = [userDefaults objectForKey:@"mode"];
    self.mode = [GameManager gameModeFromString:modeStr];
    self.counter = (unsigned int)[userDefaults integerForKey:@"counter"];
    self.levelsWithoutHintCount = (int)[userDefaults integerForKey:@"levelsWithoutHintCount"];

    _currentLevel.loaded = NO;

    // music and sound level
    SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];

    BOOL enabledSound = [userDefaults boolForKey:@"enabledSound"];
    enabledSound = NO;
    audioEngine.effectsVolume = enabledSound ? kEffectsVolume : 0;

    BOOL enabledMusic = [userDefaults boolForKey:@"enabledMusic"];
    enabledMusic = NO;
    audioEngine.backgroundMusicVolume = enabledMusic ? kBackgroundMusicVolume : 0;


    if (_enableiCloudSynchronisation) {
        //-- check that if change from iCloud need to be sync
        NSUbiquitousKeyValueStore * kvStore = [NSUbiquitousKeyValueStore defaultStore];
        NSNumber *levelMaximumiCloud = [kvStore objectForKey:@"classic.levelMaximum"];
        _levelMaximumiCloud = [levelMaximumiCloud intValue];

        NSInteger levelMaximumInMemory = [self levelMaximumForGameMode:kGameModeClassic];
        if (_levelMaximumiCloud > levelMaximumInMemory) {
            _sessions[@"classic"][@"levelMaximum"] = levelMaximumiCloud;
            [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerNewLevelFromiCloud
                                                                object:self];
        }

        //-- update the userDefault
        NSNumber *levelMaximumUserDefault = [userDefaults objectForKey:@"classic.levelMaximum"];
        if ([levelMaximumiCloud intValue] > [levelMaximumUserDefault intValue]) {
            [userDefaults setObject:levelMaximumiCloud forKey:@"classic.levelMaximum"];
        }
    }
}


#pragma mark - Helpers from sessions

- (NSUInteger)levelLimit {
    switch (_mode) {
        case kGameModeTimeAttackFlash:
#if defined(PREPROD)
#warning PREPROD ! in levelLimit
            _levelLimit = 0;
#else
            _levelLimit = 20;
#endif
            break;
        case kGameModeTimeAttackMedium:
#if defined(LITE)
            _levelLimit = 31;
#else
            _levelLimit = 40;
#endif

#if defined(PREPROD)
#warning PREPROD ! in levelLimit
            _levelLimit = 1;
#endif

            break;
        case kGameModeTimeAttackMarathon:
#if defined(LITE)
            _levelLimit = 31;
#else
            _levelLimit = 60;
#endif
#if defined(PREPROD)
#warning PREPROD ! in levelLimit
            _levelLimit = 2;
#endif
            break;
        case kGameModeClassic:
#if defined(LITE)
            _levelLimit = 31;
#else
            _levelLimit = 120;
#endif
            break;
        default:
            break;
    }
    return _levelLimit;
}


- (void)setLevel:(NSUInteger)newLevel {
#if defined(LITE)
    newLevel = MIN(newLevel, 31);
#else
    newLevel = MIN(newLevel, 120);
#endif

    NSString *modeStr = [GameManager stringFromGameMode:self.mode];
    _sessions[modeStr][@"level"] = @((int)newLevel);

    if (newLevel > self.levelMaximum) {
        self.levelMaximum = newLevel;
    }

    // set achievements
    if (self.mode == kGameModeClassic) {
        if (((newLevel % 10) == 0) && newLevel && (newLevel != 120)) {
            NSString *identifier = [NSString stringWithFormat:@"level%lu", newLevel];
            [self.gameCenterManager reportAchievementIdentifier:identifier];
        }
    }
}


- (void)setLevelMaximum:(NSUInteger)newLevelMaximum {
#if defined(LITE)
    newLevelMaximum = MIN(newLevelMaximum, 31 + 1);
#else
    newLevelMaximum = MIN(newLevelMaximum, 120 + 1);
#endif

    NSString *modeStr = [GameManager stringFromGameMode:self.mode];
    [self willChangeValueForKey:@"levelMaximum"];
    _sessions[modeStr][@"levelMaximum"] = @((int)newLevelMaximum);
    [self didChangeValueForKey:@"levelMaximum"];

    //-- store it in iCloud
    if (_enableiCloudSynchronisation) {
        if (self.mode == kGameModeClassic) {
            DebugLog(@"update iCloud key value classic.levelMaximum=%lu", newLevelMaximum);

            NSUbiquitousKeyValueStore * kvStore = [NSUbiquitousKeyValueStore defaultStore];
            [kvStore setObject:@((int)newLevelMaximum)
                        forKey:@"classic.levelMaximum"];
            [kvStore synchronize];
        }
    }
}


- (NSUInteger)level {

    NSString *modeStr = [GameManager stringFromGameMode:self.mode];
    return [_sessions[modeStr][@"level"] unsignedIntValue];
}


- (NSUInteger)levelMaximumForGameMode:(GameMode)aMode {
    NSString *modeStr = [GameManager stringFromGameMode:aMode];
    return [_sessions[modeStr][@"levelMaximum"] unsignedIntValue];
}


- (NSUInteger)levelMaximum {
    return [self levelMaximumForGameMode:self.mode];
}


+ (NSString *)stringFromGameMode:(GameMode)mode {
    switch (mode) {
        case kGameModeClassic:
            return @"classic";
            break;
        case kGameModeTimeAttackFlash:
            return @"timeattack.flash";
            break;
        case kGameModeTimeAttackMedium:
            return @"timeattack.medium";
            break;
        case kGameModeTimeAttackMarathon:
            return @"timeattack.marathon";
            break;
        case kGameModeWorld:
            return @"world";
            break;
        case kGameModeEditor:
            return @"editor";
            break;
        default:
            DebugLog(@"Error: unknow Game mode");
            return nil;
            break;
    }
}


+ (GameMode)gameModeFromString:(NSString *)modeStr {
    if ([modeStr isEqualToString:@"classic"]) {
        return kGameModeClassic;
    }
    else if ([modeStr isEqualToString:@"timeattack.flash"]) {
        return kGameModeTimeAttackFlash;
    }
    else if ([modeStr isEqualToString:@"timeattack.medium"]) {
        return kGameModeTimeAttackMedium;
    }
    else if ([modeStr isEqualToString:@"timeattack.marathon"]) {
        return kGameModeTimeAttackMarathon;
    }
    else if ([modeStr isEqualToString:@"world"]) {
        return kGameModeWorld;
    }
    else if ([modeStr isEqualToString:@"editor"]) {
        return kGameModeEditor;
    }
    else {
        DebugLog(@"Error: unknow Game string mode => default to Classic");
        return kGameModeClassic;
    }
}


- (void)setSavedLevel:(NSUInteger)level {
    self.level = level;
    _currentLevel.loaded = NO;
}


- (void)resetCounter {
    _counter = 0;
}


- (void)didSolveNewLevel:(NSUInteger)newLevel {
    if (_mode != kGameModeClassic) {
        return;
    }

    // Hints achievements
    _levelsWithoutHintCount++;
    if ((_levelsWithoutHintCount == 30) || (_levelsWithoutHintCount == 50)) {
        NSString *identifier = [NSString stringWithFormat:@"hint%ld", _levelsWithoutHintCount];
        [self.gameCenterManager reportAchievementIdentifier:identifier];
    }
    DebugLog(@"levelsWithoutHintCount=%ld", _levelsWithoutHintCount);

    // End level achievement
    if (newLevel == self.levelLimit) {
        [_gameCenterManager reportAchievementIdentifier:
         [NSString stringWithFormat:@"level%lu", self.levelLimit]];
    }

    // set score for classic leatherboard
    if (newLevel == self.levelMaximum) {
        [_gameCenterManager reportScore:newLevel
                            forCategory:@"leatherboard.classic"];
    }

    // Tools achievement
    if ((newLevel == 6) || (newLevel == 50) || (newLevel == 51) || (newLevel == 55) ||
        (newLevel == 118) || (newLevel == 42) || (newLevel == 84)) {

        if ([_currentLevel containsUnusedTool]) {
            [self.gameCenterManager reportAchievementIdentifier:
             [NSString stringWithFormat:@"tool%lu", newLevel]];
        }
    }
}


- (NSInteger)score {
    NSInteger score = 0;
    for(Achievement * achievement in [_gameCenterManager.achievements allValues]) {
        if (achievement.isCompleted) {
            score += achievement.value;
        }
    }
    return score;
}


- (void)setupAudioEngine {
    self.hasAudioBeenInitialized = NO;

#if defined(DEBUG)
    NSDate *date = [NSDate date];
#endif
    SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
    audioEngine.effectsVolume = 1.0;
    audioEngine.backgroundMusicVolume = 1.0;

    [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay
                                           autoHandle:YES];

#if defined(DEBUG)
    NSTimeInterval timePassed_ms = [date timeIntervalSinceNow] * -1000.0;
    DebugLog(@"load SimpleAudioEngine in %.2f ms", timePassed_ms);
#endif
    self.hasAudioBeenInitialized = YES;
}


#pragma mark - iCloud support

- (void)registerToiCloud {
    if (!&NSUbiquitousKeyValueStoreDidChangeExternallyNotification) {
        DebugLog(@"iCloud not supported (certainly iOS < 5.0");
        return;
    }
    NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateKVStoreItems:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
                                               object:store];
    BOOL ret = [store synchronize];
    if (ret) {
        DebugLog(@"iCloud enabled");
    }
    else {
        DebugLog(@"iCloud not available or bad entitlements");
    }
}


- (void)updateKVStoreItems:(NSNotification *)notification {
    // Get the list of keys that changed.
    NSDictionary * userInfo = [notification userInfo];
    NSNumber * reasonForChange = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey];
    NSInteger reason = -1;

    // If a reason could not be determined, do not update anything.
    if (!reasonForChange) {
        return;
    }

    // Update only for changes from the server.
    reason = [reasonForChange integerValue];
    if ((reason == NSUbiquitousKeyValueStoreServerChange) ||
        (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
        // If something is changing externally, get the changes
        // and update the corresponding keys locally.
        NSArray * changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey];
        NSUbiquitousKeyValueStore * store = [NSUbiquitousKeyValueStore defaultStore];
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];

        // This loop assumes you are using the same key names in both
        // the user defaults database and the iCloud key-value store
        for (NSString * key in changedKeys) {

            if ([key isEqualToString:@"classic.levelMaximum"]) {

                NSNumber *levelMaximumiCloud = [store objectForKey:key];

                // update in memory
                NSUInteger levelMaximumInMemory = [self levelMaximumForGameMode:kGameModeClassic];
                _levelMaximumiCloud = [levelMaximumiCloud intValue];
                if (_levelMaximumiCloud > levelMaximumInMemory) {

                    DebugLog(@"Update memory classic.levelMaximum %lu->%lu", levelMaximumInMemory, _levelMaximumiCloud);

                    [self willChangeValueForKey:@"levelMaximum"];
                    _sessions[@"classic"][@"levelMaximum"] = levelMaximumiCloud;
                    [self didChangeValueForKey:@"levelMaximum"];

                    [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerNewLevelFromiCloud
                                                                        object:self];
                }
                // update the userDefault
                NSNumber *levelMaximumUserDefault = [userDefaults objectForKey:@"classic.levelMaximum"];
                if ([levelMaximumUserDefault intValue] > [levelMaximumUserDefault intValue]) {

                    DebugLog(@"Update settings classic.levelMaximum %d->%d", [levelMaximumUserDefault intValue],
                             [levelMaximumUserDefault intValue]);

                    [userDefaults setObject:levelMaximumiCloud forKey:@"classic.levelMaximum"];
                }
            }
        }
    }
}


+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)theKey {

    BOOL automatic = NO;
    if ([theKey isEqualToString:@"levelMaximum"]) {
        automatic = NO;
    }
    else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    return automatic;
}


@end
