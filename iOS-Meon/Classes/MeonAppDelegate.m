 //
//  MeonAppDelegate.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright Manbolo 2010. All rights reserved.
//
#import "GameManager.h"
#import "MeonAppDelegate.h"
#import "MKStoreManager.h"
#import "RootViewController.h"
#import <GameKit/GameKit.h>


@implementation MeonAppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // No status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.rootViewController = [[RootViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
    
	// Initiate MKStoreKit.
	[MKStoreManager sharedManager];
   
	self.gameManager = [[GameManager alloc] init];
    _rootViewController.gameManager = _gameManager;

    // Load the saved viewController.
    UIViewController *currentController = nil;
    NSString *currentViewController = _gameManager.currentViewController;
    currentController = [_rootViewController loadViewController:currentViewController];
    
	// Simulate end animation.
    if ([currentController respondsToSelector:@selector(transitionAnimationDidStopFrom:to:)]){
        [currentController performSelector:@selector(transitionAnimationDidStopFrom:to:) 
                                withObject:@"applicationDidFinishLaunching"
                                withObject:_gameManager.currentViewController];
    }
   
    [_window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	[_gameManager.gameCenterManager serializeGameKitScoresAndAchievementsNotSent];
	[_gameManager.gameCenterManager saveLocalAchievements];
	[_gameManager.boardStore serialize];
    [_gameManager serialize];

}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	DebugLog(@"applicationWillEnterForeground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	DebugLog(@"applicationDidBecomeActive");
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[_gameManager.gameCenterManager serializeGameKitScoresAndAchievementsNotSent];
	[_gameManager.gameCenterManager saveLocalAchievements];
    [_gameManager.boardStore serialize];
    [_gameManager serialize];
}

- (void)dealloc
{
    _gameManager = nil;
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}



@end
