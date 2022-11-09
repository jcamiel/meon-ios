//
//  PlayMenuViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/1/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "PlayMenuViewController.h"
#import "GameManager.h"

@implementation PlayMenuViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Actions

- (IBAction)playClassic:(id)sender
{
    [self.delegate playMenuDidSelectPlayClassic:self];
}

- (IBAction)playTimeAttack:(id)sender
{
    [self.delegate playMenuDidSelectPlayTimeAttack:self];
}

- (IBAction)playWorld:(id)sender
{
    [self.delegate playMenuDidSelectPlayWorld:self];
}

- (IBAction)back:(id)sender
{
    [self.delegate playMenuDidSelectBack:self];
}


@end
