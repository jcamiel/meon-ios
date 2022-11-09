//
//  MKStoreManager.m
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

#import "MKStoreManager.h"
#import "NSMutableDictionary+Helper.h"

@interface MKStoreManager (PrivateMethods)

- (void) requestProductData;
- (BOOL) canCurrentDeviceUseFeature: (NSString*) featureID;
- (BOOL) verifyReceipt:(NSData*) receiptData;
- (void) enableContentForThisSession: (NSString*) productIdentifier;

@end

@implementation MKStoreManager

@synthesize purchasableObjects = _purchasableObjects;
@synthesize storeObserver = _storeObserver;
@synthesize isProductsAvailable = _isProductsAvailable;

static NSString *ownServer = nil;

static __weak id<MKStoreKitDelegate> _delegate;
static MKStoreManager* _sharedStoreManager;



#pragma mark Delegates

+ (id)delegate {
	
    return _delegate;
}

+ (void)setDelegate:(id)newDelegate {
	
    _delegate = newDelegate;	
}

#pragma mark Singleton Methods


+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static MKStoreManager *_sharedStoreManager;
    dispatch_once(&once, ^{
        _sharedStoreManager = [[self alloc] init];
        _sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];
        [_sharedStoreManager requestProductData];
        _sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];

    });
    return _sharedStoreManager;
}




#pragma mark Internal MKStoreKit functions

- (void) restorePreviousTransactions
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)requestProductData
{
	DebugLog(@"requestProductData from ");
	
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects: 
								  kConsumableFeatureBId,
								  nil]];
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[self.purchasableObjects addObjectsFromArray:response.products];
	
#ifndef NDEBUG	
	for(int i=0;i<[self.purchasableObjects count];i++)
	{		
		SKProduct *product = (self.purchasableObjects)[i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	for(NSString *invalidProduct in response.invalidProductIdentifiers)
		NSLog(@"Problem in iTunes connect configuration for product: %@", invalidProduct);
#endif
	
	
	_isProductsAvailable = YES;
	
	if([_delegate respondsToSelector:@selector(productFetchComplete)])
		[_delegate productFetchComplete];	
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	DebugLog(@"request fail with error:%@", [error description]);
	
	// some error, try to connect in one minute
	[self performSelector:@selector(requestProductData) withObject:nil afterDelay:10.0];
}

// call this function to check if the user has already purchased your feature
+ (BOOL) isFeaturePurchased:(NSString*) featureId
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:featureId];
}

// Call this function to populate your UI
// this function automatically formats the currency based on the user's locale

- (NSMutableDictionary*) purchasableObjectsDescription
{
	NSMutableDictionary *productDescriptions = [[NSMutableDictionary alloc] initWithCapacity:[self.purchasableObjects count]];
	for(int i=0;i<[self.purchasableObjects count];i++)
	{
		SKProduct *product = (self.purchasableObjects)[i];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[numberFormatter setLocale:product.priceLocale];
		NSString *formattedString = [numberFormatter stringFromNumber:product.price];
		
        DebugLog(@"localizedDescription=%@\nlocalizedTitle=%@\nproductIdentifier=%@\nlocalizedPrice=%@",
                 product.localizedDescription, product.localizedTitle, product.productIdentifier, formattedString);
        
		// you might probably need to change this line to suit your UI needs
		NSMutableDictionary *description = [NSMutableDictionary dictionary];
		[description setObjectSafe:product.localizedDescription 
						forKey:@"localizedDescription"];
		[description setObjectSafe:product.localizedTitle 
						forKey:@"localizedTitle"];
		[description setObjectSafe:product.productIdentifier 
						forKey:@"productIdentifier"];
		[description setObjectSafe:formattedString 
						forKey:@"localizedPrice"];
		
		
		
		
#ifndef NDEBUG
		NSLog(@"Product %d - %@", i, description);
#endif
		productDescriptions[product.productIdentifier] = description;
	}
	
	return productDescriptions;
}


- (void) buyFeature:(NSString*) featureId
{
	if([self canCurrentDeviceUseFeature: featureId])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Review request approved", @"")
														message:NSLocalizedString(@"You can use this feature for reviewing the app.", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles:nil];
		[alert show];
		
		[self enableContentForThisSession:featureId];
		return;
	}
	
	if ([SKPaymentQueue canMakePayments]){
        // identifier the product
        SKProduct *theProduct = nil;
        for(SKProduct *aProduct in _purchasableObjects){
            if ([aProduct.productIdentifier isEqualToString:featureId]){
                theProduct = aProduct;
                break;
            }
        }
        
        if (theProduct){
            SKPayment *payment = [SKPayment paymentWithProduct:theProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"In-App Purchasing disabled", @"")
														message:NSLocalizedString(@"Check your parental control settings and try again later", @"")
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
											  otherButtonTitles: nil];
		[alert show];
	}
}

- (BOOL) canConsumeProduct:(NSString*) productIdentifier
{
	NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	
	return (count > 0);
}

- (NSInteger)quantityOfProduct:(NSString*) productIdentifier
{
	NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
    return count;
}

- (BOOL)canConsumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	return (count >= quantity);
}

- (BOOL) consumeProduct:(NSString*) productIdentifier quantity:(int) quantity
{
	NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
	if(count < quantity)
	{
		return NO;
	}
	else 
	{
		count -= quantity;
		[[NSUserDefaults standardUserDefaults] setInteger:count forKey:productIdentifier];
		return YES;
	}
}

-(void) enableContentForThisSession: (NSString*) productIdentifier
{
	if([_delegate respondsToSelector:@selector(productPurchased:)])
		[_delegate productPurchased:productIdentifier];
}

							 
#pragma mark In-App purchases callbacks
// In most cases you don't have to touch these methods
-(void) provideContent: (NSString*) productIdentifier 
		   forReceipt:(NSData*) receiptData
{
	if(ownServer != nil && SERVER_PRODUCT_MODEL)
	{
		// ping server and get response before serializing the product
		// this is a blocking call to post receipt data to your server
		// it should normally take a couple of seconds on a good 3G connection
		if(![self verifyReceipt:receiptData]) return;
	}

	NSRange range = [productIdentifier rangeOfString:kConsumableBaseFeatureId];		
	NSString *countText = [productIdentifier substringFromIndex:range.location+[kConsumableBaseFeatureId length]];
	
	int quantityPurchased = [countText intValue];
	if(quantityPurchased != 0)
	{
		
		NSInteger oldCount = [[NSUserDefaults standardUserDefaults] integerForKey:productIdentifier];
		oldCount += quantityPurchased;	
		
		[[NSUserDefaults standardUserDefaults] setInteger:oldCount forKey:productIdentifier];		
	}
	else 
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];		
	}

	[[NSUserDefaults standardUserDefaults] synchronize];

	if([_delegate respondsToSelector:@selector(productPurchased:)])
		[_delegate productPurchased:productIdentifier];	
}

- (void) transactionCanceled: (SKPaymentTransaction *)transaction
{

#ifndef NDEBUG
	NSLog(@"User cancelled transaction: %@", [transaction description]);
#endif
	
	if([_delegate respondsToSelector:@selector(transactionCanceled)])
		[_delegate transactionCanceled];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[transaction.error localizedFailureReason] 
													message:[transaction.error localizedRecoverySuggestion]
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
										  otherButtonTitles: nil];
	[alert show];
}



#pragma mark In-App purchases promo codes support
// This function is only used if you want to enable in-app purchases for free for reviewers
// Read my blog post http://mk.sg/31
- (BOOL) canCurrentDeviceUseFeature: (NSString*) featureID
{
    return NO;
}

// This function is only used if you want to enable in-app purchases for free for reviewers
// Read my blog post http://mk.sg/

-(BOOL) verifyReceipt:(NSData*) receiptData
{
	if(ownServer == nil) return NO; // sanity check
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", ownServer, @"verifyProduct.php"]];
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url 
                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
                                                          timeoutInterval:60];
	
	[theRequest setHTTPMethod:@"POST"];		
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	NSString *receiptDataString = [[NSString alloc] initWithData:receiptData encoding:NSASCIIStringEncoding];
	NSString *postData = [NSString stringWithFormat:@"receiptdata=%@", receiptDataString];
	
	NSString *length = [NSString stringWithFormat:@"%lu", [postData length]];
	[theRequest setValue:length forHTTPHeaderField:@"Content-Length"];	
	
	[theRequest setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSHTTPURLResponse* urlResponse = nil;
	NSError *error = [[NSError alloc] init];  
	
	NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest
												 returningResponse:&urlResponse 
															 error:&error];  
	
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
	
	BOOL retVal = NO;
	if([responseString isEqualToString:@"YES"])		
	{
		retVal = YES;
	}
	
	return retVal;
}

- (BOOL)isProductsAvailable
{
#if  TARGET_IPHONE_SIMULATOR
    NSLog(@"%d", _isProductsAvailable);
	return YES;
#else
	return _isProductsAvailable;
#endif	
}

@end
