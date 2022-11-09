//
//  ScoresViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/6/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameManager.h"
#import "ModalViewController.h"

@class BoardStore, MoreItemsTableViewCell, ScoresCell;
@protocol ScoresViewControllerDelegate;


@interface ScoresViewController : ModalViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) UIButton *boardButton;
@property (nonatomic, weak) id<ScoresViewControllerDelegate> delegate;
@property (nonatomic, strong) BoardStore *boardStore;
@property (nonatomic, strong) UITableView *localTableView;
@property (nonatomic, strong) UITableView *globalTableView;
@property (nonatomic, strong) UIButton *gameModeButton;
@property (nonatomic, assign) GameMode scoreGameMode;
@property (nonatomic, weak) IBOutlet ScoresCell *scoresCell;

- (IBAction)back:(id)sender;
- (IBAction)switchTable:(id)sender;
- (IBAction)changeGameMode:(id)sender;

@end


@protocol ScoresViewControllerDelegate
-(void)scoresDidSelectBack:(ScoresViewController*)controller;
@end