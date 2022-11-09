//
//  BuildViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/22/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tile.h"


@protocol BuildViewControllerDelegate;

@interface BuildViewController : UIViewController

@property (nonatomic, weak) id<BuildViewControllerDelegate> delegate;
- (IBAction)addItem:(id)sender;


@end


@protocol BuildViewControllerDelegate
- (void)buildViewController:(BuildViewController*)controller didAddItem:(kTileType)item;
@end