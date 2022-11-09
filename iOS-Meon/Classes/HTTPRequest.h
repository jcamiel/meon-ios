//
//  HTTPRequest.h
//  Manbolo
//
//  Created by Jean-Christophe Amiel on 2/9/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTTPRequestDelegate;


@interface HTTPRequest : NSObject

@property (nonatomic, assign) SEL didFailWithErrorSelector;
@property (nonatomic, assign) SEL didFinishLoadingSelector;
@property (nonatomic, weak) id delegate;
@property (nonatomic, readonly, strong) NSData *responseData;
@property (nonatomic, strong) NSDictionary *userInfo;
- (void)loadURL:(NSString*)url;
- (void)loadURL:(NSString*)url postValue:(NSString*)value;

@end



