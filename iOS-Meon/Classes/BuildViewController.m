//
//  BuildViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/22/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "BuildViewController.h"

@interface BuildViewController()
- (void)loadButtonImage;
@end

@implementation BuildViewController


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self loadButtonImage];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}




- (IBAction)addItem:(id)sender
{
	if ([sender isKindOfClass:[UIButton class]]){
		UIButton *button = (UIButton*)sender;
		[self.delegate buildViewController:self didAddItem:(kTileType)(button.tag+1)];
	}
}

//	kTileVoid=0,
//	kTilePlain=1,
//	kTileGreenMeonS=2,
//	kTileGreenMeonW=3,
//	kTileGreenMeonN=4,
//	kTileGreenMeonE=5, 
//	kTileWhiteMeon=6,  
//	kTileRedMeon=7,  
//	kTileYellowMeon=8,  
//	kTileBlueMeon=9,  
//	kTileBrickRed=10,
//	kTileBrickYellow=11,
//	kTileBrickBlue=12,
//	kTileMirror1=13,    
//	kTileMirror2=14,
//	kTileSplitterS = 15,
//	kTileSplitterW = 16,
//	kTileSplitterN = 17,
//	kTileSplitterE = 18,
//	kTilePrismS = 19,
//	kTilePrismW = 20,
//	kTilePrismN = 21,
//	kTilePrismE = 22,

- (void)loadButtonImage
{
	NSArray *arrayStr = @[@"meon0-0-0-0",
								@"Sprites/meon1-0-0-0.png",
								@"Sprites/meon2-0-0-0.png",
								@"Sprites/meon3-0-0-0.png",
								@"Sprites/meon4-0-0-0_cropped.png",
								@"Sprites/meon5-0-0-0_cropped.png",
								@"Sprites/meon6-0-0-0_cropped.png",
								@"Sprites/meon7-0-0-0_croppedr.png",
								@"Sprites/brick0-0.png",
								@"Sprites/brick1-0.png",
								@"Sprites/brick2-0.png",
								@"Sprites/mirror1-0.png",
								@"Sprites/mirror2-0.png",
								@"Sprites/splitterS-0.png",
								@"Sprites/splitterW-0.png",
								@"Sprites/splitterN-0.png",
								@"Sprites/splitterE-0.png",
								@"Sprites/prismS-0.png",
								@"Sprites/prismW-0.png",
								@"Sprites/prismN-0.png",
								@"Sprites/prismE-0.png"];
								
	
	for(kTileType tile = kTileGreenMeonS; tile <= kTilePrismE; tile++){
		UIView * buttonView = [self.view viewWithTag:(NSInteger)(tile-1)];
		if ([buttonView isKindOfClass:[UIButton class]]){
			UIButton *button = (UIButton*)buttonView;
			NSString *buttonString = arrayStr[(int)(tile-kTileGreenMeonS)];
			UIImage *image = [UIImage imageNamed:buttonString];
			[button setImage:image forState:UIControlStateNormal];
		}
	}
}



@end
