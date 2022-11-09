//
//  Sprite.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/3/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SpriteSheet;


@interface Sprite : NSObject

@property (nonatomic, assign, getter=isSoundEnabled) BOOL soundEnabled;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, strong) CALayer *layer;
@property (nonatomic, assign) unsigned int type;
@property (nonatomic, assign) unsigned int light;
@property (nonatomic, assign, getter=isMoveable) BOOL moveable;
@property (nonatomic, weak) CALayer *superlayer;
@property (nonatomic, assign, getter=isDirty) BOOL dirty;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, assign) NSUInteger framesCount;
@property (nonatomic, assign) unsigned int direction;
@property (nonatomic, strong) SpriteSheet *spriteSheet;

- (void)touchesBegan;
- (void)touchesMoved;
- (void)touchesEnded;
- (void)touchesCancelled;
- (void)updateFrames;

@end
