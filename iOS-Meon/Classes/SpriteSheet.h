//
//  SpriteSheet.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/12/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Sprite;

@interface SpriteSheet : NSObject

@property (nonatomic, strong) UIImage *imageSource;
@property (nonatomic, strong) NSDictionary *dataSource;
@property (nonatomic, assign) CGSize textureSourceSize;
@property (nonatomic, strong) NSMutableDictionary *items;
@property (nonatomic, assign) CGFloat scale;


- (void)updateSprite:(Sprite*)sprite forKey:(NSString*)name frameCount:(NSInteger)frameCount;

@end
