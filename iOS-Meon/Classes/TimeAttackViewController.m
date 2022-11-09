//
//  TimeAttackViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/13/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "TimeAttackViewController.h"
#import "UIColor+Helper.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"
#import "UIView+Motion.h"


@implementation TimeAttackViewController

- (void)dealloc
{
    _delegate = nil;
    _textLabel = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addHeaderImageNamed:@"Common/timeattack_header.png"];
    
    //-- add buttons
    UIButton *flashButton = [self addButton:(CGPoint){20,235}
                                     parent:self.view
                                      title:@"Timeattack Flash"
                                     action:@selector(playFlash:)
                           defaultImageName:@"Common/timeattack_flash.png"];
    [flashButton addParallaxEffect:15];
    
    UIButton *mediumButton = [self addButton:(CGPoint){20,305}
                                      parent:self.view
                                       title:@"Timeattack Medium"
                                      action:@selector(playMedium:)
                            defaultImageName:@"Common/timeattack_medium.png"];
    [mediumButton addParallaxEffect:15];
    
    UIButton *marathonButton = [self addButton:(CGPoint){20,375}
                                        parent:self.view
                                         title:@"Timeattack Marathon"
                                        action:@selector(playMarathon:)
                              defaultImageName:@"Common/timeattack_marathon.png"];
    [marathonButton addParallaxEffect:15];

    [self addText];

}

- (void)addText
{
    //-- add the label
    UIFont *font = [UIFont fontWithName:@"BradyBunchRemastered" size:22];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _textLabel.backgroundColor = [UIColor clearColor];
    _textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textLabel.numberOfLines = 0;
    
    NSString *text = NSLocalizedString(@"L_TimeAttack",);
    
    NSDictionary *defaultAttributes = @{NSFontAttributeName: font,
                                        NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:defaultAttributes];

    NSRange searchRange = (NSRange){0, text.length};
    NSRange range = [text rangeOfString:@"Time Attack"
                                options:NSLiteralSearch
                                  range:searchRange];
    if (range.location != NSNotFound){
        [attrStr addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexCode:0x00f0ff]} range:range];
    }
    _textLabel.attributedText = attrStr;
    [self.view addSubview:_textLabel];
    
    // compute the frame
    CGFloat margin = 26.0;
    CGSize targetSize = (CGSize){self.view.width-2*margin};
    CGSize size = [_textLabel sizeThatFits:targetSize];
    _textLabel.frame = (CGRect){{0,0},{size.width, size.height}};
    [_textLabel alignWithHorizontalCenterOf:self.view];
    _textLabel.y = 85;
    
    
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (IBAction)playFlash:(id)sender
{
    [_delegate timeAttackDidSelectPlayFlash:self];
}

- (IBAction)playMedium:(id)sender
{
    [_delegate timeAttackDidSelectPlayMedium:self];
}

- (IBAction)playMarathon:(id)sender
{
    [_delegate timeAttackDidSelectPlayMarathon:self];
}

- (IBAction)back:(id)sender
{
    [_delegate timeAttackDidSelectBack:self];
}


@end
