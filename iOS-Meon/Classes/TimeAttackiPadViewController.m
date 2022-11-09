//
//  TimeAttackiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "TimeAttackiPadViewController.h"

#import "UIColor+Helper.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"
#import "ModaliPadViewController.h"



@interface TimeAttackiPadViewController ()

@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation TimeAttackiPadViewController

@dynamic delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addHeaderImageNamed:@"Common/timeattack_header@2x.png"];
    [self addText];
    [self addButtons];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void)addButtons
{
    
    UIButton *flashButton = [self addButton:CGPointZero
                                     parent:self.view 
                                      title:@"Flash - 20 levels"
                                     action:@selector(playFlash:)
                           defaultImageName:@"Common/timeattack_flash.png"
                       highlightedImageName:nil
                           autoresizingMask:0];
    
    [flashButton alignWithHorizontalCenterOf:self.view];
    [flashButton space:0 fromBottomSideOf:self.textLabel];

    UIButton *mediumButton = [self addButton:CGPointZero
                                      parent:self.view 
                                       title:@"Medium - 40 levels"
                                      action:@selector(playMedium:)
                            defaultImageName:@"Common/timeattack_medium.png"
                        highlightedImageName:nil
                            autoresizingMask:0];
    
    [mediumButton alignWithHorizontalCenterOf:self.view];
    [mediumButton space:12 fromBottomSideOf:flashButton];
    
    UIButton *marathonButton = [self addButton:CGPointZero
                                        parent:self.view 
                                         title:@"Marathon - 60 levels"
                                        action:@selector(playMarathon:)
                              defaultImageName:@"Common/timeattack_marathon.png"
                          highlightedImageName:nil
                              autoresizingMask:0];
    
    [marathonButton alignWithHorizontalCenterOf:self.view];
    [marathonButton space:12 fromBottomSideOf:mediumButton];
    
}

- (void)addText
{
    //-- add the label
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:30];

    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textLabel.numberOfLines = 0;

    NSString *text = NSLocalizedString(@"L_TimeAttack",);
    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
    NSRange searchRange = (NSRange){0, text.length};
    NSRange range = [text rangeOfString:@"Time Attack"
                                options:NSLiteralSearch
                                  range:searchRange];
    if (range.location != NSNotFound){
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexCode:0x00f0ff] range:range];
    }
    self.textLabel.attributedText = attrStr;
    [self.view addSubview:self.textLabel];

    // compute the frame
    CGFloat margin = 20.0;
    CGSize targetSize = (CGSize){self.view.width-2*margin};
    CGSize size = [self.textLabel sizeThatFits:targetSize];
    self.textLabel.frame = (CGRect){{0,0},{size.width, size.height}};
    [self.textLabel alignWithHorizontalCenterOf:self.view];
    [self.textLabel alignWithTopSideOf:self.view offset:margin + self.headerHeight];
    

}


- (IBAction)playFlash:(id)sender
{
    [self.delegate timeAttackiPadDidSelectPlayFlash:self];
}

- (IBAction)playMedium:(id)sender
{
    [self.delegate timeAttackiPadDidSelectPlayMedium:self];
    
}

- (IBAction)playMarathon:(id)sender
{
    [self.delegate timeAttackiPadDidSelectPlayMarathon:self];
}



@end
