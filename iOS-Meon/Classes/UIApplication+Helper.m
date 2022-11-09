//
//  UIApplication+Helper.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/19/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "UIApplication+Helper.h"


@implementation UIApplication (Helper)

+ (NSString*)documentDirectory
{
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
														 NSUserDomainMask, YES);
    if ([paths count] > 0) {
		return paths[0];
    }
    else{
        return nil;
    }

#else
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, 
														 NSUserDomainMask, YES);
    
    // TODO: change this
    if ([paths count] > 0) {
		NSString *pathName = [NSString stringWithFormat:@"%@/Meon",[paths objectAtIndex:0]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:pathName]){
            [fileManager createDirectoryAtPath:pathName withIntermediateDirectories:YES attributes:nil error:nil];
        }
        return pathName;
    }
    else{
        return nil;
    }
    
    
    
#endif
    
}

@end
