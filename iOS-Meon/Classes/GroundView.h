//
//  GroundView.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMType.h"

@interface GroundView : UIView

@property (nonatomic, assign) uint32 *dataSource;
@property (nonatomic, assign) NSUInteger theme;
@property (nonatomic, assign) CGFloat cellWidthInPoint;
- (UIImage*)rasterizedImage;



@end
