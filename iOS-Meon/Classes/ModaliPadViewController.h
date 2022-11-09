//
//  ModaliPadViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/26/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModaliPadViewControllerDelegate;

@interface ModaliPadViewController : UIViewController

@property(nonatomic, weak) id<ModaliPadViewControllerDelegate> delegate;
@property(nonatomic, strong) UIButton* cancelButton;
@property(nonatomic, assign) BOOL useDoneButton;
@property(nonatomic, readonly) CGFloat headerHeight;

- (void)addHeaderImageNamed:(NSString*)imageName;
- (IBAction)cancel:(id)sender;

@end

@protocol ModaliPadViewControllerDelegate<NSObject>
@optional
- (void)modaliPadViewControllerCancel:(ModaliPadViewController*)controller;
@end

