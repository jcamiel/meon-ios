//
//  Achievment.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 11/18/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "Achievement.h"

#import "NSMutableDictionary+Helper.h"
#import "NSString+Helper.h"

@implementation Achievement

#pragma mark - Init

// - (id)init / dealloc
//
- (id)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _identifier = [dic[@"identifier"] copy];
        _completed = [dic[@"completed"] boolValue];
        _index = [dic[@"index"] intValue];
        _value = [dic[@"value"] intValue];

        _labelFileName = [[NSString alloc] initWithFormat:
                          @"Achievements/%@_label.png", _identifier];
        _iconFileName = [[NSString alloc] initWithFormat:
                         @"Achievements/%@_icon.png", _identifier];

    }

    return self;
}

- (NSDictionary *)dictionaryFromAchievement {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    [dic setObjectSafe:self.identifier forKey:@"identifier"];
    [dic setObjectSafe:@(self.completed) forKey:@"completed"];
    [dic setObjectSafe:@(self.index) forKey:@"index"];
    [dic setObjectSafe:@(self.value) forKey:@"value"];

    return dic;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %d", self.identifier, self.completed];
}

- (NSComparisonResult)compare:(Achievement *)otherAchievement {
    if (self.index > otherAchievement.index) {
        return NSOrderedDescending;
    }
    else if (self.index < otherAchievement.index) {
        return NSOrderedAscending;
    }
    else {
        return NSOrderedSame;
    }

}

@end
