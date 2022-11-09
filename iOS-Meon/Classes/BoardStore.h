//
//  BoardStore.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/6/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequest.h"

@class Score, GameCenterManager;

#define GlobalBoardUpdate @"Notification_GlobalBoardUpdate"


@protocol BoardStoreDelegate;

@interface BoardStore : NSObject 
- (id)initWithBoardNames:(NSString*)firstNames, ... NS_REQUIRES_NIL_TERMINATION;

@property (nonatomic, strong) HTTPRequest *submitScoreRequest;
@property (nonatomic, strong) HTTPRequest *retreiveScoreRequest;
@property (nonatomic, strong) NSMutableArray *boardNames;
@property (nonatomic, strong) NSMutableDictionary *boards;
@property (nonatomic, weak) id<BoardStoreDelegate> delegate;
@property (nonatomic, strong) GameCenterManager *gameCenterManager;

- (void)serialize;
- (void)unserialize;
- (void)requestScoresForBoardNamed:(NSString*)boardName;
- (void)requestSubmitScore:(Score*)aScore;
- (void)addScore:(Score*)score toBoardNamed:(NSString*)boardName;
- (void)addScoresWithDictionnary:(NSDictionary*)scores toBoard:(NSMutableArray*)name;
- (void)removeAllScores:(NSString*)boardType;
- (Score*)highScoreForBoardNamed:(NSString*)boardName;
- (Score*)firstInvalidScoreForBoard:(NSArray*)board;
- (void)checkAchievementsAndScore:(Score *)score;
- (NSString*)encrypt:(NSString*)stringIn withKey:(NSString*)key;


@end


@protocol BoardStoreDelegate
- (void)boardScoreSubmitDidSucceed:(BoardStore*)boardStore;
- (void)boardScoreSubmitDidFailed:(BoardStore*)boardStore;
@end

