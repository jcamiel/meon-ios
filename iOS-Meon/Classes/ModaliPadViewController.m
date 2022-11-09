//
//  ModaliPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/26/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ModaliPadViewController.h"
#import "UIView+Helper.h"

@interface ModaliPadViewController ()
@end

@implementation ModaliPadViewController




- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    self = [super initWithNibName:nibName bundle:nibBundle];
    if (self){
        self.useDoneButton = NO;
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    //-- add the background
    UIColor *color = [UIColor colorWithRed:40.0/255 green:39.0/255 blue:48.0/255 alpha:1.0];
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,620)];
    self.view.backgroundColor = color;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.opaque = YES;
    
    //-- add the cancel button
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGSize buttonSize = (CGSize){203, 110};
    CGRect frame = (CGRect){{0,0}, {buttonSize.width, buttonSize.height}};
    self.cancelButton.frame = frame;
    self.cancelButton.x = self.view.width - self.cancelButton.width + 2;
    self.cancelButton.y = 0;
    
    [self.cancelButton addTarget:self
               action:@selector(cancel:) 
     forControlEvents:UIControlEventTouchUpInside]; 
    
    NSString *imageName = self.useDoneButton ? @"Common/done~ipad.png" : @"Common/cancel~ipad.png";
    UIImage *defaultImage = [UIImage imageNamed:imageName];
    [self.cancelButton setImage:defaultImage forState:UIControlStateNormal];
    [self.view addSubview:self.cancelButton];
    
    
    //-- debug
    self.view.layer.borderColor = [color CGColor];
    self.view.layer.borderWidth = 1.0f;
}

#pragma mark - Actions
- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(modaliPadViewControllerCancel:)]){
        [self.delegate modaliPadViewControllerCancel:self];
    }
}

- (void)addHeaderImageNamed:(NSString*)imageName
{
    //-- add the header
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = (CGRect){{0,0},{540,108}};
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:imageView belowSubview:self.cancelButton];
}

- (CGFloat)headerHeight
{
    return 108.0;
}

@end
