/*
 *  Common.h
 *
 *  Created by Jean-Christophe Amiel on 23/02/09.
 *  Copyright 2009 Manbolo. All rights reserved.
 *
 */
//#define PREPROD

#if defined(DEBUG)
#define DebugLog(xx, ...)  NSLog(@"[%20.20s:%4d] " xx, [[[NSString stringWithCString:__FILE__ encoding:NSASCIIStringEncoding] lastPathComponent] UTF8String], __LINE__, ##__VA_ARGS__)
#else
#define DebugLog(xx, ...)  ((void)0)
#endif

