//
//  EditorViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/18/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuildViewController.h"
#import "LevelManager.h"

@protocol EditorViewControllerDelegate;
@class GroundView, GameManager, Level, CompletedAnimator;

typedef enum  {
	kEditorModeMoveItem = 0,
    kEditorModeAddBlock = 1,
    kEditorModeRemove = 2,
    kEditorModeAddItem = 3,
    kEditorModePublishLevel = 4,
    kEditorModeUserInteractionDisabled = 5,
} EditorMode;


@interface EditorViewController : UIViewController< BuildViewControllerDelegate, 
                                                    LevelManagerDelegate> 

@property (nonatomic, strong) IBOutlet GroundView *groundView;
@property (nonatomic, strong) GameManager *gameManager;
@property (nonatomic, weak) id<EditorViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton *blockButton;
@property (nonatomic, strong) IBOutlet UIButton *eraserButton;
@property (nonatomic, strong) IBOutlet UIButton *addButton;
@property (nonatomic, strong) IBOutlet UIButton *themeButton;
@property (nonatomic, strong) IBOutlet UIButton *publishButton;
@property (nonatomic, strong) Level *level;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *publishingActivityView;

- (IBAction)addBlock:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)addItem:(id)sender;
- (IBAction)publishLevel:(id)sender;
- (IBAction)menu:(id)sender;
- (IBAction)theme:(id)sender;


@end


@protocol EditorViewControllerDelegate
- (void)editorSelectMenu:(EditorViewController*)controller;
@end
