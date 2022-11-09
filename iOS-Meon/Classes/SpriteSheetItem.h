//
//  SpriteSheetItem.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/13/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpriteSheetItem : NSObject

@property (nonatomic, assign) CGRect contentsRect;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGPoint spriteOffset;

@end
