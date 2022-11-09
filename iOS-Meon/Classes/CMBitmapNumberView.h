//
//  UIBitmapNumberView.h
//  ExoLife
//
//  Created by Jean-Christophe Amiel on 02/06/09.
//  Copyright 2009 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CMBitmapNumberView : UIView

@property (nonatomic) NSInteger value;
@property (nonatomic, readonly) NSUInteger numberOfDigit;
@property (nonatomic, strong) UIImage *digitsImage;
@property (nonatomic, assign) CGFloat letterSpacing;
@property (nonatomic, assign) UITextAlignment alignment;
@property (nonatomic, assign) BOOL hidesWhenValueIsZero;

@end
