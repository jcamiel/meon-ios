//
//  NSString+Helper.m
//  Manbolo
//
//  Created by Jean-Christophe Amiel on 20/05/09.
//  Copyright 2009 Manbolo. All rights reserved.
//

#import "NSString+Helper.h"


@implementation NSString (Helper)

- (NSString *)substringWithRangeEx:(NSRange)range
{
	if ((range.location + range.length) > [self length])
		return nil;
	else
		return [self substringWithRange:range];
}

- (BOOL)isPhoneNumber
{
	NSRange elementRange = [self rangeOfString:@"tel:"];
	return (elementRange.location != NSNotFound);
}

- (BOOL)isMailAddress
{
	NSRange elementRange = [self rangeOfString:@"mailto:"];
	return (elementRange.location != NSNotFound);
}

- (NSString *)stringByDeletingPrefix:(NSString*)prefix
{
    if ([self hasPrefix:prefix]){
        return [self substringFromIndex:prefix.length];
    }
    else{
        return [self copy];
    }
}



@end
