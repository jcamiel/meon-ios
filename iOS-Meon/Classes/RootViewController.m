//
//  RootViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright Manbolo 2010. All rights reserved.
//

#import "RootViewController.h"

#import "AchievementsViewController.h"
#import "Common.h"
#import "GameManager.h"
#import "MainMenuViewController.h"
#import "NSString+Constant.h"
#import "OptionsViewController.h"
#import "PlayMenuViewController.h"
#import "PlayViewController.h"
#import "ScoresViewController.h"
#import "SimpleAudioEngine.h"
#import "TimeAttackViewController.h"
#import "UIColor+Helper.h"
#import "UIDevice+Helper.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"
#import "WorldMenuViewController.h"

@implementation RootViewController


#pragma mark - UIViewController life cycle

- (void)loadView {
    DebugLog(@"LoadView");
    UIColor *backgroundColor = [UIColor colorWithHexCode:0x292831];

    UIScreen* mainScreen = [UIScreen mainScreen];
    CGRect applicationFrame = mainScreen.applicationFrame;
    CGRect viewFrame = (CGRect){{0,0},
        {applicationFrame.size.width,applicationFrame.size.height}};
    
    self.view = [[UIView alloc] initWithFrame:viewFrame];
    self.view.backgroundColor = backgroundColor;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIImageView *backgroundView = [self addImageView:CGPointZero
                                                  parent:self.view
                                        defaultImageName:@"Default-Portrait~ipad.png"
                                    highlightedImageName:nil
                                        autoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [backgroundView alignWithRightSideOf:self.view offset:0];
    }
}


- (void)viewWillLayoutSubviews {
    DebugLog(@"viewWillLayoutSubviews view=(%.0f,%.0f,%.0f,%.0f) statusBarOrientation=%ld",
             self.view.bounds.origin.x,
             self.view.bounds.origin.y,
             self.view.bounds.size.width,
             self.view.bounds.size.height,
             (long)[[UIApplication sharedApplication] statusBarOrientation]);
}

- (void)viewDidLayoutSubviews {
    DebugLog(@"viewDidLayoutSubviews view=(%.0f,%.0f,%.0f,%.0f) statusBarOrientation=%ld",
             self.view.bounds.origin.x,
             self.view.bounds.origin.y,
             self.view.bounds.size.width,
             self.view.bounds.size.height,
             [[UIApplication sharedApplication] statusBarOrientation]);
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    DebugLog(@"shouldAutorotateToInterfaceOrientation: %@",
             [NSString stringFromUIInterfaceOrientation:interfaceOrientation]);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        return YES;
    }
    else {
        // Return YES for supported orientations
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    DebugLog(@"willRotateToInterfaceOrientation->%@",
             [NSString stringFromUIInterfaceOrientation:toInterfaceOrientation]);

    for(UIViewController *controller in [_controllers allValues]){
        [controller willRotateToInterfaceOrientation:toInterfaceOrientation
                                              duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    DebugLog(@"didRotateFromInterfaceOrientation->%@",
             [NSString stringFromUIInterfaceOrientation:fromInterfaceOrientation]);
    
    for(UIViewController *controller in [_controllers allValues]){
        [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
    
}

#pragma mark - dealloc

- (void)dealloc {
    _controllers = nil;
    _gameManager = nil;
    _previousViewControllerName = nil;

}

#pragma mark - Loading View Controllers

- (void)unloadViewController:(NSString*)name {
    UIViewController *controller = _controllers[name];

    [controller.view removeFromSuperview];
    [_controllers removeObjectForKey:name];

}


- (void)loadMusicFrom:(NSString *)oldController to:(NSString *)newController {
    if (!_gameManager.hasAudioBeenInitialized)
        return;

    SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
    NSString *oldPath = [_gameManager musicPathForControllerName:oldController];
    NSString *newPath = [_gameManager musicPathForControllerName:newController];

    if ((![audioEngine isBackgroundMusicPlaying] || !oldPath ||
         ![oldPath isEqualToString:newPath]) &&
        newPath) {
        DebugLog(@"Play %@", newPath);
        [audioEngine playBackgroundMusic:newPath];
    }
}

- (UIViewController*)loadViewController:(NSString*)viewControllerName {
    return [self loadViewController:viewControllerName foreground:YES];
}

- (UIViewController*)loadViewController:(NSString*)viewControllerName foreground:(BOOL)foreground {
    
   NSString *aNibName = [NSString stringWithFormat:@"%@ViewController",
                                    viewControllerName];
    if (!_controllers){
        self.controllers = [NSMutableDictionary dictionary];
    }
    
    UIViewController *controller = _controllers[viewControllerName];
    if (controller) {
        [self loadMusicFrom:_previousViewControllerName to:viewControllerName];
        
        _gameManager.currentViewController = viewControllerName;
        self.previousViewControllerName = viewControllerName;
        return controller;
    }
	
    
    Class controllerClass = NSClassFromString(aNibName);
    controller = [[controllerClass alloc] 
                               initWithNibName:aNibName
                               bundle:nil];
    _controllers[viewControllerName] = controller;
    
    if ([controller respondsToSelector:@selector(setDelegate:)])
        [controller performSelector:@selector(setDelegate:)
                                      withObject:self];
           
    if ([controller respondsToSelector:@selector(setGameManager:)])
        [controller performSelector:@selector(setGameManager:)
                         withObject:_gameManager];

    if ([controller respondsToSelector:@selector(setBoardStore:)])
        [controller performSelector:@selector(setBoardStore:)
                         withObject:_gameManager.boardStore];
    
        
    [controller viewWillAppear:NO];
    if (foreground) {
        [self.view addSubview:controller.view];
    }
    else{
        UIViewController *previousViewController = _controllers[_previousViewControllerName];
        [self.view insertSubview:controller.view
                    belowSubview:previousViewController.view];
    }
    
	[controller viewDidAppear:NO];
    
    [self loadMusicFrom:_previousViewControllerName to:viewControllerName];
    _gameManager.currentViewController = viewControllerName;
    self.previousViewControllerName = viewControllerName;

    return controller;
}


-(void)performTransitionFrom:(NSString*)viewController1Name 
						  to:(NSString*)viewController2Name 
			 didStopDelegate:(NSString*)stopDelegateName
						type:(NSString*)type
					 subType:(NSString*)subtype {
	UIViewController *viewController1 = _controllers[viewController1Name];
	UIViewController *viewController2 = _controllers[viewController2Name];
    UIViewController *stopDelegate = _controllers[stopDelegateName];
    
	[viewController2 viewWillAppear:YES];
	[viewController1 viewWillDisappear:YES];
	
	if (type) {
		// First create a CATransition object to describe the transition
		CATransition *transition = [CATransition animation];
		// Animate over 3/4 of a second
		transition.duration = 0.5;
		// using the ease in/out timing function
		transition.timingFunction = [CAMediaTimingFunction functionWithName:
									 kCAMediaTimingFunctionEaseInEaseOut];
		
		transition.type		= type;
		transition.subtype	= subtype;
		
		
		// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
		// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
		transition.delegate = self;
        
		[transition setValue:stopDelegate forKey:@"stopDelegate"];
        [transition setValue:viewController1Name forKey:@"from"];
        [transition setValue:viewController2Name forKey:@"to"];
        
        
		// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
		[self.view.layer addAnimation:transition forKey:nil];
	}
	
	
	// Here we hide view1, and show view2, which will cause Core Animation to animate view1 away and view2 in.
	viewController1.view.hidden = YES;
	viewController2.view.hidden = NO;
	
	[viewController1 viewDidDisappear:YES];
	[viewController2 viewDidAppear:YES];
    
	if (!type) {
		[stopDelegate performSelector:@selector(transitionAnimationDidStopFrom:to:) 
                           withObject:viewController1Name 
                           withObject:viewController2Name];
	}
	
}

-(void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	id stopDelegate = [theAnimation valueForKey:@"stopDelegate"];	
    id from = [theAnimation valueForKey:@"from"];	
    id to = [theAnimation valueForKey:@"to"];	
    
	if ([stopDelegate respondsToSelector:@selector(transitionAnimationDidStopFrom:to:)]) {
        [stopDelegate performSelector:@selector(transitionAnimationDidStopFrom:to:)
                           withObject:from
                           withObject:to];
	}
}


#pragma mark - MainMenuViewControllerDelegate

- (void)mainMenuDidSelectPlayClassic:(MainMenuViewController*)controller {
    [_gameManager unserialize];

	_gameManager.mode = kGameModeClassic;

    [self loadViewController:@"Play"];
    
    [self performTransitionFrom:@"MainMenu" 
                             to:@"Play"
                didStopDelegate:@"Play"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
	
    
}

- (void)mainMenuDidSelectTimeAttack:(MainMenuViewController*)controller {
    [self loadViewController:@"TimeAttack"];

    [self performTransitionFrom:@"MainMenu" 
                             to:@"TimeAttack"
                didStopDelegate:@"TimeAttack"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
}

- (void)mainMenuDidSelectShowScores:(MainMenuViewController*)controller {
    [self loadViewController:@"Scores"];

    [self performTransitionFrom:@"MainMenu" 
                             to:@"Scores"
                didStopDelegate:nil
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
}

- (void)mainMenuDidSelectShowOptions:(MainMenuViewController*)controller {
     [self loadViewController:@"Options"];
        
    [self performTransitionFrom:@"MainMenu" 
                             to:@"Options"
                didStopDelegate:nil
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
}

-(void)mainMenuDidSelectBuyFullVersion:(MainMenuViewController*)controller {
    NSLocale *local  = [NSLocale currentLocale];
    NSString *cc = [local localeIdentifier];
    NSString *pn = [[UIDevice currentDevice] hardwareModelAndVersion];
    NSString *urlString = [NSString stringWithFormat:@"http://ws.manbolo.com:8251/links?id=1&cc=%@&pn=%@",cc, pn];
    NSURL *url = [NSURL URLWithString:urlString];
    
	[[UIApplication sharedApplication] openURL:url];    
}

- (void)mainMenuDidSelectShowAchievements:(MainMenuViewController*)controller {
	[self loadViewController:@"Achievements"];
	
    [self performTransitionFrom:@"MainMenu" 
                             to:@"Achievements"
                didStopDelegate:nil
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
}

- (void)mainMenuDidSelectRate:(MainMenuViewController*)controller {
	[[UIApplication sharedApplication] openURL:_gameManager.reviewsURL];   
}

- (void)mainMenuDidSelectEditor:(MainMenuViewController*)controller {
    [_gameManager unserialize];
    
	_gameManager.mode = kGameModeEditor;
	
	[self loadViewController:@"Editor"];
	
    [self performTransitionFrom:@"MainMenu" 
                             to:@"Editor"
                didStopDelegate:@"Editor"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
	
}
#pragma mark - Play Menu

- (void)playMenuDidSelectPlayClassic:(PlayMenuViewController*)controller {
    [_gameManager unserialize];
    
	_gameManager.mode = kGameModeClassic;

    
    [self loadViewController:@"Play"];
    
    [self performTransitionFrom:@"PlayMenu" 
                             to:@"Play"
                didStopDelegate:@"Play"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];

    [self unloadViewController:@"PlayMenu"];

}

- (void)playMenuDidSelectPlayTimeAttack:(PlayMenuViewController *)controller {
    [self loadViewController:@"TimeAttack"];
    
    [self performTransitionFrom:@"PlayMenu" 
                             to:@"TimeAttack"
                didStopDelegate:@"TimeAttack"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"PlayMenu"];
}

- (void)playMenuDidSelectPlayWorld:(PlayMenuViewController*)controller {
    [self loadViewController:@"WorldMenu"];
    
    [self performTransitionFrom:@"PlayMenu" 
                             to:@"WorldMenu"
                didStopDelegate:@"WorldMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];

    [self unloadViewController:@"PlayMenu"];
}

- (void)playMenuDidSelectBack:(PlayMenuViewController*)controller {
    [self loadViewController:@"MainMenu"];
    
    [self performTransitionFrom:@"PlayMenu" 
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"PlayMenu"];
}

#pragma mark - WorldMenu Delegate

- (void)worldMenuDidSelectBack:(WorldMenuViewController*)controller {
    [self loadViewController:@"PlayMenu"];
    
    [self performTransitionFrom:@"WorldMenu" 
                             to:@"PlayMenu"
                didStopDelegate:@"PlayMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"WorldMenu"];

}

- (void)worldMenu:(WorldMenuViewController*)controller didSelectLevelIndex:(NSUInteger)levelIndex {
    [_gameManager unserialize];
    
    _gameManager.mode = kGameModeWorld;
    _gameManager.level = levelIndex;
    
    [self loadViewController:@"Play"];
    
    [self performTransitionFrom:@"WorldMenu" 
                             to:@"Play"
                didStopDelegate:@"Play"
     //						   type:kCATransitionFade
     						   type:nil
						subType:nil];
    
    [self unloadViewController:@"WorldMenu"];

}

#pragma mark - Editor

- (void)editorSelectMenu:(EditorViewController*)controller {

    [_gameManager serialize];

	[self loadViewController:@"MainMenu"];
	
    [self performTransitionFrom:@"Editor" 
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"Editor"];
	
}



#pragma mark - PlayViewControllerDelegate

- (void)playDidSelectBuy:(PlayViewController*)controller {
    NSLocale *local  = [NSLocale currentLocale];
    NSString *cc = [local localeIdentifier];
    NSString *pn = [[UIDevice currentDevice] hardwareModelAndVersion];
    NSString *urlString = [NSString stringWithFormat:@"http://ws.manbolo.com:8251/links?id=2&cc=%@&pn=%@",cc, pn];
    NSURL *url = [NSURL URLWithString:urlString];
    
	[[UIApplication sharedApplication] openURL:url];
}

- (void)playDidSelectMenu:(PlayViewController*)controller {
    // save the previous level
    [_gameManager serialize];
    
    [self loadViewController:@"MainMenu"];    

    [self performTransitionFrom:@"Play"  
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
 						   type:kCATransitionPush
						subType:kCATransitionFromTop];
   
    [self unloadViewController:@"Play"];   
}

- (void)playDidFinishGame:(PlayViewController*)controller {
    // save the previous level
    [_gameManager serialize];

    [self loadViewController:@"Congratulation"];
    
    [self performTransitionFrom:@"Play" 
                             to:@"Congratulation"
                didStopDelegate:nil
 						   type:kCATransitionFade
						subType:nil];

	[self unloadViewController:@"Play"];
    
}


- (void)playDidFinishWorldLevel:(PlayViewController*)controller {
    // save the previous level
    [_gameManager serialize];

    [self loadViewController:@"WorldMenu"];
    
    [self performTransitionFrom:@"Play" 
                             to:@"WorldMenu"
                didStopDelegate:@"WorldMenu"
						   type:nil
						subType:nil];
	
    [self unloadViewController:@"Play"];

}

#pragma mark - TimeAttackViewController Delegate

- (void)timeAttackDidSelectPlayFlash:(TimeAttackViewController*)controller {
    _gameManager.mode = kGameModeTimeAttackFlash;
    _gameManager.level = 0;
    
    [self loadViewController:@"Play"];
    
    [self performTransitionFrom:@"TimeAttack" 
                             to:@"Play"
                didStopDelegate:@"Play"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];

    [self unloadViewController:@"TimeAttack"];  
    
}

- (void)timeAttackDidSelectPlayMedium:(TimeAttackViewController*)controller {
    _gameManager.mode = kGameModeTimeAttackMedium;
    _gameManager.level = 0;

    [self loadViewController:@"Play"];
    
    [self performTransitionFrom:@"TimeAttack" 
                             to:@"Play" 
                didStopDelegate:@"Play" 
						   type:kCATransitionPush
						subType:kCATransitionFromTop];

	 [self unloadViewController:@"TimeAttack"];  
    
}

- (void)timeAttackDidSelectPlayMarathon:(TimeAttackViewController*)controller {
    _gameManager.mode = kGameModeTimeAttackMarathon;
    _gameManager.level = 0;
    
    [self loadViewController:@"Play"];
    
    
    [self performTransitionFrom:@"TimeAttack"
                             to:@"Play" 
                didStopDelegate:@"Play" 
						   type:kCATransitionPush
						subType:kCATransitionFromTop];

    [self unloadViewController:@"TimeAttack"];  

    
}

- (void)timeAttackDidSelectBack:(TimeAttackViewController*)controller {
    [self loadViewController:@"MainMenu"];
    
    [self performTransitionFrom:@"TimeAttack"
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"TimeAttack"];  
    
    
}

#pragma mark - CongratulationViewControllerDelegate

-(void)congratulationDidTapGoToMainMenu:(CongratulationViewController*)controller {
    [self loadViewController:@"MainMenu"];

    
    [self performTransitionFrom:@"Congratulation" 
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
   [self unloadViewController:@"Congratulation"]; 
    
}

-(void)congratulationDidTapBuyFullVersion:(CongratulationViewController*)controller {
    NSLocale *local  = [NSLocale currentLocale];
    NSString *cc = [local localeIdentifier];
    NSString *pn = [[UIDevice currentDevice] hardwareModelAndVersion];
    NSString *urlString = [NSString stringWithFormat:@"http://ws.manbolo.com:8251/links?id=3&cc=%@&pn=%@",cc, pn];
    NSURL *url = [NSURL URLWithString:urlString];
    
	[[UIApplication sharedApplication] openURL:url];    
}

#pragma mark - OptionsViewController Delegate

- (void)optionsDidSelectBack:(OptionsViewController*)controller {
    [self loadViewController:@"MainMenu"];
    
    [self performTransitionFrom:@"Options"
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"Options"];    
}

#pragma mark - ScoresViewController Delegate

- (void)scoresDidSelectBack:(ScoresViewController*)controller {
    [self loadViewController:@"MainMenu"];
    
    [self performTransitionFrom:@"Scores"
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"Scores"];    
    
}


#pragma mark - AchievementsViewControllerDelegate Delegate

- (void)achievementsDidSelectBack:(AchievementsViewController*)controller {
	[self loadViewController:@"MainMenu"];
    
    [self performTransitionFrom:@"Achievements"
                             to:@"MainMenu"
                didStopDelegate:@"MainMenu"
						   type:kCATransitionPush
						subType:kCATransitionFromTop];
    
    [self unloadViewController:@"Achievements"];    
}


#pragma mark - PlayMenuiPadViewControllerDelegate delegate

- (void)loadPlayiPadViewController {
 	[self loadViewController:@"PlayiPad" foreground:NO];
    
    UIViewController *aController0 = _controllers[@"PlayiPad"];
    if ([aController0 isKindOfClass:[PlayiPadViewController class]]){
        PlayiPadViewController* playController = (PlayiPadViewController*)aController0; 
        [playController setGroundViewVisibleAnimated:YES];
        [playController layoutButtonsAnimated:NO];        
        [playController setButtonsVisible:YES animated:YES];
        [playController setBannerViewVisibleAnimated:YES];
    }
    
    UIViewController *aController1 = _controllers[@"MainMenuiPad"];
    if ([aController1 isKindOfClass:[MainMenuiPadViewController class]]){
        MainMenuiPadViewController* mainMenuController = (MainMenuiPadViewController*)aController1; 
        [mainMenuController dismissViewController];
    }
}

- (void)mainMenuiPadDidSelectPlayClassic:(MainMenuiPadViewController*)controller {
    [_gameManager unserialize];
    _gameManager.mode = kGameModeClassic;
    [self loadPlayiPadViewController];
}

- (void)mainMenuiPadDismissAnimationDidFinish:(MainMenuiPadViewController*)controller {
    UIViewController *aController = _controllers[@"PlayiPad"];
    if ([aController isKindOfClass:[PlayiPadViewController class]]){
        
        [aController performSelector:@selector(transitionAnimationDidStopFrom:to:) 
                                withObject:@"MainMenuiPad"
                                withObject:@"PlayiPad"];
    }
    [self unloadViewController:@"MainMenuiPad"];

}

- (void)mainMenuiPadDidSelectPlayFlash:(MainMenuiPadViewController*)controller {
    _gameManager.mode = kGameModeTimeAttackFlash;
    _gameManager.level = 0;
    [self loadPlayiPadViewController];
}

- (void)mainMenuiPadDidSelectPlayMedium:(MainMenuiPadViewController*)controller {
    _gameManager.mode = kGameModeTimeAttackMedium;
    _gameManager.level = 0;
    [self loadPlayiPadViewController];
}

- (void)mainMenuiPadDidSelectPlayMarathon:(MainMenuiPadViewController*)controller {
    _gameManager.mode = kGameModeTimeAttackMarathon;
    _gameManager.level = 0;
    [self loadPlayiPadViewController];
}

- (void)mainMenuiPadDidSelectBuyFullVersion:(MainMenuiPadViewController*)controller {
    NSLocale *local  = [NSLocale currentLocale];
    NSString *cc = [local localeIdentifier];
    NSString *pn = [[UIDevice currentDevice] hardwareModelAndVersion];
    NSString *urlString = [NSString stringWithFormat:@"http://ws.manbolo.com:8251/links?id=1&cc=%@&pn=%@",cc, pn];
    NSURL *url = [NSURL URLWithString:urlString];
    
	[[UIApplication sharedApplication] openURL:url];    
}



#pragma mark - PlayiPadViewControllerDelegate delegate

- (void)playiPadDidTapMenu:(PlayiPadViewController*)controller {
    [_gameManager serialize];

    [self loadViewController:@"MainMenuiPad"];
    
    [self performTransitionFrom:@"PlayiPad" 
                             to:@"MainMenuiPad"
                didStopDelegate:@"MainMenuiPad"
 						   type:kCATransitionFade
						subType:nil];
    
	[self unloadViewController:@"PlayiPad"];

}

- (void)playiPadDidFinishGame:(PlayiPadViewController *)controller {
    // save the previous level
    [_gameManager serialize];
    
    [self loadViewController:@"CongratulationiPad"];
    
    [self performTransitionFrom:@"PlayiPad" 
                             to:@"CongratulationiPad"
                didStopDelegate:nil
 						   type:kCATransitionFade
						subType:nil];
    
	[self unloadViewController:@"PlayiPad"];
}


- (void)playiPadDidSelectBuy:(PlayiPadViewController*)controller {
    NSLocale *local  = [NSLocale currentLocale];
    NSString *cc = [local localeIdentifier];
    NSString *pn = [[UIDevice currentDevice] hardwareModelAndVersion];
    NSString *urlString = [NSString stringWithFormat:@"http://ws.manbolo.com:8251/links?id=2&cc=%@&pn=%@",cc, pn];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - CongratulationiPadViewControllerDelegate

-(void)congratulationiPadDidTapGoToMenu:(CongratulationiPadViewController *)controller {
    [self loadViewController:@"MainMenuiPad"];
    
    [self performTransitionFrom:@"CongratulationiPad" 
                             to:@"MainMenuiPad"
                didStopDelegate:@"MainMenuiPad"
						   type:kCATransitionFade
						subType:nil];
    
    [self unloadViewController:@"CongratulationiPad"]; 
    
}

-(void)congratulationiPadDidTapBuyFullVersion:(CongratulationiPadViewController*)controller {
    NSLocale *local  = [NSLocale currentLocale];
    NSString *cc = [local localeIdentifier];
    NSString *pn = [[UIDevice currentDevice] hardwareModelAndVersion];
    NSString *urlString = [NSString stringWithFormat:@"http://ws.manbolo.com:8251/links?id=3&cc=%@&pn=%@",cc, pn];
    NSURL *url = [NSURL URLWithString:urlString];
    
	[[UIApplication sharedApplication] openURL:url];    
}


@end
