//
//  NSMutableDictionary+Helper.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 12/29/10.
//  Copyright 2010 Manbolo. All rights reserved.
//



@implementation NSMutableDictionary (Helper)

- (void)setObjectSafe:(id)anObject forKey:(id)aKey
{
	if (anObject){
		self[aKey] = anObject;
	}
	else {
		DebugLog(@"object nil for key=%@", aKey);
	}
}

@end
