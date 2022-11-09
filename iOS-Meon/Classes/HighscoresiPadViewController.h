//
//  HighscoresiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "ModaliPadViewController.h"
#import "GameManager.h"  
@class BoardStore, ScoresiPadCell;

@interface HighscoresiPadViewController : ModaliPadViewController<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong) UITableView *localTableView;
@property (nonatomic, strong) UITableView *globalTableView;
@property (nonatomic, assign) GameMode scoreGameMode;
@property (nonatomic, strong) BoardStore *boardStore;
@property (nonatomic, strong) IBOutlet ScoresiPadCell *scoresCell;
@property (nonatomic, strong) UIButton *boardButton;
@property (nonatomic, strong) UIButton *gameModeButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end
