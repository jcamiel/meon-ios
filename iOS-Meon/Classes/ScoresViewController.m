//
//  ScoresViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/6/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "BoardStore.h"
#import "MoreItemsTableViewCell.h"
#import "Score.h"
#import "ScoresCell.h"
#import "ScoresViewController.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"

@interface ScoresViewController ()

@property (nonatomic, assign) unsigned int segmentedIndex;

@end


@implementation ScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addHeaderImageNamed:@"Common/scores_header.png"];

    //-- locale tableView
    self.localTableView = [self addTableView:(CGRect){{32, 139}, {268, 289}}
                                      parent:self.view
                                  dataSource:self
                                    delegate:self];
    self.localTableView.backgroundColor = [UIColor colorWithRed:41.0 / 255
                                                          green:40.0 / 255
                                                           blue:49.0 / 255
                                                          alpha:1.0];
    self.localTableView.opaque = YES;
    self.localTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.localTableView.height = self.view.height - self.localTableView.y - 52;

    //-- global tableView
    self.globalTableView = [self addTableView:(CGRect){{32, 139}, {268, 289}}
                                       parent:self.view
                                   dataSource:self
                                     delegate:self];
    self.globalTableView.backgroundColor = [UIColor colorWithRed:41.0 / 255
                                                           green:40.0 / 255
                                                            blue:49.0 / 255
                                                           alpha:1.0];
    self.globalTableView.opaque = YES;
    self.globalTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.globalTableView.height = self.view.height - self.globalTableView.y - 52;

    //-- buttons
    self.gameModeButton = [self addButton:(CGPoint){10, 61}
                                     parent:self.view
                                      title:@"Flash"
                                     action:@selector(changeGameMode:)
                           defaultImageName:@"score_flash.png"
                       highlightedImageName:nil
                           autoresizingMask:0];


    [self addImageView:(CGPoint){0, 120}
                   parent:self.view
         defaultImageName:@"score_tableview_up.png"
     highlightedImageName:nil
         autoresizingMask:0];

    UIImageView *rightView = [self addImageView:(CGPoint){288, 150}
                                         parent:self.view
                               defaultImageName:@"score_tableview_right.png"
                           highlightedImageName:nil
                               autoresizingMask:0];

    rightView.height = self.view.height - rightView.y;
    UIImage *image = [rightView.image stretchableImageWithLeftCapWidth:5 topCapHeight:10];
    rightView.image = image;

    [self addImageView:(CGPoint){164, 80}
                   parent:self.view
         defaultImageName:@"change.png"
     highlightedImageName:nil
         autoresizingMask:0];


    self.boardButton = [self addButton:(CGPoint){10, 0}
                                  parent:self.view
                                   title:@"Flash"
                                  action:@selector(switchTable:)
                        defaultImageName:@"segment_local.png"
                    highlightedImageName:nil
                        autoresizingMask:0];
    [self.boardButton alignWithBottomSideOf:self.view offset:-7];

    self.loadingView = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.center = self.localTableView.center;
    [self.view addSubview:self.loadingView];


    self.scoreGameMode = kGameModeTimeAttackFlash;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGlobalBoardUpdate:)
                                                 name:GlobalBoardUpdate
                                               object:nil];

    self.localTableView.hidden = ([self.localTableView numberOfRowsInSection:0] == 0);

    self.localTableView.separatorColor = [UIColor darkGrayColor];
    self.globalTableView.separatorColor = [UIColor darkGrayColor];

    if ([self.localTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.localTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if ([self.globalTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.globalTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}


/*
   // Override to allow orientations other than the default portrait orientation.
   - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
   }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.localTableView = nil;
    self.globalTableView = nil;
    self.gameModeButton = nil;
    self.scoresCell = nil;
    self.boardButton = nil;
    self.loadingView = nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)back:(id)sender {
    [self.delegate scoresDidSelectBack:self];
}


#pragma mark - TableView Delegate

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *prefix = (tableView == self.globalTableView) ? @"global" : @"local";
    NSString *boardName = [NSString stringWithFormat:@"%@.%@", prefix,
                           [GameManager stringFromGameMode:self.scoreGameMode]];

    NSArray *scores = self.boardStore.boards[boardName];
    return scores.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"ScoresCell";
    ScoresCell *cell = nil;

    // generic case
    cell = (ScoresCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"ScoresCell" owner:self options:nil];
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
    cell.contentView.backgroundColor = color;
    cell.textLabel.backgroundColor = color;
    cell.detailTextLabel.backgroundColor = color;
    return cell;
}


- (IBAction)switchTable:(id)sender {
    self.segmentedIndex = (self.segmentedIndex + 1) % 2;

    NSString *newLabel = self.segmentedIndex == 0 ? @"segment_local.png" :
                         @"segment_global.png";

    UIImage *image = [UIImage imageNamed:newLabel];
    [self.boardButton setImage:image forState:UIControlStateNormal];

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


- (IBAction)changeGameMode:(id)sender {
    NSString *newLabel = nil;

    switch (self.scoreGameMode) {
        case kGameModeTimeAttackFlash: {
            self.scoreGameMode = kGameModeTimeAttackMedium;
            newLabel = @"score_medium.png";
            break;
        }
        case kGameModeTimeAttackMedium: {
            self.scoreGameMode = kGameModeTimeAttackMarathon;
            newLabel = @"score_marathon.png";
            break;
        }
        case kGameModeTimeAttackMarathon: {
            self.scoreGameMode = kGameModeTimeAttackFlash;
            newLabel = @"score_flash.png";
            break;
        }
        case kGameModeClassic:
        case kGameModeWorld:
        case kGameModeEditor:
            break;
    }
    UIImage *image = [UIImage imageNamed:newLabel];
    [self.gameModeButton setImage:image forState:UIControlStateNormal];
    [self reloadTables];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}


#pragma mark - Notifications methods

- (void)onGlobalBoardUpdate:(NSNotification *)theNotification {
    [self.loadingView stopAnimating];
    [self reloadGlobalTable];
}


@end
