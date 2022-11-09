//
//  CMGotoViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 04/04/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CMButton.h"

@protocol CMGotoViewControllerDelegate;

@interface CMGotoViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *levelsView;
@property (nonatomic, weak) IBOutlet UICollectionViewFlowLayout *levelsViewLayout;
@property (nonatomic, weak) id<CMGotoViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentLevel;
@property (nonatomic, assign) NSUInteger maximumLevel;
@property (nonatomic, weak) IBOutlet CMButton *cancelButton;

@end


@protocol CMGotoViewControllerDelegate<NSObject>

- (void)didSelectLevel:(NSUInteger)level controller:(CMGotoViewController *)controller;

@end
