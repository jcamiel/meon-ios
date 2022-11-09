//
//  ModalViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 9/16/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "ModalViewController.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"

@implementation ModalViewController

- (void)loadView {
    CGRect frame = [UIViewController fullscreenFrame];

    UIImageView *view = [[UIImageView alloc] initWithFrame:frame];
    view.opaque = YES;
    view.image = [UIImage imageNamed:@"Default"];
    view.userInteractionEnabled = YES;
    self.view = view;

    [self addBackButton];
}

- (void)setBackButtonType:(ModalViewControllerType)type {
    _backButtonType  = type;
    [self addBackButton];
}

- (void)addBackButton {
    [self.cancelButton removeFromSuperview];
    self.cancelButton = nil;

    if (self.backButtonType == ModalViewControllerButtonNone) {
        return;
    }


    SEL action = (self.backButtonType == ModalViewControllerButtonBack) ?
                 @selector(back:) : @selector(cancel:);
    NSString *title = (self.backButtonType == ModalViewControllerButtonBack) ?
                      @"Back" : @"Cancel";
    NSString *imageName = (self.backButtonType == ModalViewControllerButtonBack) ?
                          @"back.png" : @"Common/cancel.png";

    self.cancelButton = [self addButton:CGPointZero
                         parent:self.view
                         title:title
                         action:action
                         defaultImageName:imageName
                         highlightedImageName:nil
                         autoresizingMask:0];

    if (self.backButtonType == ModalViewControllerButtonBack) {
        [self.cancelButton alignWithRightSideOf:self.view offset:2];
    }
    else {
        [self.cancelButton alignWithRightSideOf:self.view offset:-1];
        [self.cancelButton alignWithTopSideOf:self.view offset:-3];
    }

}

- (void)addHeaderImageNamed:(NSString *)imageName {
    UIImageView *headerView = [self addImageView:CGPointZero
                               parent:self.view
                               defaultImageName:imageName
                               highlightedImageName:nil
                               autoresizingMask:0];

    if (self.cancelButton) {
        NSUInteger cancelButtonIndex = [self.cancelButton subviewIndex];
        NSUInteger headerViewIndex = [headerView subviewIndex];

        [self.view exchangeSubviewAtIndex:cancelButtonIndex
         withSubviewAtIndex:headerViewIndex];
    }
}

- (IBAction)back:(id)sender {

}
- (IBAction)cancel:(id)sender {

}


@end
