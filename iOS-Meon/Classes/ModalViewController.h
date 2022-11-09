//
//  ModalViewController.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 9/16/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ModalViewControllerType) {
    ModalViewControllerButtonBack = 0,
    ModalViewControllerButtonCancel,
    ModalViewControllerButtonNone
    
};

@interface ModalViewController : UIViewController

- (void)addHeaderImageNamed:(NSString*)imageName;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, assign) ModalViewControllerType backButtonType;

@end
