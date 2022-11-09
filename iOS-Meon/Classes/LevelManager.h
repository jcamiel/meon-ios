//
//  LevelManager.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 3/13/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Level.h"
#import "HTTPRequest.h"


@protocol LevelManagerDelegate;


@interface LevelManager : NSObject

@property (nonatomic, weak) id<LevelManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableSet *requests;
@property (nonatomic, strong) NSMutableArray *worldLevels;
@property (nonatomic, strong) NSMutableArray *classicLevels;
@property (nonatomic, strong) NSMutableArray *editorLevels;
@property (nonatomic, strong) NSMutableArray *worldLevelsQueued;
@property (nonatomic, strong) HTTPRequest *submitLevelRequest;

+ (LevelManager*)sharedLevelManager;
- (void)publish:(Level*)level;
- (void)loadWorldLevels;
- (void)loadClassicLevels;
- (void)loadEditorLevels;
- (void)renewWorldLevelsAtIndexSet:(NSIndexSet*)index;
- (BOOL)isPublishing;
@end



@protocol LevelManagerDelegate<NSObject>
- (void)publishLevelDidSucceed:(LevelManager*)manager;
- (void)publishLevelDidFailed:(LevelManager*)manager;
@end

