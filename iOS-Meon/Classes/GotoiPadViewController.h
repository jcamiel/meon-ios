//
//  GotoiPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 9/17/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "GameManager.h"
#import "ModaliPadViewController.h"
#import "SimpleGotoCell.h"
#import <UIKit/UIKit.h>

@class GotoiPadViewController;


@protocol GotoiPadViewControllerDelegate <ModaliPadViewControllerDelegate>
@optional
- (void)gotoDidSelectLevel:(NSUInteger)level controller:(GotoiPadViewController *)controller;

@end

@interface GotoiPadViewController : ModaliPadViewController<UITableViewDelegate,
                                                            UITableViewDataSource,
                                                            SimpleGotoCellDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet SimpleGotoCell *genericCell;
@property (nonatomic, assign) NSUInteger maxLevel;
@property (nonatomic) NSUInteger currentLevel;
@property (nonatomic, weak) id<GotoiPadViewControllerDelegate> delegate;
@property (nonatomic, strong) GameManager *gameManager;

@end



