//
//  CMGotoViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 04/04/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import "CMGotoViewController.h"

#import "CMButton+Meon.h"
#import "CMLevelViewCell.h"

@interface CMGotoViewController ()

@property (nonatomic, assign) BOOL hasScrolledToCurrentLevel;

@end

@implementation CMGotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasScrolledToCurrentLevel = NO;
    
    [self.cancelButton applyStyle:CMButtonMeonStyleNormal];

    NSString *title = NSLocalizedString(@"L_Cancel", );
    [self.cancelButton setTitle:title forState:UIControlStateNormal];
}


- (void)scrollToCurrentLevel {
    NSIndexPath *levelIndexPath = [NSIndexPath indexPathForRow:self.currentLevel
                                                     inSection:0];

    [self.levelsView scrollToItemAtIndexPath:levelIndexPath
                            atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                    animated:NO];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.levelsView flashScrollIndicators];
}


- (void)viewDidLayoutSubviews {

    CGFloat cellWidth = 76;
    CGFloat width = self.view.bounds.size.width;
    NSInteger numberOfCell = (NSInteger)(width / cellWidth);
    CGFloat totalMargin = width - (numberOfCell * cellWidth);
    CGFloat margin = MAX(floor(totalMargin / (numberOfCell + 1)), 3);
    CGFloat leftRight = totalMargin - (margin * (numberOfCell - 1));
    CGFloat left = floor(leftRight / 2);
    CGFloat right = leftRight - left;

    CGFloat top = margin;
    CGFloat bottom = margin;

    self.levelsViewLayout.sectionInset = UIEdgeInsetsMake(top, left, bottom, right);
    self.levelsViewLayout.minimumInteritemSpacing = margin;
    self.levelsViewLayout.minimumLineSpacing = margin;

    if (!self.hasScrolledToCurrentLevel) {
        self.hasScrolledToCurrentLevel = YES;
        [self scrollToCurrentLevel];
    }
}


- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 121;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didSelectLevel:controller:)]) {
        [self.delegate didSelectLevel:indexPath.row controller:self];
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    CMLevelViewCell *cell = [self.levelsView dequeueReusableCellWithReuseIdentifier:@"Level" forIndexPath:indexPath];

    NSString *imageName = nil;
    NSInteger level = indexPath.row;
    
    if (level < self.maximumLevel) {
        imageName = [NSString stringWithFormat:@"%03ld", (long)indexPath.row];
    }
    else if (level > self.maximumLevel) {
        imageName = @"Cadena";
    }
    else {
        imageName = @"Mini";
    }
    
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.level = level;
    return cell;
}
@end
