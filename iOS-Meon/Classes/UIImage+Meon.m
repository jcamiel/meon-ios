//
//  UIImage+Meon.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 14/06/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import "UIImage+Meon.h"

@implementation UIImage (Meon)

+ (UIImage *)splashScreenImageWidth:(CGFloat)width height:(CGFloat)height {
    NSString *imageName = [NSString stringWithFormat:@"%dx%d", (int)width, (int)height];
    UIImage *image = [UIImage imageNamed:imageName];
    
    // Image par défault, on se rabbat sur la résolution iPhone 5 sur iPad
    // et la résolution iPad classique sur iPad.
    if (!image) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            image = [UIImage imageNamed:@"320x568"];
        }
        else {
            if (width > height) {
                image = [UIImage imageNamed:@"1024x768"];
            }
            else {
                image = [UIImage imageNamed:@"768x1024"];
            }
        }
    }
    
    return image;
}


@end
