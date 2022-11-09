//
//  GotoViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GotoCell.h"
#import "GameManager.h"
#import "ModalViewController.h"
@protocol GotoViewControllerDelegate;

@interface GotoViewController : ModalViewController<GotoCellDelegate,
                                                    UITableViewDataSource,
                                                    UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) IBOutlet GotoCell *genericCell;
@property (nonatomic, assign) NSUInteger maxLevel;
@property (nonatomic, weak) id<GotoViewControllerDelegate> delegate;
@property (nonatomic) NSUInteger currentLevel;
@property (nonatomic, strong) GameManager *gameManager;

- (IBAction)cancel:(id)sender;

@end



@protocol GotoViewControllerDelegate
- (void)didSelectLevel:(NSUInteger)level controller:(GotoViewController*)controller;
- (void)didCancel:(GotoViewController*)controller;
@end
