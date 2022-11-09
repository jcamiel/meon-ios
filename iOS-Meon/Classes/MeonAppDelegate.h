//
//  MeonAppDelegate.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright Manbolo 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController, GameManager;

@interface MeonAppDelegate : NSObject <UIApplicationDelegate> 

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) RootViewController *rootViewController;
@property (nonatomic, strong) GameManager *gameManager;



@end

