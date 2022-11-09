//
//  LevelManager.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 3/13/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "HTTPRequest.h"
#import "LevelManager.h"


@implementation LevelManager

#pragma mark - Singleton managment

+ (instancetype)sharedLevelManager {
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
        self.requests = [[NSMutableSet alloc] init];
    }
    return self;
}




#pragma mark - publish level
- (void)publish:(Level *)level {
    NSString *solutionStr, *originalStr;
    if (![level isCompleted]) {
        DebugLog(@"Warning: level not completed, can't publish it");
        return;
    }

    level.published = NO;
    [level generateHintsSprites];

    solutionStr = [level string];

    // Create a tempory level from the solution
    Level *shuffledlevel = [[Level alloc] init];
    [shuffledlevel loadFromString:solutionStr];
    [shuffledlevel shuffleObjects:NO];


    originalStr = [shuffledlevel string];

    // TODO: check that the shuffled is not a solution !!

    NSString *jsonStr = [NSString stringWithFormat:
                         @"{\"original\":\"%@\",\"solution\":\"%@\"}",
                         originalStr,
                         solutionStr];

    NSString *paramStr = [NSString stringWithFormat:@"p=%@",
                          [jsonStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];


    self.submitLevelRequest = [[HTTPRequest alloc] init];
    self.submitLevelRequest.delegate = self;
    self.submitLevelRequest.didFinishLoadingSelector = @selector(submitRequestDidFinishLoading:);
    self.submitLevelRequest.didFailWithErrorSelector = @selector(submitRequest:didFailWithError:);
    self.submitLevelRequest.userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        level, @"level", nil];

    [self.requests addObject:self.submitLevelRequest];

//  [self performSelector:@selector(test:) withObject:paramStr afterDelay:10.0];

    [self.submitLevelRequest loadURL:@"http://ws.manbolo.com/meon/level.php"
     postValue:paramStr];
}

- (void)test:(NSString *)str {
    [self.submitLevelRequest loadURL:@"http://localhost/ws.manbolo.com/meon/level.php"
     postValue:str];
}

#pragma mark - download level
- (void)loadWorldLevels {
    int i = 0;

    self.worldLevels = [NSMutableArray array];
    self.worldLevelsQueued = [NSMutableArray array];

    for(i=0; i < 9; i++) {
        [self.worldLevels addObject:[NSNull null]];
    }

    HTTPRequest *downloadLevelRequest = [[HTTPRequest alloc] init];
    downloadLevelRequest.delegate = self;
    downloadLevelRequest.didFinishLoadingSelector = @selector(downloadRequestDidFinishLoading:);
    downloadLevelRequest.didFailWithErrorSelector = @selector(downloadRequest:didFailWithError:);

    [self.requests addObject:downloadLevelRequest];

    [downloadLevelRequest loadURL:@"http://localhost/ws.manbolo.com/meon/level.php?start=0&count=11"];

}




#pragma mark - Submit Request delegate

- (void)submitRequest:(HTTPRequest *)request didFailWithError:(NSError *)error {
    [self.requests removeObject:request];
    self.submitLevelRequest = nil;

    if ([self.delegate respondsToSelector:@selector(publishLevelDidFailed:)]) {
        [self.delegate publishLevelDidFailed:self];
    }

}

- (void)submitRequestDidFinishLoading:(HTTPRequest *)request {
    [self.requests removeObject:request];
    self.submitLevelRequest = nil;

    Level *level = (request.userInfo)[@"level"];
    level.published = YES;

    if ([self.delegate respondsToSelector:@selector(publishLevelDidSucceed:)]) {
        [self.delegate publishLevelDidSucceed:self];
    }

}

#pragma mark - Download World Request delegate

- (void)downloadRequest:(HTTPRequest *)request didFailWithError:(NSError *)error {
    [self.requests removeObject:request];
}



- (void)downloadRequestDidFinishLoading:(HTTPRequest *)request {
    id jsonLevels = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:NULL];

    int i = 0;
    if ([jsonLevels isKindOfClass:[NSArray class]]) {
        for(NSDictionary *jsonLevel in jsonLevels) {
            [self.worldLevelsQueued addObject:jsonLevel];
            i++;
        }
    }

    // feed the worldLevel with worldLevelsQueue
    for(i=0; i < 9; i++) {
        if (self.worldLevels[i] == [NSNull null]) {
            if (self.worldLevelsQueued.count) {
                NSMutableDictionary * level = self.worldLevelsQueued[0];


                [self willChange:NSKeyValueChangeReplacement
                 valuesAtIndexes:[NSIndexSet indexSetWithIndex:i]
                 forKey:@"worldLevels"];

                self.worldLevels[i] = level;
                [self.worldLevelsQueued removeObjectAtIndex:0];

                [self didChange:NSKeyValueChangeReplacement
                 valuesAtIndexes:[NSIndexSet indexSetWithIndex:i]
                 forKey:@"worldLevels"];

            }
        }
    }


    [self.requests removeObject:request];
}

- (void)renewWorldLevelsAtIndexSet:(NSIndexSet *)index {
    NSUInteger currentIndex = [index firstIndex];

    while (currentIndex != NSNotFound) {

        [self willChange:NSKeyValueChangeReplacement
         valuesAtIndexes:[NSIndexSet indexSetWithIndex:currentIndex]
         forKey:@"worldLevels"];

        id newLevel = self.worldLevelsQueued.count ? self.worldLevelsQueued[0] :
                      [NSNull null];
        if ([newLevel isKindOfClass:[NSNull class]]) {
            DebugLog(@"Warning !! run out of levels");
        }
        self.worldLevels[currentIndex] = newLevel;

        if (self.worldLevelsQueued.count) {[self.worldLevelsQueued removeObjectAtIndex:0]; }

        [self didChange:NSKeyValueChangeReplacement
         valuesAtIndexes:[NSIndexSet indexSetWithIndex:currentIndex]
         forKey:@"worldLevels"];

        currentIndex = [index indexGreaterThanIndex:currentIndex];
    }
}


#pragma mark - Classic Levels

- (void)loadClassicLevels {
    // levels
    NSString *thePath = [[NSBundle mainBundle] pathForResource:@"levels"
                         ofType:@"plist"];
    self.classicLevels = [NSMutableArray arrayWithContentsOfFile:thePath];

}

#pragma mark - Editor Levels

- (void)loadEditorLevels {
    self.editorLevels = [[NSMutableArray alloc] init];

    NSDictionary *dic = @{kLevelOriginalKey: kEmptyLevelString,
                          kLevelSolutionKey: kEmptyLevelString};
    [self.editorLevels addObject:dic];


//    Level *aLevel = [[[Level alloc] init] autorelease];
//
//    int col, row, index;
//    for(row=0; row<12; row++){
//        for(col=0; col<12; col++){
//            index = col + 12*row;
//            if ((row==0) || (row==11) || (col==0) || (col==11) ||
//                (row==1) || (row==10) || (col==1) || (col==10)) {
//                aLevel.cells[index]= kTilePlain;
//            }
//            else{
//                aLevel.cells[index]= kTileVoid;
//
//            }
//
//        }
//    }
//
//    NSString* string = [aLevel string];
//    NSLog(string);


}

- (BOOL)isPublishing {
    return (self.submitLevelRequest != nil);
}




@end
