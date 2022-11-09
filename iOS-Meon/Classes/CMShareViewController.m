//
//  CMShareViewController.m
//  testshare
//
//  Created by Jean-Christophe Amiel on 8/16/13.
//  Copyright (c) 2013 Manbolo. All rights reserved.
//
#import "CMShareViewController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "UIColor+Helper.h"
#import "UIView+Helper.h"
#import "UIView+Motion.h"
#import "UIViewController+Helper.h"


@interface CMShareViewController ()

@property (nonatomic, weak) UIViewController *originViewController;
@property (nonatomic, strong) UIView *popoverView;
@property (nonatomic, assign) CGPoint popoverAnchorPoint;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) CGFloat yInset;

@end

@implementation CMShareViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.animationDuration = 0.15;
        self.popoverType = CMSharePopoverLeft;
        [self isWeiboAvailable];
    }
    return self;
}

- (void)loadView {
    CGRect frame = [UIViewController fullscreenFrame];
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.view.userInteractionEnabled = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentShareViewAtPoint:(CGPoint)point
           parentViewController:(UIViewController *)controller
                     completion:(CMShareCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;

    self.popoverAnchorPoint = point;

    [controller addChildViewController:self];
    self.originViewController = controller;

    [self viewWillAppear:YES];
    [self.originViewController viewWillDisappear:YES];

    [self.originViewController.view addSubview:self.view];

    [self showPopoverAnimated:YES];

    self.view.alpha = 0.0;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
         self.view.alpha = 1.0;
     }

                     completion:^(BOOL finished){
         [self.originViewController viewWillDisappear:YES];
         [self viewDidAppear:YES];
     }];
}

- (void)dismissShareView {
    [self.originViewController viewWillAppear:YES];
    [self viewWillDisappear:YES];

    self.view.alpha = 1.0;
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
         self.view.alpha = 0.0;
     }

                     completion:^(BOOL finished){
         [self.view removeFromSuperview];
         [self.originViewController viewDidAppear:YES];
         [self viewDidDisappear:YES];
         [self removeFromParentViewController];
         self.originViewController = nil;
         if (self.completionBlock) {
             self.completionBlock();
         }
     }];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissShareView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self dismissShareView];
}

#pragma mark - Popover managment

- (void)showPopoverAnimated:(BOOL)animated {
    if (!self.popoverView) {
        [self addPopoverView];
    }

    self.popoverView.alpha = 0;
    self.popoverView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    CGFloat duration = animated ? self.animationDuration : 0;
    [UIView animateWithDuration:duration
                     animations:^{
         self.popoverView.alpha = 1.0;
         self.popoverView.transform = CGAffineTransformIdentity;
     }

                     completion:^(BOOL finished){
     }];

}

- (void)addPopoverView {
    if (self.popoverView) {
        return;
    }

    BOOL isWeiboAvailable = [self isWeiboAvailable];
    CGFloat frameWidth = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 170 : 250;
    CGFloat numberOfButtons = isWeiboAvailable ? 3 : 2;
    CGFloat arrowDelta = 17;
    CGFloat shadowBorder = 12;
    CGFloat width = (self.popoverType == CMSharePopoverBottom) ? frameWidth : frameWidth + arrowDelta;
    CGFloat buttonHeight = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 45 : 72;
    CGFloat buttonSpace = 8;
    CGFloat buttonsHeight = (numberOfButtons * buttonHeight)  + ((numberOfButtons+1) * buttonSpace) + 2*shadowBorder;
    CGFloat height = (self.popoverType == CMSharePopoverBottom) ? buttonsHeight + arrowDelta : buttonsHeight;
    self.yInset = (numberOfButtons == 2) ? 0 : 60;

    // Always insure our popoverView has even dimension so our view is well
    // aligned on non retina screen.
    if (((int)width % 2)== 1) {
        width += 1;
    }
    if (((int)height % 2)== 1) {
        height += 1;
    }

    // Create our popover view.
    CGRect frame = CGRectMake(0, 0, width, height);
    self.popoverView = [[UIView alloc] initWithFrame:frame];
    self.popoverView.alpha = 0;
    self.popoverView.userInteractionEnabled = YES;
    [self.view addSubview:self.popoverView];


    self.popoverView.layer.anchorPoint = (self.popoverType == CMSharePopoverBottom) ?
                                         CGPointMake(0.5, 1) : CGPointMake(0, (self.yInset + (height/2)) / height);

    // Position our popover to its anchor point.
    self.popoverView.center = CGPointMake(self.popoverAnchorPoint.x, self.popoverAnchorPoint.y);

    [self addBackgroundView];

    CGFloat x = (self.popoverType == CMSharePopoverBottom) ? 20 : 20 + arrowDelta;

    // Add Twitter button
    UIButton *weiboButton = nil;
    if (isWeiboAvailable) {
        weiboButton = [self addButton:CGPointZero
                                 parent:self.popoverView
                                  title:nil
                                 action:@selector(shareOnWeibo:)
                       defaultImageName:@"Common/CMShareWeibo.png"];
        weiboButton.x = x;
        weiboButton.y = 20;
    }


    // Add Twitter button
    UIButton *twitterButton = [self addButton:CGPointZero
                                         parent:self.popoverView
                                          title:nil
                                         action:@selector(shareOnTwitter:)
                               defaultImageName:@"Common/CMShareTwitter.png"];
    twitterButton.x = x;
    twitterButton.y = isWeiboAvailable ? weiboButton.y + weiboButton.height + buttonSpace : 20;

    // Add Facebook button
    UIButton *facebookButton = [self addButton:CGPointZero
                                          parent:self.popoverView
                                           title:nil
                                          action:@selector(shareOnFacebook:)
                                defaultImageName:@"Common/CMShareFacebook.png"];
    facebookButton.x = x;
    facebookButton.y = twitterButton.y + twitterButton.height + buttonSpace;
}

- (void)addLayerImageNamed:(NSString *)name frame:(CGRect)frame {
    UIImage *image = [UIImage imageNamed:name];
    CALayer *layer = [CALayer layer];
    layer.contents = (id)image.CGImage;
    layer.frame = frame;
    [self.popoverView.layer addSublayer:layer];
}

- (void)addLayerColor:(UIColor *)color frame:(CGRect)frame {
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = color.CGColor;
    layer.frame = frame;
    [self.popoverView.layer addSublayer:layer];
}

- (void)addBackgroundView {
    CGRect frame;
    CGFloat cornerWidth = 30;
    CGFloat cornerHeight = 30;
    CGFloat arrowDelta = 17;
    CGFloat popoverWidth = (self.popoverType == CMSharePopoverBottom) ? self.popoverView.width : self.popoverView.width - arrowDelta;
    CGFloat popoverHeight = (self.popoverType == CMSharePopoverBottom) ? self.popoverView.height - arrowDelta : self.popoverView.height;
    CGFloat popoverX = (self.popoverType == CMSharePopoverBottom) ? 0 : arrowDelta;

    // Up left corner.
    frame = CGRectMake(popoverX, 0, cornerWidth, cornerHeight);
    [self addLayerImageNamed:@"Common/PopoverCornerUpLeft.png" frame:frame];

    // Up right corner.
    frame = CGRectMake(popoverWidth - cornerWidth + popoverX, 0, cornerWidth, cornerHeight);
    [self addLayerImageNamed:@"Common/PopoverCornerUpRight.png" frame:frame];

    // Down left corner.
    frame = CGRectMake(popoverX, popoverHeight - cornerHeight, cornerWidth, cornerHeight);
    [self addLayerImageNamed:@"Common/PopoverCornerDownLeft.png" frame:frame];

    // Down right corner.
    frame = CGRectMake(popoverWidth - cornerWidth + popoverX, popoverHeight - cornerHeight, cornerWidth, cornerHeight);
    [self addLayerImageNamed:@"Common/PopoverCornerDownRight.png" frame:frame];

    // Center.
    UIColor *color = [UIColor colorWithHexCode:0x252c40];
    frame = CGRectMake(cornerWidth + popoverX, cornerHeight, popoverWidth - 2*cornerWidth, popoverHeight - 2*cornerHeight);
    [self addLayerColor:color frame:frame];

    // Up border.
    frame = CGRectMake(cornerWidth + popoverX, 0, popoverWidth - 2*cornerWidth, cornerHeight);
    [self addLayerImageNamed:@"Common/PopoverUp.png" frame:frame];

    // Down border.
    if (self.popoverType == CMSharePopoverBottom) {
        CGFloat arrowWidth = 58;
        CGFloat arrowHeight = 47;
        frame = CGRectMake(cornerWidth, popoverHeight - cornerHeight, (popoverWidth-arrowWidth)/2 - cornerWidth, cornerHeight);
        [self addLayerImageNamed:@"Common/PopoverDown.png" frame:frame];

        frame = CGRectMake(popoverWidth/2+(arrowWidth/2), popoverHeight - cornerHeight, (popoverWidth-arrowWidth)/2 - cornerWidth, cornerHeight);
        [self addLayerImageNamed:@"Common/PopoverDown.png" frame:frame];

        frame = CGRectMake((popoverWidth-arrowWidth)/2, popoverHeight - cornerHeight, arrowWidth, arrowHeight);
        [self addLayerImageNamed:@"Common/PopoverArrowBottom.png" frame:frame];
    }
    else {
        frame = CGRectMake(cornerWidth + popoverX, popoverHeight - cornerHeight, popoverWidth - 2*cornerWidth, cornerHeight);
        [self addLayerImageNamed:@"Common/PopoverDown.png" frame:frame];
    }

    // Left border.
    if (self.popoverType == CMSharePopoverLeft) {
        CGFloat arrowWidth = 47;
        CGFloat arrowHeight = 58;

        frame = CGRectMake(popoverX, cornerHeight, cornerWidth, (popoverHeight-arrowHeight)/2 - cornerHeight + self.yInset);
        [self addLayerImageNamed:@"Common/PopoverLeft.png" frame:frame];

        frame = CGRectMake(popoverX, (popoverHeight + arrowHeight)/2 + self.yInset, cornerWidth, (popoverHeight-arrowHeight)/2 - cornerHeight - self.yInset);
        [self addLayerImageNamed:@"Common/PopoverLeft.png" frame:frame];

        frame = CGRectMake(0, (popoverHeight - arrowHeight)/2 + self.yInset, arrowWidth, arrowHeight);
        [self addLayerImageNamed:@"Common/PopoverArrowLeft.png" frame:frame];

    }
    else {
        frame = CGRectMake(0, cornerHeight, cornerWidth, popoverHeight - 2*cornerHeight);
        [self addLayerImageNamed:@"Common/PopoverLeft.png" frame:frame];
    }

    // Right border.
    frame = CGRectMake(popoverX + popoverWidth - cornerWidth, cornerHeight, cornerWidth, popoverHeight - 2*cornerHeight);
    [self addLayerImageNamed:@"Common/PopoverRight.png" frame:frame];

}

#pragma mark - Actions

- (IBAction)shareOnTwitter:(id)sender {
    [self shareOnService:SLServiceTypeTwitter];
}

- (IBAction)shareOnFacebook:(id)sender {
    [self shareOnService:SLServiceTypeFacebook];
}

- (IBAction)shareOnWeibo:(id)sender {
    [self shareOnService:SLServiceTypeSinaWeibo];
}

- (void)shareOnService:(NSString *)service {
    // First dismiss our controlle
    [self dismissShareView];

    // Then present the Twitter view controller
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:service];
    if (!controller) {
        return;
    }
    controller.completionHandler = ^(SLComposeViewControllerResult result) {
        [self.originViewController dismissViewControllerAnimated:YES completion:nil];
    };

    if (self.initialText) {
        [controller setInitialText:self.initialText];
    }
    if (self.URLString) {
        NSURL *url = [NSURL URLWithString:self.URLString];
        [controller addURL:url];
    }

    [self.originViewController presentViewController:controller
                                            animated:YES
                                          completion:nil];
}

- (BOOL)isWeiboAvailable {
    // Test if Weibo is available. Returns YES if the current keyboard language
    // is chinese, or if the Weibo app is available; NO otherwise.
    NSArray * inputModes = [UITextInputMode activeInputModes];
    for(UITextInputMode *inputMode in inputModes) {
        NSString *primaryLanguage = inputMode.primaryLanguage;
        if ([primaryLanguage hasPrefix:@"zh"]) {
            return YES;
        }
    }

    // No chinese keyboard. Test with Weibo URL scheme.
    NSURL *url = [NSURL URLWithString:@"weibo://"];
    BOOL ret = [[UIApplication sharedApplication] canOpenURL:url];
    return ret;
}

@end
