//
//  TutorialViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/15/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "TutorialViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "GameManager.h"
#import "UIView+Helper.h"

@interface TutorialViewController ()

@property (nonatomic, assign) CGFloat leftMargin;
@property (nonatomic, assign) CGFloat rightMargin;
@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, assign) CGFloat bottomMargin;
@property (nonatomic, assign) NSTimeInterval expandViewAnimationDuration;
@property (nonatomic, assign) NSTimeInterval fitToTextAnimationDuration;

@end


@implementation TutorialViewController


#pragma mark - UIViewController Lifecycle

- (void)loadView {
    BOOL isiPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    self.expandViewAnimationDuration = 0.2;
    self.fitToTextAnimationDuration = 0.2;

    self.leftMargin = isiPad ? 20 : 14;
    self.rightMargin = isiPad ? 85 : 49;
    self.topMargin = isiPad ? 20 : 20;
    self.bottomMargin = isiPad ? 70 : 48;
    CGFloat viewWidth = isiPad ? 500.0 : 320.0;
    CGFloat viewHeight = 480.0;
    CGFloat textWidth = viewWidth - self.leftMargin - self.rightMargin;
    CGFloat textHeight = viewHeight - self.topMargin - self.bottomMargin;
    CGFloat rectWidth = viewWidth;
    CGFloat rectHeight = viewHeight - 27;


    CGRect viewFrame = (CGRect){{0, 0}, {viewWidth, viewHeight}};

    UIView *aView = [[UIView alloc] initWithFrame:viewFrame];
    aView.backgroundColor = [UIColor clearColor];
    self.view = aView;

    //-- background rounded rect
    UIImage *imageTipBackground = [UIImage imageNamed:@"tip-background"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:imageTipBackground];
    backgroundView.frame = (CGRect){{0, 0}, {rectWidth, rectHeight}};
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleHeight;
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    self.backgroundView = backgroundView;
    [self.view addSubview:self.backgroundView];

    //-- text
    CGRect textLabelFrame = (CGRect){{self.leftMargin, self.topMargin}, {textWidth, textHeight}};
    UILabel *textLabel = [[UILabel alloc] initWithFrame:textLabelFrame];
    textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.opaque = YES;
    textLabel.backgroundColor = [UIColor colorWithRed:252.0 / 255 green:251.0 / 255 blue:179.0 / 255 alpha:1.0];
    textLabel.numberOfLines = 0;
    self.textLabel = textLabel;
    [self.view addSubview:self.textLabel];

    CGFloat normalFontSize = isiPad ? 30 : 18;
    CGFloat bigFontSize = isiPad ? 32 : 20;

    self.normalFont = [UIFont fontWithName:@"BradyBunchRemastered" size:normalFontSize];
    self.bigFont = [UIFont fontWithName:@"BradyBunchRemastered" size:bigFontSize];

    self.textLabel.hidden = YES;
    self.textLabel.shadowColor = [UIColor colorWithRed:251.0 / 255
                                                 green:179.0 / 255
                                                  blue:66.0 / 255
                                                 alpha:1.0];
    self.textLabel.shadowOffset = (CGSize){1, 2};


    //-- the blue Meon
    UIImage *meonImage = [UIImage imageNamed:@"Common/meon-tutorial.png"];
    UIImageView *meonImageView = [[UIImageView alloc] initWithImage:meonImage];
    CGFloat meonWidth = meonImageView.width;
    CGFloat meonHeight = meonImageView.height;
    meonImageView.frame = (CGRect){{viewWidth - meonWidth + 8, viewHeight - meonHeight + 11},
                                   {meonWidth, meonHeight}};

    meonImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.meonView = meonImageView;
    [self.view addSubview:self.meonView];


    self.meonView.hidden = YES;
    self.runningFitToTextAnimation = NO;
    self.runningExpandViewAnimation = NO;
}


- (void)loadFirstPage {
    [self loadPage:0 inSection:self.gameManager.tutorialSectionIndex];
    [self fitToTextAnimated:NO];
    [self expandViewAnimated:YES];
}


- (void)expandViewAnimated:(BOOL)animated {
    if (self.runningExpandViewAnimation) {
        return;
    }

    NSTimeInterval rectAnimationDuration = animated ? self.expandViewAnimationDuration : 0;
    self.runningExpandViewAnimation = YES;
    self.backgroundView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    self.textLabel.hidden = YES;

    DebugLog(@"expandViewAnimated:%d start", animated);
    [UIView animateWithDuration:rectAnimationDuration
                     animations:^{
         self.backgroundView.transform = CGAffineTransformIdentity;
     }
                     completion:^(BOOL finished){
         DebugLog(@"expandViewAnimated:%d stop", animated);
         self.textLabel.hidden = NO;
         self.runningExpandViewAnimation = NO;
     }
    ];


    self.meonView.hidden = NO;
    self.meonView.x = self.view.width;
    [UIView animateWithDuration:0.5
                     animations:^{
         self.meonView.x = self.view.width - self.meonView.width + 8;
     }
    ];
}


- (void)loadPage:(NSInteger)page inSection:(NSInteger)section {
    UIColor *textColor = [UIColor colorWithRed:0.0 / 255
                                         green:71.0 / 255
                                          blue:216.0 / 255
                                         alpha:1.0];


    UIColor *highlightColor = [UIColor colorWithRed:139.0 / 255
                                              green:12.0 / 255
                                               blue:237.0 / 255
                                              alpha:1.0];

    NSString *newText = [self.gameManager tutorialTextAtSection:section page:page];
    NSArray *highlights = [self.gameManager highlightedTextsAtSection:section page:page];

    NSDictionary *attributes = @{NSFontAttributeName: self.normalFont, NSForegroundColorAttributeName: textColor};
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:newText attributes:attributes];

    //-- set highlight on each part if the string
    NSRange searchRange = (NSRange){0, newText.length};
    for(NSString *highlight in highlights) {
        NSRange range = [newText rangeOfString:highlight
                                       options:NSLiteralSearch
                                         range:searchRange];
        if (range.location != NSNotFound) {
            [attrStr addAttributes:@{NSFontAttributeName: self.bigFont, NSForegroundColorAttributeName: highlightColor} range:range];
            searchRange.location = range.location + range.length;
            searchRange.length = newText.length - searchRange.location;
        }
    }

    CGFloat textWidth = self.view.width - self.leftMargin - self.rightMargin;
    CGFloat textHeight = self.view.height - self.topMargin - self.bottomMargin;
    self.textLabel.attributedText = attrStr;
    self.textLabel.frame = (CGRect){{self.leftMargin, self.rightMargin}, {textWidth, textHeight}};
    [self.textLabel sizeToFit];
    self.textLabel.x = self.leftMargin;
    self.textLabel.y = self.topMargin;
    self.textLabel.width = textWidth;
    self.textLabel.hidden = YES;
}


- (void)fitToTextAnimated:(BOOL)animated {
    if (self.runningFitToTextAnimation) {return; }

    self.textLabel.y = self.view.height - self.textLabel.height - self.bottomMargin;

    NSTimeInterval duration = animated ? self.fitToTextAnimationDuration : 0;

    if (self.runningExpandViewAnimation) {self.textLabel.hidden = YES; }
    self.runningFitToTextAnimation = YES;

    DebugLog(@"fitToTextAnimated:%d start", animated);


    [UIView animateWithDuration:duration
                     animations:^{
         self.backgroundView.frame = CGRectMake(self.backgroundView.x,
                                                self.view.height - self.textLabel.height - self.topMargin - self.bottomMargin,
                                                self.textLabel.width + 2 * self.leftMargin,
                                                self.textLabel.height + 2 * self.topMargin);
     }
                     completion:^(BOOL finished){
         DebugLog(@"fitToTextAnimated:%d stop", animated);
         if (!self.runningExpandViewAnimation) { self.textLabel.hidden = NO; }
         self.runningFitToTextAnimation = NO;
     }
    ];
}


- (void)nextPage {
    if (self.textLabel.hidden) {
        return;
    }

    self.gameManager.tutorialPageIndex++;
    [self.delegate tutorialDidChangePage:self];

    if (self.gameManager.tutorialPageIndex >= [self.gameManager numberOfPageInSectionForTutorial:
                                               self.gameManager.tutorialSectionIndex]) {

        self.gameManager.tutorialSectionIndex++;
        self.gameManager.tutorialPageIndex = 0;
        [self.delegate tutorialDidChangeSection:self];

        if (self.gameManager.tutorialSectionIndex >= [self.gameManager numberOfSectionForTutorial]) {
            [self.delegate tutorialDidFinish:self];
            return;
        }
    }

    [self loadPage:self.gameManager.tutorialPageIndex
         inSection:self.gameManager.tutorialSectionIndex];
    [self fitToTextAnimated:(self.gameManager.tutorialPageIndex > 0)];
}


@end
