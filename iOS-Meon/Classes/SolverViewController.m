//
//  SolverViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/5/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "SolverViewController.h"
#import "MKStoreManager.h"
#import "Reachability.h"
#import "UIColor+Helper.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"



@implementation SolverViewController



- (void)loadView
{
    [super loadView];
    
    [self addHeaderImageNamed:@"Common/solverHeader.png"];
	self.backButtonType = ModalViewControllerButtonCancel;

    self.spinner = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.x = 141;
    self.spinner.y = 324;
    self.spinner.hidden = YES;
    [self.view addSubview:self.spinner];

    UIImageView *bottomView = [self addImageView:CGPointZero
                                          parent:self.view
                                defaultImageName:@"Common/solver_bottom.png"
                            highlightedImageName:nil
                                autoresizingMask:0];
    [bottomView alignWithBottomSideOf:self.view];
    
    CGRect frame = (CGRect){{14,73},{292,239}};
    self.connectedView = [[UILabel alloc] initWithFrame:frame];
    self.connectedView.backgroundColor = [UIColor clearColor];
    self.connectedView.numberOfLines = 0;
    [self.view addSubview:self.connectedView];

    self.unlockButton = [self addButton:(CGPoint){90,310}
                                 parent:self.view
                                  title:@"Unlock"
                                 action:@selector(buy:)
                       defaultImageName:@"Common/unlock.png"
                   highlightedImageName:nil
                       autoresizingMask:0];
    
    frame = (CGRect){{14,189},{292,66}};
    self.connectingView = [[UILabel alloc] initWithFrame:frame];
    [self.view addSubview:self.connectingView];
    self.connectingView.numberOfLines = 0;
    self.connectingView.textAlignment = NSTextAlignmentCenter;
    self.connectingView.lineBreakMode = NSLineBreakByWordWrapping;
    self.connectingView.backgroundColor = [UIColor clearColor];
    self.connectingView.textColor = [UIColor whiteColor];
    
    frame = (CGRect){{14,168},{292,125}};
    self.errorView = [[UILabel alloc] initWithFrame:frame];
    [self.view addSubview:self.errorView];
    self.errorView.numberOfLines = 0;
    self.errorView.textAlignment = NSTextAlignmentLeft;
    self.errorView.lineBreakMode = NSLineBreakByTruncatingTail;
    self.errorView.backgroundColor = [UIColor clearColor];
    self.errorView.textColor = [UIColor whiteColor];
    
    self.thankyouView = [self addImageView:(CGPoint){67,176}
                                    parent:self.view
                          defaultImageName:@"Common/thankyou.png"
                      highlightedImageName:nil
                          autoresizingMask:0];
    self.thankyouView.hidden = YES;
    
    frame = (CGRect){{8,230},{305,42}};
    self.thankyouLabel = [[UILabel alloc] initWithFrame:frame];
    [self.view addSubview:self.thankyouLabel];
    self.thankyouLabel.numberOfLines = 1;
    self.thankyouLabel.textAlignment = NSTextAlignmentCenter;
    self.thankyouLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.thankyouLabel.backgroundColor = [UIColor clearColor];
    self.thankyouLabel.textColor = [UIColor whiteColor];
    self.thankyouLabel.hidden = YES;
    
    
    //-- fonts
    CGFloat normalFontSize = 22;
    CGFloat bigFontSize = 24;
    self.normalFont = [UIFont fontWithName:@"BradyBunchRemastered" size:normalFontSize];
    self.bigFont = [UIFont fontWithName:@"BradyBunchRemastered" size:bigFontSize];
    
	// register to application did become active
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidBecomeActive:) 
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
	
	self.unlockButton.enabled = NO;
	self.unlockButton.hidden  = YES;
	
    self.connectingView.text = NSLocalizedString(@"L_SolverWaitForConnection",);
    self.connectingView.font = self.normalFont;
    
    self.errorView.text = NSLocalizedString(@"L_SolverNoConnection",);
    self.errorView.font = self.normalFont;
    
    self.thankyouLabel.text = NSLocalizedString(@"L_SolverLevelUnlocked",);
    self.thankyouLabel.font = self.normalFont;
    
	[MKStoreManager setDelegate:self];	

	[self updateSpinnerAndText];
    
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


- (void)viewDidAppear:(BOOL)animated
{
	DebugLog(@"viewDidAppear");

	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	DebugLog(@"viewDidDisappear");

	[super viewDidDisappear:animated];
	[self.delegate solverDidDisappear:self];
}


- (void)dealloc {

	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[MKStoreManager setDelegate:nil];	
		
}

- (IBAction)cancel:(id)sender
{
	[self.delegate solverDidSelectCancel:self];
}

- (IBAction)buy:(id)sender
{
	[UIView beginAnimations:@"cancel" context:NULL];
	self.cancelButton.alpha = 0.0;
	self.unlockButton.alpha = 0.0;
	[UIView commitAnimations];
	[self.spinner startAnimating];
	
	// Contacting the App Store...
	
#if TARGET_IPHONE_SIMULATOR
	DebugLog(@"Buy on simulator");
	
	[self performSelector:@selector(productPurchased:)
			   withObject:self
			   afterDelay:5.0];
#else
	[[MKStoreManager sharedManager] buyFeature:self.productId];
#endif
	
	
}

- (void)applicationDidBecomeActive:(NSNotification*)theNotification
{
	// if product purchased, automatic hide the controller
	if ([[MKStoreManager sharedManager] canConsumeProduct:self.productId quantity:1]){
		[self cancel:nil]; 
	}
}

- (void)updateBuyTextWithPrice:(NSString*)price
{
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"L_Solver",), price];   
    UIColor *textColor = [UIColor whiteColor];
    UIColor *highlightColor = [UIColor colorWithHexCode:0x00FFFF];
    
    NSArray *highlights = @[NSLocalizedString(@"L_Solver_Highlight_1",),
                           NSLocalizedString(@"L_Solver_Highlight_2",)];
    
    NSDictionary *defaultAttributes = @{ NSForegroundColorAttributeName: textColor,
                                         NSFontAttributeName: self.normalFont};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:defaultAttributes];
    
    [attrStr beginEditing];
    
    //-- set highlight on each part if the string
    NSRange searchRange = (NSRange){0, text.length};
    for(NSString *highlight in highlights){
        NSRange range = [text rangeOfString:highlight
                                    options:NSLiteralSearch
                                      range:searchRange];
        if (range.location != NSNotFound){
            [attrStr addAttributes:@{NSForegroundColorAttributeName:highlightColor, NSFontAttributeName:self.bigFont}
                           range:range];
            searchRange.location = range.location + range.length;
            searchRange.length = text.length - searchRange.location;
        }
    }
    [attrStr endEditing];
    
    self.connectedView.attributedText = attrStr;
}


#pragma mark - MKStoreKitDelegate delegate

- (void)productFetchComplete
{
	DebugLog(@"productFetchComplete");
	
	[self updateSpinnerAndText];

}

- (void)productPurchased:(NSString *)productId
{
	DebugLog(@"productPurchased id=%@", productId);
	
	self.cancelButton.titleLabel.text = @"Done";
	[self.cancelButton setImage:[UIImage imageNamed:@"Common/done.png"]
				   forState:UIControlStateNormal];
	
	[UIView beginAnimations:@"cancel" context:NULL];
	self.cancelButton.alpha = 1.0;
	[UIView commitAnimations];
	
	[self.spinner stopAnimating];

	self.thankyouView.hidden = NO;
    self.thankyouLabel.hidden = NO;
	self.connectedView.hidden = YES;
}

- (void)transactionCanceled
{
	DebugLog(@"transactionCanceled");
	[UIView beginAnimations:@"cancel" context:NULL];
	self.cancelButton.alpha = 1.0;
	self.unlockButton.alpha = 1.0;
	[UIView commitAnimations];
	
	[self updateSpinnerAndText];
}

- (void)updateSpinnerAndText
{
	MKStoreManager* storeManager = [MKStoreManager sharedManager];
    if (storeManager.isProductsAvailable){
		[self.spinner stopAnimating];
		
		
		NSDictionary* description = [storeManager purchasableObjectsDescription];
		NSDictionary* product = description[self.productId];
		
        NSString *localizedPrice = product[@"localizedPrice"];
        [self updateBuyTextWithPrice:localizedPrice];
		self.connectedView.hidden = NO;
		self.connectingView.hidden = YES;
		self.errorView.hidden = YES;
		self.unlockButton.enabled = YES;
		self.unlockButton.hidden = NO;
	}
	else {
		BOOL networkAvailable = [self networkAvailable];

		self.unlockButton.enabled = NO;
		self.unlockButton.hidden = YES;
		self.connectedView.hidden = YES;
		self.connectingView.hidden = !networkAvailable;
		self.errorView.hidden = networkAvailable;

		if (networkAvailable) {
            [self.spinner startAnimating];
        }
        else {
            [self.spinner stopAnimating];   
        }
	}
	
#if TARGET_IPHONE_SIMULATOR
	self.unlockButton.enabled = YES;	
#endif	
}

#pragma mark - Network
			
- (BOOL)networkAvailable
{
	NetworkStatus status = [Reachability reachabilityForInternetConnection];
	return (status != NotReachable);
}	







@end
