//
//  NSKeyedArchiver+Helper.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/1/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "NSKeyedArchiver+Helper.h"
#import "UIApplication+Helper.h"

@implementation NSKeyedArchiver (Helper)

+ (BOOL)archiveRootObject:(id)rootObject toDocumentFile:(NSString*)fileName
{
    NSString *userDocumentsPath = [UIApplication documentDirectory];
    if (!userDocumentsPath) return NO;
    
    NSString *fullName = [NSString stringWithFormat:@"%@/%@", userDocumentsPath,fileName];
    BOOL ret = [NSKeyedArchiver archiveRootObject:rootObject
                                           toFile:fullName];
    if (!ret){
        DebugLog(@"unable to archive file name %@", fileName);
    }
    return ret;
	
}




@end
