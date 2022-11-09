//
//  UIBitmapNumberView.m
//  ExoLife
//
//  Created by Jean-Christophe Amiel on 02/06/09.
//  Copyright 2009 Manbolo. All rights reserved.
//

#import "CMBitmapNumberView.h"
#import "Common.h"
#import "UIView+Helper.h"

@interface CMBitmapNumberView ()

@property (nonatomic, assign) CGFloat digitHeight;
@property (nonatomic, assign) CGFloat digitWidth;
@property (nonatomic, readwrite) NSUInteger numberOfDigit;

@end

@implementation CMBitmapNumberView

#pragma mark - init / dealloc

- (id)initWithFrame:(CGRect)aRect {
    self = [super initWithFrame:aRect];
    if (self) {
        self.hidesWhenValueIsZero = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (self) {
        self.hidesWhenValueIsZero = NO;
    }
    return self;
}

#pragma mark - Properties

- (void)setValue:(NSInteger)newValue {
    _value = newValue;
    if (_value) { self.numberOfDigit = (NSUInteger)(log10(_value)) + 1; }
    else { self.numberOfDigit = 1; }
    if (self.hidesWhenValueIsZero) {
        self.hidden = (_value == 0);
    }
    [self setNeedsDisplay];
}

- (void)setDigitsImage:(UIImage *)newImage {
    _digitsImage = newImage;
    self.digitWidth = newImage.size.width / 10;
    self.digitHeight = newImage.size.height;

    //DebugLog(@"digitsWidth=%.0f digitsHeight=%.0f",self.digitWidth, self.digitHeight);
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    int i = 0, base = 1, mod = 0, digit = 0;
    CGImageRef digitsImageRef = self.digitsImage.CGImage;
    CGImageRef bmp;
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat digitWidthInPixel = self.digitWidth * scale;
    CGFloat digitHeightInPixel = self.digitHeight * scale;

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextTranslateCTM (context, 0, self.bounds.size.height);
    CGContextScaleCTM (context, 1.0, -1.0);

    CGRect srcRect = CGRectMake(0, 0, digitWidthInPixel, digitHeightInPixel);
    CGRect dstRect = CGRectMake(0, 0, self.digitWidth, self.digitHeight);

    CGFloat x = (self.alignment == NSTextAlignmentRight) ?
                self.bounds.size.width - self.digitWidth :
                (self.numberOfDigit-1)*(self.digitWidth*(1+self.letterSpacing));

    for(i = 0; i < self.numberOfDigit; i++) {

        mod = base * 10;
        digit = (self.value % mod) / base;
        base = base *10;

        srcRect.origin.x = digit * digitWidthInPixel;
        srcRect.origin.y = 0;
        dstRect.origin.x = x;
        dstRect.origin.y = 0;
        x -= (self.digitWidth*(1+self.letterSpacing));

        bmp = CGImageCreateWithImageInRect(digitsImageRef, srcRect);
        CGContextDrawImage(context, dstRect, bmp);
        CGImageRelease(bmp);

    }
}

- (void)sizeToFit {
    // let the x, and y as there are
    CGFloat newWidth = floor(self.digitWidth + (self.numberOfDigit-1)*(self.digitWidth*(1+self.letterSpacing)));

    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                                 newWidth, self.digitHeight);
    self.frame = newFrame;

}

@end
