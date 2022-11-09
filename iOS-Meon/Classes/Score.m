//
//  Score.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/9/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "Score.h"


@implementation Score


#pragma mark - init / dealloc

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    if (self = [super init]){
        id object = dictionary[@"username"];
        if (object  && ([object isKindOfClass:[NSString class]])){
            self.user = (NSString*)object;
        }
        else{
            self.user=@"invalid";
        }
        
        object = dictionary[@"scorevalue"];
        if (object  && ([object isKindOfClass:[NSString class]])){
            self.value = (NSString*)object;
        }
        else{
            self.value=@"0";
        }
    }
    
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    Score *copy = [[[self class] allocWithZone:zone] init];
    copy.user = self.user;
	copy.value = self.value;
	copy.type = self.type;
	copy.scoreId = self.scoreId;
    return copy;
}


- (NSComparisonResult)compare:(Score*)aScore
{
	// test validity
	if (!self.isValid){
		if (!aScore.isValid)
			return NSOrderedSame;
		else
			return NSOrderedDescending;
	}
	else {
		// sanity check
		if (!aScore.isValid)
			return NSOrderedAscending;
		// two are valids
		else {
			int value0 = self.value.intValue;
			int value1 = aScore.value.intValue;
			if (value0 > value1) {
				return  NSOrderedDescending;
			}
			else if (value0 < value1){
				return NSOrderedAscending;
			}
			else {
				return NSOrderedSame;
			}
		}
	}
}


#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInt:1 forKey:@"version"];
    [encoder encodeObject:self.user forKey:@"user"];
	[encoder encodeObject:self.value forKey:@"value"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.scoreId forKey:@"scoreId"];
    
}


- (id)initWithCoder:(NSCoder *)decoder
{
    int version = [decoder decodeIntForKey:@"version"];
    if (version == 1){
        self.user = [decoder decodeObjectForKey:@"user"];
        self.value = [decoder decodeObjectForKey:@"value"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.scoreId = [decoder decodeObjectForKey:@"scoreId"];
        
    }
    return self;
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"user=%@ value=%@ type=%@ scoreId=%@",
			self.user, self.value, self.type, self.scoreId];
}

-(BOOL)isValid
{
	return self.user && self.value;
}

@end
