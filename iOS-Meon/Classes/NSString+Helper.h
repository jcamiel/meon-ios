//
//  NSString+Helper.h
//  Manbolo
//
//  Created by Jean-Christophe Amiel on 20/05/09.
//  Copyright 2009 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (NSString *)substringWithRangeEx:(NSRange)range;
- (BOOL)isPhoneNumber;
- (BOOL)isMailAddress;
- (NSString *)stringByDeletingPrefix:(NSString*)prefix;

@end