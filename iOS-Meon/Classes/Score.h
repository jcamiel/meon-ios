//
//  Score.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/9/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Score : NSObject<NSCopying>

@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *scoreId;
@property (nonatomic,readonly, getter=isValid) BOOL valid;

- (id)initWithDictionary:(NSDictionary*)dictionary;

@end
