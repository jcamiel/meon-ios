//
//  NSKeyedArchiver+Helper.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/1/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSKeyedArchiver (Helper)

+ (BOOL)archiveRootObject:(id)rootObject toDocumentFile:(NSString*)fileName;


@end
