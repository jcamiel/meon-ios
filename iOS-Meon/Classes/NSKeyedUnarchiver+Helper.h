//
//  NSKeyedUnarchiver+Helper.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/1/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSKeyedUnarchiver (Helper)

+ (id)unarchiveObjectWithDocumentFile:(NSString*)fileName;

@end
