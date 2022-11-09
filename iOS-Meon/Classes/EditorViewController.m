//
//  EditorViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/18/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "EditorViewController.h"
#import "GameManager.h"
#import "GroundView.h"
#import "Sprite.h"
#import "tile.h"
#import "BuildViewController.h"
#import "Level.h"
#import "LevelManager.h"
#import "UIView+Helper.h"
#import "CompletedAnimator.h"


@interface EditorViewController()

@property (nonatomic, strong) BuildViewController *buildViewController;
@property (nonatomic, strong) CompletedAnimator *completedAnimator;
@property (nonatomic, assign) EditorMode currentMode;
@property (nonatomic, copy) NSMutableDictionary* selectedSprites;

@end





@implementation EditorViewController


#pragma mark - View Lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.selectedSprites = [[NSMutableDictionary alloc] init];

	self.level = self.gameManager.currentLevel;
    
	self.groundView.dataSource = self.level.cells;

	self.level.layoutView = self.groundView;
	
    [self.gameManager loadLevel];

    LevelManager *levelManager = [LevelManager sharedLevelManager];
    levelManager.delegate = self;
    
    // create the published animator
    self.completedAnimator = [CompletedAnimator animator];
    self.completedAnimator.sloganImage = [UIImage imageNamed:@"Common/levelPublished.png"];
    self.completedAnimator.superLayer = self.view.layer;
    self.completedAnimator.ySlogan = 200.0;

    
	// check if the current edited level has already been published
    if (self.level.isPublished){
         [self.level empty];
    }
    if (levelManager.isPublishing){
        [self.publishingActivityView startAnimating];
    }
    
    
	[self.groundView setNeedsDisplay];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    LevelManager *levelManager = [LevelManager sharedLevelManager];
    levelManager.delegate = nil;
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.groundView = nil;
	self.publishButton = nil;
    self.blockButton = nil;
    self.eraserButton = nil;
    self.addButton = nil;
    self.themeButton = nil;
    self.publishButton = nil;
    self.publishingActivityView = nil;

}


- (void)dealloc
{
    DebugLog(@"EditorViewController dealloc");

    LevelManager *levelManager = [LevelManager sharedLevelManager];
    levelManager.delegate = nil;

	[self removeBuildView];
    
    [self.completedAnimator setAnimatorDidStopSelector:NULL withDelegate:nil];
    
}

#pragma mark -
#pragma mark Action

- (IBAction)menu:(id)sender
{
	[self.delegate editorSelectMenu:self];
}

- (void)transitionAnimationDidStopFrom:(NSString*)from to:(NSString*)to
{
}

#pragma mark -
#pragma mark Touch Managment

//kEditorModeMoveItem = 0,
//kEditorModeAddBlock = 1,
//kEditorModeRemove = 2,
//kEditorModeAddItem = 3,
//kEditorModePublishLevel = 4,

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}



#pragma mark -
#pragma mark Touches mode add block

- (void)touchesMovedModeAddBlock:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch *touch in touches){
		
		int colDst, rowDst;
		
		CGPoint pt = [touch locationInView:self.groundView];
		
		colDst = pt.x / 30;
		rowDst = pt.y / 30;
		
		if ((colDst < 1) || (colDst > 10) || (rowDst < 1) || (rowDst > 10))
			continue;

		
		if ([self.level tileAtCol:colDst row:rowDst] == kTileVoid){
			CGRect invalidRect = CGRectMake((colDst-1)*30.0,(rowDst-1)*30.0,
											30*3, 30*3);
			[self.level setTile:kTilePlain col:colDst row:rowDst];
			[self.groundView setNeedsDisplayInRect:invalidRect];
            [self.level updateLightsAndObjects];
		}
	}	
}

#pragma mark -
#pragma mark Touches mode remove

- (void)touchesMovedModeRemove:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch *touch in touches){
		
		int colDst, rowDst;
		
		CGPoint pt = [touch locationInView:self.groundView];
		
		colDst = pt.x / 30;
		rowDst = pt.y / 30;
		
		if ((colDst < 1) || (colDst > 10) || (rowDst < 1) || (rowDst > 10))
			continue;

		if ([self.level tileAtCol:colDst row:rowDst] != kTileVoid){
			CGRect invalidRect = CGRectMake((colDst-1)*30.0,(rowDst-1)*30.0,
											30*3, 30*3);
			[self.level setTile:kTileVoid col:colDst row:rowDst];
			[self.groundView setNeedsDisplayInRect:invalidRect];
			[self.level updateLightsAndObjects];
		}
	}	
}


#pragma mark -
#pragma mark Touches mode move item

-(void)touchesBeganModeMoveItem:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch *touch in touches){
		CGPoint pt = [touch locationInView:self.groundView];
		Sprite  *sprite = [self.level nearestSprite:pt 
														  inRadius:1.5*30 
													  meonFiltered:NO];
		if (!sprite) continue;
		
		NSNumber *key = @((unsigned int)touch.self);
		self.selectedSprites[key] = sprite;
		[sprite touchesBegan];
	}
	[self touchesMovedModeMoveItem:touches withEvent:event];
}

- (void)touchesMovedModeMoveItem:(NSSet *)touches withEvent:(UIEvent *)event
{
	int colDst, rowDst, colSrc, rowSrc;
	
	for(UITouch *touch in touches){
		
		NSNumber *key = @((unsigned int)touch.self);
		Sprite* selectedSprite = self.selectedSprites[key];
		CGPoint pt = [touch locationInView:self.groundView];
		
		colDst = pt.x / 30;
		rowDst = pt.y / 30;
		colSrc = selectedSprite.center.x / 30;
		rowSrc = selectedSprite.center.y / 30;
				
		// sanity check
		if (((colDst == colSrc) && (rowDst == rowSrc)) ||
			(colDst < 1) || (colDst > 10) || (rowDst < 1) || (rowDst > 10) ||
			!selectedSprite)
			continue;
		
		if ([self.level tileAtCol:colDst row:rowDst] >= kTilePlain)
			continue;
		
		selectedSprite.center = (CGPoint){(colDst * 30) + 15,(rowDst * 30) + 15};
		
		[self.level moveSprite:selectedSprite colSrc:colSrc rowSrc:rowSrc colDst:colDst rowDst:rowDst];
	}
	
	if ([self.level isCompleted]){
		DebugLog(@"Ready to publish");
		//self.publishButton.enabled = YES;
	}
	else {
		//self.publishButton.enabled = NO;
	}

}

- (void)touchesEndedModeMoveItem:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch *touch in touches){
		NSNumber *key = @((unsigned int)touch.self);
		[self.selectedSprites removeObjectForKey:key];
	}
}

- (void)touchesCancelledModeMoveItem:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self touchesEndedModeMoveItem:touches withEvent:event];
}


#pragma mark -
#pragma mark Touches mode add item
- (void)touchesBeganModeAddItem:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self removeBuildView];
    [self updateButtons];
    [self touchesBeganModeMoveItem:touches withEvent:event];
}


- (void)touchesMovedModeAddItem:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self removeBuildView];
    [self updateButtons];
    [self touchesMovedModeMoveItem:touches withEvent:event];
}

#pragma mark -
#pragma mark Touches mode UI disabled
- (void)touchesModeUIDisabled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.completedAnimator stop];
    
    self.currentMode = kEditorModeMoveItem;
    self.blockButton.userInteractionEnabled = YES;
    self.eraserButton.userInteractionEnabled = YES;
    self.addButton.userInteractionEnabled = YES;
    self.themeButton.userInteractionEnabled = YES;
    self.publishButton.userInteractionEnabled = YES;

    
    [UIView beginAnimations:@"newLevel" context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight 
                           forView:self.groundView 
                             cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(newLevelAnimationDidStop:finished:context:)];
    [self.level empty];
    [self.groundView setNeedsDisplay];
    [UIView commitAnimations];
}






#pragma mark -
#pragma mark Build

- (IBAction)build:(id)sender
{
	[self addBuildView];
}


- (void)addBuildView
{
	if (self.buildViewController) 
		return;
	
	self.buildViewController = [[BuildViewController alloc] initWithNibName:nil 
                                                                      bundle:nil];
	self.buildViewController.delegate = self;
	
	[self.buildViewController viewWillAppear:NO];
    self.buildViewController.view.y = 244;
	[self.view addSubview:self.buildViewController.view];
	[self.buildViewController viewDidAppear:NO];
}

- (void)removeBuildView
{
	[self.buildViewController viewWillDisappear:NO];
	[self.buildViewController.view removeFromSuperview];
	[self.buildViewController viewDidDisappear:NO];

	self.buildViewController = nil;
	
	if (self.currentMode == kEditorModeAddItem)
		self.currentMode = kEditorModeMoveItem;
}

- (void)buildViewController:(BuildViewController*)controller didAddItem:(kTileType)item
{
	int freeIndex = [self.level firstFreeTileIndex];
	int col = freeIndex % 12;
	int row = freeIndex / 12;
	
	[self.level createObjectSprite:item col:col row:row];
	[self.level updateLightsAndObjects];
}


- (IBAction)addBlock:(id)sender
{
	if (self.currentMode == kEditorModeAddItem){
		[self removeBuildView];
	}
    
    
	self.currentMode = (self.currentMode != kEditorModeAddBlock) ? kEditorModeAddBlock : kEditorModeMoveItem;
    
    [self updateButtons];
}

- (IBAction)remove:(id)sender
{
	if (self.currentMode == kEditorModeAddItem){
		[self removeBuildView];
	}
	
	self.currentMode = (self.currentMode != kEditorModeRemove) ? kEditorModeRemove : kEditorModeMoveItem;
    
    [self updateButtons];
   

}


- (IBAction)addItem:(id)sender
{
	if (self.currentMode == kEditorModeAddItem){
		[self removeBuildView];
		self.currentMode = kEditorModeMoveItem;
	}
	else {
		[self addBuildView];
		self.currentMode = kEditorModeAddItem;		
	}
    
    [self updateButtons];
   

}

- (IBAction)publishLevel:(id)sender
{
	// somme little UI cleanups
    if (self.currentMode == kEditorModeAddItem){
		[self removeBuildView];
	}
    self.currentMode = kEditorModeMoveItem;	
    [self updateButtons];
    
    
    
	if (![self.level isCompleted]) {
        DebugLog(@"Warning: level not completed");
        return;
    }
    else {
        self.currentMode = kEditorModeUserInteractionDisabled;	
    }
    
    // stop previous animation
    [self.completedAnimator stop];
    
    [self.publishingActivityView startAnimating];
    
    // disabled interaction on buttons:
    self.blockButton.userInteractionEnabled = NO;
    self.eraserButton.userInteractionEnabled = NO;
    self.addButton.userInteractionEnabled = NO;
    self.themeButton.userInteractionEnabled = NO;
    self.publishButton.userInteractionEnabled = NO;
    
    [[LevelManager sharedLevelManager] publish:self.level];
    
}

- (void)updateButtons
{
    NSString * imageName = nil;
    
    imageName = (self.currentMode == kEditorModeAddBlock) ? 
        @"Common/blockButtonOn.png" : @"Common/blockButton.png";
    
    [self.blockButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    imageName = (self.currentMode == kEditorModeRemove) ? 
        @"Common/eraserButtonOn.png" : @"Common/eraserButton.png";
    
    [self.eraserButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    
    imageName = (self.currentMode == kEditorModeAddItem) ? 
        @"Common/addButtonOn.png" : @"Common/addButton.png";
    
    [self.addButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}


- (IBAction)theme:(id)sender
{
    self.level.theme = (self.level.theme + 1) % 5;
	[self.groundView setNeedsDisplay];
}


- (UIImage*)levelImage
{	
	CGSize itemSize=CGSizeMake(30.0*12.0,30.0*12.0);
	UIGraphicsBeginImageContext(itemSize);

	[self.groundView drawRect:CGRectMake(0,0, 30.0*12.0,30.0*12.0)];
	
	UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return theImage;
	
}

#pragma mark -
#pragma mark LevelManagerDelegate

- (void)publishLevelDidSucceed:(LevelManager*)manager
{
    DebugLog(@"publishLevelDidSucceed");
    [self.publishingActivityView stopAnimating];
    [self.completedAnimator start];
    
}

- (void)newLevelAnimationDidStop:(NSString*)animationId finished:(BOOL)finished context:(void*)context
{
}




- (void)publishLevelDidFailed:(LevelManager*)manager
{
    DebugLog(@"publishLevelDidFailed");
    
    self.currentMode = kEditorModeMoveItem;
    self.blockButton.userInteractionEnabled = YES;
    self.eraserButton.userInteractionEnabled = YES;
    self.addButton.userInteractionEnabled = YES;
    self.themeButton.userInteractionEnabled = YES;
    self.publishButton.userInteractionEnabled = YES;

    
    //    NSString* msg = NSLocalizedString(@"PUBLISH SUCCEED", @"PUBLISH SUCCEDD");
    //    
    //    UIAlertView* av = [[UIAlertView alloc] initWithTitle:nil
    //                                                 message:msg
    //                                                delegate:nil
    //                                       cancelButtonTitle:@"OK"
    //                                       otherButtonTitles:nil];
    //    [av show];
    //    [av release];

}

#pragma mark -
#pragma mark Published animation
 -(void)publishedSloganAnimationDidStop
{

}

@end
