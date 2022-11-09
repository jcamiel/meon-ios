//
//  GameCenterManager.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 11/21/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GameManager;


@interface GameCenterManager : NSObject


@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, assign) BOOL gameCenterAvailable;
@property (nonatomic, strong) NSMutableArray *achievementsToDisplay;
@property (nonatomic, strong) NSMutableDictionary *achievements;
@property (nonatomic, copy) NSString *gameKitIdentifierPrefix;

- (void)resetAchievements;
- (void)reportAchievementIdentifier:(NSString*)identifier;
- (void)reportScore:(int64_t)score forCategory:(NSString*)category;
- (id)initWithGameManager:(GameManager*)gameManager;
- (void)saveLocalAchievements;
- (void)serializeGameKitScoresAndAchievementsNotSent;
- (void)unserializeGameKitScoresAndAchievementsNotSent;


@end
