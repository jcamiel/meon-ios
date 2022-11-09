//
//  HighscoresiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//
#import "HighscoresiPadViewController.h"

#import "BoardStore.h"
#import "Score.h"
#import "ScoresiPadCell.h"
#import "UIView+Helper.h"

@interface HighscoresiPadViewController ()

@property (nonatomic, assign) NSInteger segmentedIndex;

@end


@implementation HighscoresiPadViewController

#pragma mark - init / dealloc

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addHeaderImageNamed:@"Common/scores_header@2x.png"];

    self.scoreGameMode = kGameModeTimeAttackFlash;

    self.localTableView = [self addTableView];
    self.globalTableView = [self addTableView];
    self.localTableView.hidden = NO;
    self.globalTableView.hidden = YES;

    [self addButtons];
    [self addActivityIndicator];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGlobalBoardUpdate:)
                                                 name:GlobalBoardUpdate
                                               object:nil];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.localTableView = nil;
    self.globalTableView = nil;
}


#pragma mark - Add subviews

- (void)addActivityIndicator {
    self.loadingView = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.center = self.localTableView.center;
    [self.view addSubview:self.loadingView];
}


- (void)addButtons {
    // create the board button: local or global
    self.boardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize buttonSize = (CGSize){253, 166};
    CGRect frame = (CGRect){{self.view.bounds.size.width - buttonSize.width - 10, 60},
                            {buttonSize.width, buttonSize.height}};
    self.boardButton.frame = frame;
    [self.boardButton addTarget:self action:@selector(switchTable:)
               forControlEvents:UIControlEventTouchUpInside];
    [self updateBoardButton];
    [self.view insertSubview:self.boardButton belowSubview:self.cancelButton];

    // create the switch to game mode: flash, medium, marathon
    self.gameModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonSize = (CGSize){160, 66};
    frame = (CGRect){{0, 60}, {buttonSize.width, buttonSize.height}};
    self.gameModeButton.frame = frame;
    [self.gameModeButton addTarget:self action:@selector(changeGameMode:)
                  forControlEvents:UIControlEventTouchUpInside];
    [self updateGameModeButton];
    [self.view addSubview:self.gameModeButton];
    [self.gameModeButton alignWithVerticalCenterOf:self.boardButton];

    // add the label for the game mode switch
    UIImage *image = [UIImage imageNamed:@"change.png"];
    UIImageView *anImageView = [[UIImageView alloc] initWithImage:image];
    anImageView.x = self.gameModeButton.width + self.gameModeButton.x;
    [anImageView alignWithVerticalCenterOf:self.gameModeButton];
    [self.view addSubview:anImageView];
}


#pragma mark - TableView Delegate

- (UITableView *)addTableView {
    CGFloat marginLeft = 20.0;
    CGFloat marginTop = 180.0;
    CGFloat marginBottom = 0.0;

    CGRect frame = (CGRect){{marginLeft, marginTop},
                            {self.view.frame.size.width - 2 * marginLeft,
                             self.view.frame.size.height - marginTop - marginBottom}};
    UITableView *aTableView = [[UITableView alloc] initWithFrame:frame
                                                           style:UITableViewStylePlain];
    aTableView.dataSource = self;
    aTableView.delegate = self;
    aTableView.rowHeight = 70;
    aTableView.separatorColor = [UIColor darkGrayColor];
    aTableView.backgroundColor = [UIColor colorWithRed:41.0 / 255
                                                 green:40.0 / 255
                                                  blue:49.0 / 255
                                                 alpha:1];
    aTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    if ([aTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        aTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }

    [self.view addSubview:aTableView];
    return aTableView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *prefix = (tableView == self.globalTableView) ? @"global" : @"local";
    NSString *boardName = [NSString stringWithFormat:@"%@.%@", prefix,
                           [GameManager stringFromGameMode:self.scoreGameMode]];

    NSArray *scores = (self.boardStore.boards)[boardName];
    return scores.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"ScoresiPadCell";
    ScoresiPadCell *cell = nil;

    // generic case
    cell = (ScoresiPadCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:kCellIdentifier owner:self options:nil];
        cell = self.scoresCell;
        self.scoresCell = nil;
    }

    NSString *prefix = (tableView == self.globalTableView) ? @"global" : @"local";
    NSString *boardName = [NSString stringWithFormat:@"%@.%@", prefix,
                           [GameManager stringFromGameMode:self.scoreGameMode]];

    NSArray *scores = (self.boardStore.boards)[boardName];
    Score *score = scores[indexPath.row];

    cell.index = indexPath.row + 1;
    cell.userLabel.text = score.user;
    cell.scoreLabel.text = score.value;

    UIColor *color;
    color = indexPath.row % 2 ?
            [UIColor colorWithRed:41.0 / 255 green:40.0 / 255 blue:49.0 / 255 alpha:1.0] :
            [UIColor colorWithRed:53.0 / 255 green:53.0 / 255 blue:67.0 / 255 alpha:1.0];
    cell.userLabel.backgroundColor = color;
    cell.scoreLabel.backgroundColor = color;
    cell.indexLabel.backgroundColor = color;
    cell.contentView.backgroundColor = color;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


- (void)updateBoardButton {
    NSString *newLabel = self.segmentedIndex == 0 ? @"segment_local.png" :
                         @"segment_global.png";

    UIImage *image = [UIImage imageNamed:newLabel];
    [self.boardButton setImage:image forState:UIControlStateNormal];
}


- (IBAction)switchTable:(id)sender {
    self.segmentedIndex = (self.segmentedIndex + 1) % 2;
    [self updateBoardButton];
    [self reloadTables];
}


- (void)reloadTables {
    if (self.segmentedIndex == 0) {
        self.loadingView.hidden = YES;
        self.globalTableView.hidden = YES;
        [self reloadLocalTable];
    }
    else {
        self.localTableView.hidden = YES;
        self.loadingView.hidden = NO;
        [self.loadingView startAnimating];

        NSString *boardName = [NSString stringWithFormat:@"global.%@",
                               [GameManager stringFromGameMode:self.scoreGameMode]];
        [self.boardStore requestScoresForBoardNamed:boardName];
        [self reloadGlobalTable];
    }
    [self reloadGlobalTable];
}


- (void)reloadLocalTable {
    [self.localTableView reloadData];
    self.localTableView.hidden = ([self.localTableView numberOfRowsInSection:0] == 0) ||
                                 (self.segmentedIndex == 1);

    [self.localTableView flashScrollIndicators];
}


- (void)reloadGlobalTable {
    [self.globalTableView reloadData];
    self.globalTableView.hidden = ([self.globalTableView numberOfRowsInSection:0] == 0)
                                  || (self.segmentedIndex == 0);
    [self.globalTableView flashScrollIndicators];
}


- (void)updateGameModeButton {
    NSString *newLabel = nil;
    switch (self.scoreGameMode) {
        case kGameModeTimeAttackFlash: {
            newLabel = @"score_flash.png";
            break;
        }
        case kGameModeTimeAttackMedium: {
            newLabel = @"score_medium.png";
            break;
        }
        case kGameModeTimeAttackMarathon: {
            newLabel = @"score_marathon.png";
            break;
        }
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:newLabel];
    [self.gameModeButton setImage:image forState:UIControlStateNormal];
}


- (IBAction)changeGameMode:(id)sender {
    switch (self.scoreGameMode) {
        case kGameModeTimeAttackFlash: {
            self.scoreGameMode = kGameModeTimeAttackMedium;
            break;
        }
        case kGameModeTimeAttackMedium: {
            self.scoreGameMode = kGameModeTimeAttackMarathon;
            break;
        }
        case kGameModeTimeAttackMarathon: {
            self.scoreGameMode = kGameModeTimeAttackFlash;
            break;
        }
        default:
            break;
    }
    [self updateGameModeButton];
    [self reloadTables];
}


#pragma mark - Scores update
- (void)onGlobalBoardUpdate:(NSNotification *)theNotification {
    [self.loadingView stopAnimating];
    [self reloadGlobalTable];
}


@end
