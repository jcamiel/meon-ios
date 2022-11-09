//
//  SpriteSheet.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/12/11.
//  Copyright 2011 Manbolo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SpriteSheet.h"
#import "Sprite.h"
#import "SpriteSheetItem.h"

@implementation SpriteSheet


- (id)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableDictionary alloc] init];
        _scale = [[UIScreen mainScreen] scale];
    }
    return self;
}




- (void)setDataSource:(NSDictionary *)newDataSource
{
    _dataSource = newDataSource;
    
    NSDictionary *metaDataDictionary = _dataSource[@"metadata"];
    NSString *sizeString = metaDataDictionary[@"size"];
    _textureSourceSize = CGSizeFromString(sizeString);
}



- (void)updateSprite:(Sprite*)sprite forKey:(NSString*)keyName frameCount:(NSInteger)frameCount
{
    CALayer *layer = sprite.layer;
    NSString *frameNamePattern = @"%@-%d"; 
    
    // set the base content - frame for index 0
    NSString *frameName = [NSString stringWithFormat:frameNamePattern,keyName,0];
    [layer removeAllAnimations];
    UIImage *image = [UIImage imageNamed:frameName];
    if (!image){
        DebugLog(@"Error in frame[%@]",frameName);
    }

    CGFloat widthInPoint = image.size.width;
    CGFloat heightInPoint = image.size.height;
    layer.bounds = (CGRect){{0,0},{widthInPoint,heightInPoint}};
    layer.position = (CGPoint){sprite.center.x, sprite.center.y};
    layer.contents = (id)image.CGImage;

    // if the sprite is animated, add an animation on the layer
    if (frameCount > 1) {
        CAKeyframeAnimation *contentAnimation = [CAKeyframeAnimation 
                                                 animationWithKeyPath:@"contents"];
        
        NSMutableArray *values = [NSMutableArray array];

        for(NSInteger i=0; i < frameCount; i++){
            frameName = [NSString stringWithFormat:frameNamePattern,keyName,i];
            image = [UIImage imageNamed:frameName];
            if (image){
                [values addObject:(id)image.CGImage];
            }
            else{
                DebugLog(@"Error in animation frame[%@]",frameName);
            }
        }
        
        contentAnimation.calculationMode = kCAAnimationDiscrete;
        contentAnimation.values = values;
        contentAnimation.autoreverses = YES;
        contentAnimation.duration = 2.0;
        contentAnimation.repeatCount = (float)HUGE_VAL;
        
        
        [layer addAnimation:contentAnimation forKey:@"contents"];
        
    }
   
}


@end
