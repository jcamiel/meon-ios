//
//  GameCenterManager.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 11/21/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "Achievement.h"
#import "GameCenterManager.h"
#import "GameManager.h"
#import "NSKeyedArchiver+Helper.h"
#import "NSKeyedUnarchiver+Helper.h"
#import "UIApplication+Helper.h"
#import <GameKit/GameKit.h>


@interface GameCenterManager ()

@property (nonatomic, strong) NSMutableDictionary *gameKitAchievements;
@property (nonatomic, strong) NSTimer *retryReportingTimer;
@property (nonatomic, strong) NSMutableArray *scoresToReport;
@property (nonatomic, strong) NSMutableArray *scoresReported;
@property (nonatomic, strong) NSMutableArray *achievementsToReport;
@property (nonatomic, strong) NSMutableArray *achievementsReported;

@end



@implementation GameCenterManager



+ (BOOL)isGameCenterAvailable {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));

    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);

    return (gcClass && osVersionSupported);
#else
    return NO;
#endif
}


- (id)initWithGameManager:(GameManager *)gameManager {
    self = [super init];

    if (self) {

        _gameManager = gameManager;
        _gameCenterAvailable = [GameCenterManager isGameCenterAvailable];

        self.achievementsToDisplay = [NSMutableArray array];

        // get the achievements from disk
        [self loadLocalAchievements];

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        if (_gameCenterAvailable) {
            // authenticate to GameKit and get achievement from network
            [self authenticateGameKitPlayer];

            // get the GameKit score than have not been serialized
            // and that should be resent
            [self unserializeGameKitScoresAndAchievementsNotSent];
        }
#endif
    }
    return self;
}


- (void)dealloc {
    [self saveLocalAchievements];

    [self.retryReportingTimer invalidate];
}


- (void)resetAchievements {
    for(Achievement *achievement in [self.achievements allValues]) {
        achievement.completed = NO;
    }

    if (!self.gameCenterAvailable) {
        return;
    }

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    // Clear all locally saved achievement objects.
    // Clear all progress saved on Game Center
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){
         if (!error) {
             DebugLog(@"Gamecenter achievement reseted");
         }
     }];
#endif
}


#pragma mark -
#pragma mark Serialize / Unseralize Achievements
- (NSArray *)arrayFromPlistAtPath:(NSString *)path {
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSString *error;
    NSPropertyListFormat format;
    NSArray *array = nil;

    array = [NSPropertyListSerialization propertyListFromData:plistData
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:&format
                                             errorDescription:&error];
    return array;
}


- (void)loadLocalAchievements {
    NSArray * serializedAchievements;
    NSString *documentPath = [UIApplication documentDirectory];
    NSString *currentPath = [NSString stringWithFormat:@"%@/achievements.plist", documentPath];
    serializedAchievements = [self arrayFromPlistAtPath:currentPath];
    if (!serializedAchievements.count) {
        DebugLog(@"unserialize default achievements");
        currentPath = [[NSBundle mainBundle] pathForResource:@"achievements"
                                                      ofType:@"plist"];
        serializedAchievements = [self arrayFromPlistAtPath:currentPath];
    }


    self.achievements = [NSMutableDictionary dictionary];
    for(NSDictionary * dic in serializedAchievements) {
        Achievement *achievement = [[Achievement alloc] initWithDictionary:dic];
        self.achievements[achievement.identifier] = achievement;
    }

    // in this case, try to synchronise local achievements
    // with maximumLevel, if you upgrade from 1.0 to 1.1
    [self synchroniseLocalAchievements];
}


- (void)saveLocalAchievements {
    NSString *documentPath = [UIApplication documentDirectory];
    NSString *currentPath = [NSString stringWithFormat:@"%@/achievements.plist", documentPath];
    NSArray * achievements = [self.achievements allValues];
    NSMutableArray *arrayToSerialize = [NSMutableArray array];
    for(Achievement *achievement in achievements) {
        NSDictionary *dic = [achievement dictionaryFromAchievement];
        [arrayToSerialize addObject:dic];
    }
    BOOL ret = [arrayToSerialize writeToFile:currentPath atomically:YES];
    if (!ret) {
        DebugLog(@"Problem in serializing achievements");
    }
}


#pragma mark -
#pragma mark Achievements Reporting

- (void)reportAchievementIdentifier:(NSString *)identifier {
    Achievement *achievement = self.achievements[identifier];
    if (!achievement) {
        DebugLog(@"problem with achievement %@", identifier);
        return;
    }
    if (achievement.completed) {
        return;
    }

    achievement.completed = YES;
    [self.achievementsToDisplay addObject:achievement];

    NSString * gameKitIdentifier = identifier;
    if (self.gameKitIdentifierPrefix) {
        gameKitIdentifier = [NSString stringWithFormat:@"%@%@", self.gameKitIdentifierPrefix, identifier];
    }

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [self reportGameKitAchievementIdentifier:gameKitIdentifier percentComplete:100.0];
#endif
}


- (void)reportGameKitAchievementIdentifier:(NSString *)identifier percentComplete:(double)percent {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

    if (!self.gameCenterAvailable) {
        return;
    }

    GKAchievement *achievement = [self gameKitAchievementForIdentifier:identifier];
    if (achievement.completed ) {
        DebugLog(@"achievement %@ already completed", identifier);
        return;
    }

    achievement.percentComplete = percent;

    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error){
         if (error != nil) {
             DebugLog(@"Reporting achievement %@ failed", identifier);
             [self.achievementsToReport addObject:achievement];

             [self startRetryReportingTimer];
         }
         else {
             DebugLog(@"Reporting achievement %@ succeeded", identifier);
         }
     }];
#endif
}


#pragma mark - Score posting

- (void)reportScore:(int64_t)scoreValue forCategory:(NSString *)category {
    if (!self.gameCenterAvailable) {
        return;
    }

    NSString * realCategory = category;
    if (self.gameKitIdentifierPrefix) {
        realCategory = [NSString stringWithFormat:@"%@%@", self.gameKitIdentifierPrefix, category];
    }

    GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:realCategory];
    score.value = scoreValue;

    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
         if (error != nil) {
             DebugLog(@"Reporting score %d in %@ failed", (int)scoreValue, realCategory);

             if (self.scoresToReport.count < 20) {
                 [self.scoresToReport addObject:score];
             }

             [self startRetryReportingTimer];
         }
         else {
             DebugLog(@"Reporting score %d in %@ succeeded", (int)score, realCategory);
         }
     }];
}


- (void)startRetryReportingTimer {
    if (self.retryReportingTimer) {
        return;
    }

    DebugLog(@"Start Retry timer");
    self.retryReportingTimer = [NSTimer scheduledTimerWithTimeInterval:120
                                                                target:self
                                                              selector:@selector(tryReporting:)
                                                              userInfo:nil
                                                               repeats:YES];
}


- (void)stopRetryReportingTimer {
    DebugLog(@"Stop Retry timer");
    [self.retryReportingTimer invalidate];
    self.retryReportingTimer = nil;
}


- (void)tryReporting:(NSTimer *)theTimer {
    DebugLog(@"Tick");

    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        DebugLog(@"Player not authenticate to gamekit");
        return;
    }

    // remove the reported scores from the scores to send
    for(GKScore * score in self.scoresReported) {
        [self.scoresToReport removeObject:score];
    }
    [self.scoresReported removeAllObjects];

    // remove the reported achievements from the achievements to send
    for(GKAchievement * achievement in self.achievementsReported) {
        [self.achievementsToReport removeObject:achievement];
    }
    [self.achievementsReported removeAllObjects];

    // if no score to send, stop the timer
    if (!self.scoresToReport.count && !self.achievementsToReport.count) {
        [self stopRetryReportingTimer];
        return;
    }


    // try to send the scores
    for(GKScore *score in self.scoresToReport) {
        // FIXME: on iOS 6.0 directly send scores that have been unserialized can
        // crash the application with the following message
        // Terminating app due to uncaught exception 'GKInvalidArgumentException',
        // reason: 'A GKScore must contain an initialized value.'
        // to patch this crash, we create a new GKScore based on the score values
        // and report it instead. The bug doesn't seen to happens with GKAchievement
        // but in case it happens, we prevently do the same thing
        GKScore *scoreToReport = [[GKScore alloc] initWithLeaderboardIdentifier:score.leaderboardIdentifier];
        scoreToReport.value = score.value;


        [GKScore reportScores:@[scoreToReport] withCompletionHandler:^(NSError *error) {
             if (error != nil) {
                 DebugLog(@"Reporting score %d in %@ failed", (int)score.value, score.leaderboardIdentifier);
             }
             else {
                 DebugLog(@"Reporting score %d in %@ succeeded", (int)score.value, score.leaderboardIdentifier);
                 [self.scoresReported addObject:score];
             }
         }];
    }


    // try to send the achievemnts
    for(GKAchievement *achievement in self.achievementsToReport) {
        // FIXME: on iOS 6.0 possible bug, see above.
        GKAchievement *achievementToReport = [[GKAchievement alloc]
                                              initWithIdentifier:achievement.identifier];
        [GKAchievement reportAchievements:@[achievementToReport] withCompletionHandler:^(NSError *error) {
             if (error != nil) {
                 DebugLog(@"Reporting achievement %@ failed", achievement.identifier);
             }
             else {
                 DebugLog(@"Reporting achievement %@ succeeded", achievement.identifier);
                 [self.achievementsReported addObject:achievement];
             }
         }];
    }
}


#pragma mark -
#pragma mark GameCenter

- (GKAchievement *)gameKitAchievementForIdentifier: (NSString *) identifier {
    GKAchievement *achievement = self.gameKitAchievements[identifier];
    if (achievement == nil) {
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        self.gameKitAchievements[achievement.identifier] = achievement;
    }
    return achievement;
}


- (void)authenticateGameKitPlayer {
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
         if (error == nil) {
             DebugLog(@"successful authentication - load achievements");

             // check if there is no user name, if no, set one
             if (!self.gameManager.userName || !self.gameManager.userName.length) {
                 DebugLog(@"Assign GameCenter user name");
                 self.gameManager.userName = [[GKLocalPlayer localPlayer] alias];
             }

             [self loadGameKitAchievements];
         }
         else {
             DebugLog(@"fail authentication");
         }
     };
}


- (void)loadGameKitAchievements {
    self.gameKitAchievements = [NSMutableDictionary dictionary];

    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error){
         if (!error) {
             for (GKAchievement * achievement in achievements) {
                 self.gameKitAchievements[achievement.identifier] = achievement;
             }
             [self synchroniseLocalAchievements];
             [self synchroniseGameKitAchievements];
         }
         else {
             DebugLog(@"Error in loading achievements");
         }
     }];
}


- (void)synchroniseGameKitAchievements {
    BOOL shouldSendNotification = NO;

    // synchronise local and GameKit achievements
    // we see if there is any pending local achievements
    for (Achievement *localAchievement in [self.achievements allValues]) {

        NSString * gameKitIdentifier = [NSString stringWithFormat:@"%@%@",
                                        self.gameKitIdentifierPrefix, localAchievement.identifier];;

        GKAchievement *gameKitAchievement = self.gameKitAchievements[gameKitIdentifier];

        // if any local has not been registered to Game Center notify it
        if ((localAchievement.completed && !gameKitAchievement.completed) ||
            (localAchievement.completed && !gameKitAchievement)) {
            DebugLog(@"Report achievement %@", localAchievement.identifier);

            [self reportGameKitAchievementIdentifier:gameKitIdentifier
                                     percentComplete:100.0];
        }

        // if any Game Center achievement is not registered in local, save it
        if (!localAchievement.completed && gameKitAchievement.completed) {
            localAchievement.completed = YES;
            shouldSendNotification = YES;
        }
    }

    if (shouldSendNotification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GameManagerUpdateAchievements
                                                            object:self];
    }
}


- (void)serializeGameKitScoresAndAchievementsNotSent {
    if (self.gameCenterAvailable) {
        [NSKeyedArchiver archiveRootObject:self.scoresToReport
                            toDocumentFile:@"scoresToReport"];

        [NSKeyedArchiver archiveRootObject:self.achievementsToReport
                            toDocumentFile:@"achievementsToReport"];
    }
}


- (void)unserializeGameKitScoresAndAchievementsNotSent {
    if (self.gameCenterAvailable) {
        self.scoresToReport = [NSKeyedUnarchiver
                               unarchiveObjectWithDocumentFile:@"scoresToReport"];
        if (!self.scoresToReport) {
            self.scoresToReport = [NSMutableArray array];
        }
        self.achievementsToReport = [NSKeyedUnarchiver
                                     unarchiveObjectWithDocumentFile:@"achievementsToReport"];
        if (!self.achievementsToReport) {
            self.achievementsToReport = [NSMutableArray array];
        }

        self.scoresReported = [NSMutableArray array];

        self.achievementsReported = [NSMutableArray array];
    }

    if (self.scoresToReport.count || self.achievementsToReport.count) {
        [self startRetryReportingTimer];
    }
}


- (void)synchroniseLocalAchievements {
    DebugLog(@"Synchronise local achievements");

    NSUInteger levelMaximum = [self.gameManager levelMaximumForGameMode:kGameModeClassic];

    // synchronise maximum reached level for local Achievement
    for(NSUInteger i = 1; i <= (levelMaximum / 10); i++) {
        if (i == 12) {
            break;
        }

        NSString *achievementId = [NSString stringWithFormat:@"level%lu", i * 10];
        Achievement *localAchievement = [self.achievements valueForKey:achievementId];
        if (!localAchievement.completed) {
            localAchievement.completed = YES;
            if (localAchievement) {
                [self.achievementsToDisplay addObject:localAchievement];
            }
            else {
                DebugLog(@"!! problem local achievement nil");
            }
        }
    }
}


@end
