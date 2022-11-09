//
//  CMShareViewController.h
//  testshare
//
//  Created by Jean-Christophe Amiel on 8/16/13.
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, CMSharePopoverType) {
    CMSharePopoverBottom,
    CMSharePopoverLeft,
};

typedef void (^CMShareCompletionBlock)();

@interface CMShareViewController : UIViewController

@property (nonatomic, assign) CMSharePopoverType popoverType;
@property (nonatomic, copy) NSString *initialText;
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) CMShareCompletionBlock completionBlock;

- (void)presentShareViewAtPoint:(CGPoint)point
           parentViewController:(UIViewController *)controller
                     completion:(CMShareCompletionBlock)completionBlock;
- (void)dismissShareView;

@end
