//
//  SolveriPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/31/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//

#import "SolveriPadViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "MKStoreManager.h"
#import "Reachability.h"
#import "UIColor+Helper.h"
#import "UIView+Helper.h"
#import "UIView+Helper.h"

@interface SolveriPadViewController ()

@property (nonatomic, strong) id applicationDidBecomeActiveNotificationObserver;

@end



@implementation SolveriPadViewController

@dynamic delegate;

- (void)dealloc {
    if (self.applicationDidBecomeActiveNotificationObserver) {
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter removeObserver:self.applicationDidBecomeActiveNotificationObserver];
    }
    else {
        DebugLog(@"Duhh...no observer!");
    }

    [MKStoreManager setDelegate:nil];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    //-- register to application did become active
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    self.applicationDidBecomeActiveNotificationObserver = [defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil
                                                                                      queue:nil
                                                                                 usingBlock:^(NSNotification *notification){
                                                               if ([[MKStoreManager sharedManager] canConsumeProduct:self.productId
                                                                                                            quantity:1]) {
                                                                   [self cancel:nil];
                                                               }
                                                           }];

    [self addHeaderImageNamed:@"Common/solverHeader@2x.png"];

    //-- add the bottom
    UIImage *image = [UIImage imageNamed:@"Common/solver_bottom@2x.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = (CGRect){{0, 0}, {540, 260}};
    imageView.y = self.view.height - imageView.height;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];

    [MKStoreManager setDelegate:self];

    //-- add the unlock button
    UIButton *unlockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.unlockButton = unlockButton;
    CGFloat width = 223;
    CGFloat height = 107;
    CGFloat x = floor((self.view.width - width) / 2);
    CGFloat y = 400;
    self.unlockButton.frame = (CGRect){{x, y}, {width, height}};
    [self.unlockButton addTarget:self
                          action:@selector(buy:)
                forControlEvents:UIControlEventTouchUpInside];

    UIImage *defaultImage = [UIImage imageNamed:@"Common/unlock~ipad.png"];
    [self.unlockButton setImage:defaultImage forState:UIControlStateNormal];
    self.unlockButton.enabled = NO;
    self.unlockButton.hidden = YES;
    [self.view addSubview:self.unlockButton];


    //-- add the spinner
    UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinnerView = spinnerView;
    spinnerView.center = self.unlockButton.center;
    spinnerView.hidesWhenStopped = YES;
    [self.view addSubview:self.spinnerView];

    //-- add the connected Text
    CGFloat normalFontSize = 30;
    CGFloat bigFontSize = 32;
    self.normalFont = [UIFont fontWithName:@"BradyBunchRemastered" size:normalFontSize];
    self.bigFont = [UIFont fontWithName:@"BradyBunchRemastered" size:bigFontSize];

    //-- add the thankyou view
    UIImage *thankyouImage = [UIImage imageNamed:@"Common/thankyou~ipad.png"];
    UIImageView *thankyouImageView = [[UIImageView alloc] initWithImage:thankyouImage];
    self.thankyouView = thankyouImageView;
    x = floor((self.view.width - thankyouImage.size.width) / 2);
    y = 200;
    width = thankyouImage.size.width;
    height = thankyouImage.size.height;
    self.thankyouView.frame = (CGRect){{x, y}, {width, height}};
    self.thankyouView.hidden = YES;
    [self.view addSubview:self.thankyouView];

    //-- add the thank you text
    UILabel *thankyouLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.thankyouLabel = thankyouLabel;
    self.thankyouLabel.textColor = [UIColor whiteColor];
    self.thankyouLabel.backgroundColor = [UIColor clearColor];
    self.thankyouLabel.text = NSLocalizedString(@"L_SolverLevelUnlocked", );
    self.thankyouLabel.font = self.normalFont;
    [self.thankyouLabel sizeToFit];
    x = floor((self.view.width - thankyouLabel.frame.size.width) / 2);
    y = 300;
    width = self.thankyouLabel.frame.size.width;
    height = self.thankyouLabel.frame.size.height;
    self.thankyouLabel.frame = (CGRect){{x, y}, {width, height}};
    self.thankyouLabel.hidden = YES;
    [self.view addSubview:self.thankyouLabel];

    //-- add the connecting view
    UILabel *connectingView = [[UILabel alloc] initWithFrame:CGRectZero];
    self.connectingView = connectingView;
    self.connectingView.textColor = [UIColor whiteColor];
    self.connectingView.backgroundColor = [UIColor clearColor];
    self.connectingView.text = NSLocalizedString(@"L_SolverWaitForConnection", );
    self.connectingView.font = self.normalFont;
    [self.connectingView sizeToFit];
    x = floor((self.view.width - self.connectingView.frame.size.width) / 2);
    y = 250;
    width = self.connectingView.frame.size.width;
    height = self.connectingView.frame.size.height;
    self.connectingView.frame = (CGRect){{x, y}, {width, height}};
    self.connectingView.hidden = YES;
    [self.view addSubview:self.connectingView];

    //-- add the error view
    UILabel *errorView = [[UILabel alloc] initWithFrame:CGRectZero];
    self.errorView = errorView;
    self.errorView.textColor = [UIColor whiteColor];
    self.errorView.backgroundColor = [UIColor clearColor];
    self.errorView.text = NSLocalizedString(@"L_SolverNoConnection", );
    self.errorView.font = self.normalFont;
    self.errorView.numberOfLines = 0;

    width = self.view.width - 2 * 10;
    height = 200;
    CGSize size = (CGSize){width, height};
    CGSize newSize = [self.errorView sizeThatFits:size];
    x = floor((self.view.width - newSize.width) / 2);
    y = 200;
    width = newSize.width;
    height = newSize.height;
    self.errorView.frame = (CGRect){{x, y}, {width, height}};
    self.errorView.hidden = YES;
    [self.view addSubview:self.errorView];



    [self updateSpinnerAndText];
}


/*
   // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
   - (void)viewDidLoad
   {
    [super viewDidLoad];
   }
 */

- (void)viewDidAppear:(BOOL)animated {
    DebugLog(@"viewDidAppear");

    [super viewDidAppear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
    DebugLog(@"viewDidDisappear");

    [super viewDidDisappear:animated];
    [self.delegate solveriPadDidDisappear:self];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    [MKStoreManager setDelegate:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark - Update text price
- (void)addBuyTextWithPrice:(NSString *)price {
    if (self.connectedView) {return; }

    // add the text
    CGFloat margin = 24;
    CGFloat x = margin;
    CGFloat y = 100 + margin;
    CGFloat width = self.view.width - 2 * margin;
    CGFloat height = self.view.height - 2 * margin;
    CGRect textFrame = (CGRect){{x, y}, {width, height}};
    UILabel *textLabel = [[UILabel alloc] initWithFrame:textFrame];
    textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines = 0;
    self.connectedView = textLabel;
    [self.view addSubview:self.connectedView];

    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"L_Solver", ), price];
    UIColor *textColor = [UIColor whiteColor];

    UIColor *highlightColor = [UIColor colorWithHexCode:0x00FFFF];

    NSArray *highlights = @[NSLocalizedString(@"L_Solver_Highlight_1", ),
                            NSLocalizedString(@"L_Solver_Highlight_2", )];

    NSDictionary *attributes = @{NSFontAttributeName: self.normalFont, NSForegroundColorAttributeName: textColor};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

    //-- set highlight on each part if the string
    NSRange searchRange = (NSRange){0, text.length};
    for(NSString *highlight in highlights) {
        NSRange range = [text rangeOfString:highlight
                                    options:NSLiteralSearch
                                      range:searchRange];
        if (range.location != NSNotFound) {
            [attrStr addAttributes:@{NSForegroundColorAttributeName: highlightColor, NSFontAttributeName: self.bigFont} range:range];
            searchRange.location = range.location + range.length;
            searchRange.length = text.length - searchRange.location;
        }
    }
    self.connectedView.attributedText = attrStr;
}


#pragma mark - MKStoreKitDelegate delegate

- (void)productFetchComplete {
    DebugLog(@"productFetchComplete");

    [self updateSpinnerAndText];
}


- (void)productPurchased:(NSString *)productId {
    DebugLog(@"productPurchased id=%@", productId);

    self.cancelButton.titleLabel.text = @"Done";
    [self.cancelButton setImage:[UIImage imageNamed:@"Common/done.png"]
                       forState:UIControlStateNormal];

    [UIView beginAnimations:@"cancel" context:NULL];
    self.cancelButton.alpha = 1.0;
    [UIView commitAnimations];

    [self.spinnerView stopAnimating];

    self.thankyouView.hidden = NO;
    self.thankyouLabel.hidden = NO;
    self.connectedView.hidden = YES;
}


- (void)transactionCanceled {
    DebugLog(@"transactionCanceled");
    [UIView beginAnimations:@"cancel" context:NULL];
    self.cancelButton.alpha = 1.0;
    self.unlockButton.alpha = 1.0;
    [UIView commitAnimations];

    [self updateSpinnerAndText];
}


- (void)updateSpinnerAndText {
    MKStoreManager *storeManager = [MKStoreManager sharedManager];
    if (storeManager.isProductsAvailable) {
        [self.spinnerView stopAnimating];

        NSDictionary *description = [storeManager purchasableObjectsDescription];
        NSDictionary *product = description[self.productId];

        NSString *localizedPrice = product[@"localizedPrice"];
        [self addBuyTextWithPrice:localizedPrice];
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
        self.connectedView.hidden = YES;

        if (networkAvailable) {
            [self.spinnerView startAnimating];
        }
        else {
            [self.spinnerView stopAnimating];
        }
    }

#if TARGET_IPHONE_SIMULATOR
    self.unlockButton.enabled = YES;
#endif
}


#pragma mark - Network
- (BOOL)networkAvailable {
    NetworkStatus status = [Reachability reachabilityForInternetConnection];
    return (status != NotReachable);
}


- (IBAction)buy:(id)sender {
    [UIView beginAnimations:@"cancel" context:NULL];
    self.cancelButton.alpha = 0.0;
    self.unlockButton.alpha = 0.0;
    [UIView commitAnimations];
    [self.spinnerView startAnimating];

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


@end
