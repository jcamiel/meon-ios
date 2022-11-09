//
//  NSMutableDictionary+Helper.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 12/29/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableDictionary (Helper)

- (void)setObjectSafe:(id)anObject forKey:(id)aKey;

@end
