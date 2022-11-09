//
//  StoreManager.h
//  MKStoreKit
//
//  Created by Mugunth Kumar on 17-Nov-2010.
//  Copyright 2010 Steinlogic. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://mugunthkumar.com
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/1m on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices


#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

// CONFIGURATION STARTS -- Change this in your app

#if defined(LITE)
	#define kConsumableBaseFeatureId @"com.manbolo.meonlite.solvelevel."
	#define kConsumableFeatureBId @"com.manbolo.meonlite.solvelevel.5"
#else
	#define kConsumableBaseFeatureId @"com.manbolo.meon.solvelevel."
	#define kConsumableFeatureBId @"com.manbolo.meon.solvelevel.5"
#endif

// consumable features should have only number as the last part of the product name
// MKStoreKit automatically keeps track of the count of your consumable product

#define SERVER_PRODUCT_MODEL 0
// CONFIGURATION ENDS -- Change this in your app

@protocol MKStoreKitDelegate <NSObject>
@optional
- (void)productFetchComplete;
- (void)productPurchased:(NSString *)productId;
- (void)transactionCanceled;
// as a matter of UX, don't show a "User Canceled transaction" alert view here
// use this only to "enable/disable your UI or hide your activity indicator view etc.,
@end

@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {

	NSMutableArray *_purchasableObjects;
	MKStoreObserver *_storeObserver;
	BOOL isProductsAvailable;
}

@property (nonatomic, strong) NSMutableArray *purchasableObjects;
@property (nonatomic, strong) MKStoreObserver *storeObserver;
@property (nonatomic, readonly) BOOL isProductsAvailable;

// These are the methods you will be using in your app
+ (instancetype)sharedManager;


// this is a static method, since it doesn't require the store manager to be initialized prior to calling
+ (BOOL) isFeaturePurchased:(NSString*) featureId; 

// these three are not static methods, since you have to initialize the store with your product ids before calling this function
- (void) buyFeature:(NSString*) featureId;
- (NSMutableDictionary*) purchasableObjectsDescription;
- (void) restorePreviousTransactions;

- (BOOL)canConsumeProduct:(NSString*) productIdentifier quantity:(int) quantity;
- (BOOL)consumeProduct:(NSString*) productIdentifier quantity:(int) quantity;
- (NSInteger)quantityOfProduct:(NSString*) productIdentifier;


//DELEGATES
+(id)delegate;	
+(void)setDelegate:(id)newDelegate;

@end
