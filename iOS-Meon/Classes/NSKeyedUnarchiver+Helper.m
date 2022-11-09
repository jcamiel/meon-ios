//
//  NSKeyedUnarchiver+Helper.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 2/1/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "NSKeyedUnarchiver+Helper.h"
#import "UIApplication+Helper.h"

@implementation NSKeyedUnarchiver (Helper)

+ (id)unarchiveObjectWithDocumentFile:(NSString*)fileName
{
    NSString *userDocumentsPath = [UIApplication documentDirectory];
    if (!userDocumentsPath) return nil;

    NSString *fullName = [NSString stringWithFormat:@"%@/%@", 
                          userDocumentsPath, fileName];
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:fullName];
    if (!object){
        DebugLog(@"unable to unarchive file %@", fileName);
    }
    return object;
}



@end
