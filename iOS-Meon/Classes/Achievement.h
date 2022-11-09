//
//  Achievment.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 11/18/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Achievement : NSObject

// Designate initializer
- (id)initWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)dictionaryFromAchievement;

@property (nonatomic, assign) NSInteger index;

// Achievement identifier
@property (nonatomic, copy) NSString *identifier;

// Set to NO until percentComplete = 100.
@property (nonatomic, assign, getter=isCompleted) BOOL completed;
@property (nonatomic, readonly) NSString *labelFileName;
@property (nonatomic, readonly) NSString *iconFileName;
@property (nonatomic, assign) NSInteger value;

@end
