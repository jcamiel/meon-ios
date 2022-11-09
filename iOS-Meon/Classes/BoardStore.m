//
//  BoardStore.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/6/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "BoardStore.h"
#import "Common.h"
#import "GameCenterManager.h"
#import "HTTPRequest.h"
#import "NSData+Base64.h"
#import "NSKeyedArchiver+Helper.h"
#import "NSKeyedUnarchiver+Helper.h"
#import "Reachability.h"
#import "Score.h"
#import "UIDevice+Helper.h"


@interface BoardStore ()

@property (nonatomic, strong) NSMutableDictionary *requestDates;
@end

@implementation BoardStore


#pragma mark - init / dealloc

- (id)initWithBoardNames:(NSString *)firstNames, ...{


    if (self = [super init]) {

        self.boardNames = [NSMutableArray array];

        _requestDates = [[NSMutableDictionary alloc] init];

        va_list args;
        va_start(args, firstNames);
        for (NSString *arg = firstNames; arg != nil; arg = va_arg(args, NSString *)) {
            [_boardNames addObject:arg];
        }
        va_end(args);

        [self unserialize];
    }

    return self;
}


#pragma mark - serialize / unserialize

- (void)serialize {

    for(NSString *boardName in self.boardNames) {
        NSString *localBoardName = [NSString stringWithFormat:@"local.%@", boardName];
        NSMutableArray *board = self.boards[localBoardName];
        [NSKeyedArchiver archiveRootObject:board
                            toDocumentFile:[NSString stringWithFormat:@"scores.%@", localBoardName]];
    }

}

- (void)unserialize {
    self.boards = [[NSMutableDictionary alloc] init];

    for(NSString *boardName in self.boardNames) {
        // local
        NSString *localBoardName = [NSString stringWithFormat:@"local.%@", boardName];
        NSMutableArray *board = nil;
        int i =0;

        board = [NSKeyedUnarchiver unarchiveObjectWithDocumentFile:
                 [NSString stringWithFormat:@"scores.%@", localBoardName]];

        if (!board) {
            board = [NSMutableArray array];

            // feed with 20 scores
            for(i=0; i < 20; i++) {
                Score *score = [[Score alloc] init];
                score.type = boardName;
                [board addObject:score];
            }
        }
        self.boards[localBoardName] = board;

        // global
        NSString *globalBoardName = [NSString stringWithFormat:@"global.%@", boardName];
        board = [NSMutableArray array];
        self.boards[globalBoardName] = board;
        // feed with 50 scores
        for(i=0; i < 50; i++) {
            Score *score = [[Score alloc] init];
            score.type = boardName;
            [board addObject:score];
        }

    }

}

- (NSString *)encrypt:(NSString *)stringIn withKey:(NSString *)key {

    NSData * dataIn = [stringIn dataUsingEncoding:NSUTF8StringEncoding];
    NSString * stringBase64In = [dataIn base64EncodedString];
    NSMutableData *dataOut = [NSMutableData data];

    for(int i=0; i < stringBase64In.length; i++) {
        NSRange strRange = {i, 1};
        NSString * str = [stringBase64In substringWithRange:strRange];

        NSRange keyStrRange = {(i % key.length), 1};
        NSString * keyStr = [key substringWithRange:keyStrRange];

        const char * one = [str cStringUsingEncoding:NSASCIIStringEncoding];
        const char * two = [keyStr cStringUsingEncoding:NSASCIIStringEncoding];
        uint8_t result = one[0] + two[0];
        [dataOut appendBytes:&result length:1];
    }


    return [dataOut base64EncodedString];
}

#pragma mark - Retreive score
- (void)requestScoresForBoardNamed:(NSString *)boardName;
{
    if (![self networkAvailable]) {
        return;
    }


    // test if the last date for this request is enough spaced
    NSDate *lastRequest = self.requestDates[boardName];
    if (lastRequest && (fabs([lastRequest timeIntervalSinceNow]) < 20.0f)) {
        DebugLog(@"request too soon, 5s between each request");

        [[NSNotificationCenter defaultCenter] postNotificationName:GlobalBoardUpdate
                                                            object:self];
        return;
    }

    self.requestDates[boardName] = [NSDate date];


    // network is ok, send the get highscore request
    HTTPRequest *aNewRequest = [[HTTPRequest alloc] init];
    self.retreiveScoreRequest = aNewRequest;
    self.retreiveScoreRequest.delegate = self;
    self.retreiveScoreRequest.didFinishLoadingSelector = @selector(retreiveScoreRequestDidFinishLoading:);
    self.retreiveScoreRequest.didFailWithErrorSelector = @selector(retreiveScoreRequest:didFailWithError:);
    self.retreiveScoreRequest.userInfo = @{@"boardName": boardName};

    unsigned int type = 0;
    if ([boardName isEqualToString:@"global.timeattack.flash"]) {
        type=1;
    }
    else if ([boardName isEqualToString:@"global.timeattack.medium"]) {
        type=2;
    }
    else if ([boardName isEqualToString:@"global.timeattack.marathon"]) {
        type=3;
    }

#if defined(LITE)
    type+=3;
#endif
    NSString *platform = [[UIDevice currentDevice] hardwareModelAndVersion];

#if defined(PREPROD)
#warning PREPROD !!!!! requestScoresForBoardNamed:
    NSString *urlStr = [NSString stringWithFormat:
                        @"http://admin.manbolo.com/workjc/ws/highscores?im=0&ns=50&gi=%d&pn=%@",
                        type, platform];
#else
    NSString *urlStr = [NSString stringWithFormat:
                        @"http://ws.manbolo.com:8251/highscores?im=0&ns=50&gi=%d&pn=%@",
                        type, platform];
#endif


    [self.retreiveScoreRequest loadURL:urlStr];

}

#pragma mark -
#pragma mark Submit score
- (void)requestSubmitScore:(Score *) score {
    if (![self networkAvailable]) {
        return;
    }

    HTTPRequest *aNewRequest = [[HTTPRequest alloc] init];
    self.submitScoreRequest = aNewRequest;
    self.submitScoreRequest.didFinishLoadingSelector = @selector(submitScoreRequestDidFinishLoading:);
    self.submitScoreRequest.didFailWithErrorSelector = @selector(submitScoreRequest:didFailWithError:);
    self.submitScoreRequest.delegate = self;

    NSString *platform = [[UIDevice currentDevice] hardwareModelAndVersion];



    unsigned int type = 0;
    if ([score.type isEqualToString:@"timeattack.flash"]) {
        type=1;
    }
    else if ([score.type isEqualToString:@"timeattack.medium"]) {
        type=2;
    }
    else if ([score.type isEqualToString:@"timeattack.marathon"]) {
        type=3;
    }

#if defined(LITE)
    type+=3;
#endif

    NSDictionary *json = @{@"pn": platform, @"gi": @(type), @"un": score.user, @"sv": @([score.value intValue])};

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:NULL];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *jsonStrEncrypt = [self encrypt:jsonStr withKey:@"C3ciEstUn3Cl3C0mpl1quE!"];

#if defined(PREPROD)
#warning PREPROD !!!!! requestSubmitScore:
    NSString *urlStr = @"http://admin.manbolo.com/workjc/ws/highscores";
#else
    NSString *urlStr = @"http://ws.manbolo.com:8251/highscores";
#endif

    NSString *paramStr = [NSString stringWithFormat:@"p=%@",
                          [jsonStrEncrypt stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    [self.submitScoreRequest loadURL:urlStr postValue:paramStr];
    DebugLog(@"%@", urlStr);
}

#pragma mark -
#pragma mark RetreiveScoreRequest

- (void)retreiveScoreRequest:(HTTPRequest *) request didFailWithError:(NSError *)error {
    NSString *boardName = request.userInfo[@"boardName"];
    [self.requestDates removeObjectForKey:boardName];
    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalBoardUpdate
                                                        object:self];
}

- (void)retreiveScoreRequestDidFinishLoading:(HTTPRequest *)request {
    NSString *boardName = request.userInfo[@"boardName"];
    NSMutableArray *board = self.boards[boardName];

    id scores = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                options:0
                                                  error:NULL];
    if ([scores isKindOfClass:[NSDictionary class]]) {
        [self addScoresWithDictionnary:scores toBoard:board];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:GlobalBoardUpdate
                                                        object:self];

}

#pragma mark -
#pragma mark SubmitScoreRequest

- (void)submitScoreRequest:(HTTPRequest *) request didFailWithError:(NSError *)error {
    [self.delegate boardScoreSubmitDidSucceed:self];

//    [self.delegate boardScoreSubmitDidFailed:self];
}

- (void)submitScoreRequestDidFinishLoading:(HTTPRequest *)request {
    [self.delegate boardScoreSubmitDidSucceed:self];
}

- (Score *)firstInvalidScoreForBoard:(NSArray *)board {
    // search through the board an invalid score
    Score *invalidScore = nil;
    for(Score *score in board) {
        if (!score.isValid) {
            invalidScore = score;
            break;
        }
    }

    return invalidScore;
}

- (void)checkAchievementsAndScore:(Score *)score {
    if ([score.type isEqualToString:@"timeattack.flash"]) {

        [self.gameCenterManager reportAchievementIdentifier:@"flash"];

        if ([score.value intValue] <= 5000) {
            [self.gameCenterManager reportAchievementIdentifier:@"timeattack.flash5000"];
        }
        if ([score.value intValue] <= 3000) {
            [self.gameCenterManager reportAchievementIdentifier:@"timeattack.flash3000"];
        }
        if ([score.value intValue] <= 1000) {
            [self.gameCenterManager reportAchievementIdentifier:@"timeattack.flash1000"];
        }
    }
    else if ([score.type isEqualToString:@"timeattack.medium"]) {

        [self.gameCenterManager reportAchievementIdentifier:@"medium"];
        if ([score.value intValue] <= 5000) {
            [self.gameCenterManager reportAchievementIdentifier:@"timeattack.medium5000"];
        }

    }
    else if ([score.type isEqualToString:@"timeattack.marathon"]) {

        [self.gameCenterManager reportAchievementIdentifier:@"marathon" ];

        if ([score.value intValue] <= 1000) {
            [self.gameCenterManager reportAchievementIdentifier:@"timeattack3000"];
        }

    }

    // check if there is a new score
    NSString *category = [NSString stringWithFormat:@"leatherboard.%@", score.type];
    [self.gameCenterManager reportScore:[score.value intValue] forCategory:category];
}

- (void)addScore:(Score *)score toBoardNamed:(NSString *)boardName {
    NSMutableArray *board = self.boards[boardName];

    Score *invalidScore = [self firstInvalidScoreForBoard:board];
    if (invalidScore) {
        NSUInteger index = 0;
        index = [board indexOfObject:invalidScore];
        board[index] = score;
    }
    else {
        [board addObject:score];
    }

    [board sortUsingSelector:@selector(compare:)];
}

- (void)removeAllScores:(NSString *)boardType {
    for(NSString * boardName in self.boardNames) {
        NSString *selectedBoardName = [NSString stringWithFormat:@"%@.%@",
                                       boardType, boardName];
        NSMutableArray *board = self.boards[selectedBoardName];
        [board removeAllObjects];

        // feed with 20 scores
        for(int i=0; i < 20; i++) {
            Score *score = [[Score alloc] init];
            score.type = boardName;
            [board addObject:score];
        }
    }
}

- (void)addScoresWithDictionnary:(NSDictionary *)scores toBoard:(NSMutableArray *)board {
    int index = [scores[@"index"] intValue];

    NSArray *list = scores[@"list"];
    if (!list || ((NSNull *)list == [NSNull null])) {
        DebugLog(@"no scores available for index=%d", index);
        return;
    }

    for(NSDictionary * infoScore in list) {
        Score *newScore = [[Score alloc] initWithDictionary:infoScore];
        newScore.scoreId = [NSString stringWithFormat:@"%d", index];
        Score *previousScore = board[index];
        if (previousScore) {
            board[index] = newScore;
        }
        index++;
    }


}

#pragma mark -
#pragma mark Network availability

- (BOOL)networkAvailable {
    NetworkStatus status = [Reachability reachabilityForInternetConnection];
    if (status == NotReachable) {
        DebugLog(@"no network available");

        // simulate the update of the global board
        [[NSNotificationCenter defaultCenter] postNotificationName:GlobalBoardUpdate
                                                            object:self];
        [self.delegate boardScoreSubmitDidFailed:self];
        [self showNoNetworkAlert];
        return NO;
    }
    return YES;
}

- (void)showNoNetworkAlert {
    NSString * msg = NSLocalizedString(@"L_NoNetwork", );
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil
                                                  message:msg
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
    [av show];
}

- (Score *)highScoreForBoardNamed:(NSString *)boardName {
    NSMutableArray *board = self.boards[boardName];
    if (board.count) {
        Score * score = board[0];
        return [score copy];
    }
    else {
        return nil;
    }

}

@end
