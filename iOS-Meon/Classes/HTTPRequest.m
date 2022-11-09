//
//  HTTPRequest.m
//  Manbolo
//
//  Created by Jean-Christophe Amiel on 2/9/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "HTTPRequest.h"

@interface HTTPRequest ()
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *connectionData;
@property (nonatomic, strong, readwrite) NSData *responseData;

@end

@implementation HTTPRequest


- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)loadURL:(NSString *)url {
    [self loadURL:url postValue:nil];
}


- (void)loadURL:(NSString *)url postValue:(NSString *)value {
    // create the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    if (value) {
        NSData * data = [value dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPMethod:@"POST"];
        [request setValue:[NSString stringWithFormat:@"%lu", data.length]
         forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded"
         forHTTPHeaderField:@"Content-Type"];

        [request setHTTPBody:data];
    }


    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self];
    self.responseData = nil;
    self.connection = connection;
    self.connectionData = [NSMutableData data];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.connectionData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.connectionData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.connection = nil;
    self.connectionData = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.delegate respondsToSelector:self.didFailWithErrorSelector]) {
        [self.delegate performSelector:self.didFailWithErrorSelector withObject:self withObject:error];
    }
#pragma clang diagnostic pop
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.responseData = [self.connectionData copy];

    self.connection = nil;
    self.connectionData = nil;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([self.delegate respondsToSelector:self.didFinishLoadingSelector]) {
        [self.delegate performSelector:self.didFinishLoadingSelector withObject:self];
    }
#pragma clang diagnostic pop
}


@end
