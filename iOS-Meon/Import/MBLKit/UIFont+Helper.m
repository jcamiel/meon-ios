//
//  UIFont+Helper.m
//  MBLKit
//
//  Created by Jean-Christophe Amiel on 13/01/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import "UIFont+Helper.h"

@implementation UIFont (Helper)

- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width lineNumber:(NSInteger)lineNumber {
    if (text == nil) {
        return 1;
    }

    CGSize size = CGSizeMake(width, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName : self};
    CGRect r = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:attributes
                                  context:nil];
    // Hauteur sans contrainte de lignes
    CGFloat maxHeight = r.size.height + 1;
    if (lineNumber != 0) {
        return ceilf(MIN(self.lineHeight * lineNumber, maxHeight));
    }

    // On ajoute 1 pt de padding.
    return ceilf(maxHeight);
}


- (CGFloat)heightForText:(NSString *)text width:(CGFloat)width {
    return [self heightForText:text width:width lineNumber:0];
}


- (CGFloat)widthForText:(NSString *)text {
    if (text == nil) {
        return 1;
    }

    CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName : self};
    CGRect r = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:attributes
                                  context:nil];
    // Hauteur sans contrainte de lignes
    CGFloat width = r.size.width + 1;

    // On ajoute 1 pt de padding.
    return ceilf(width);
}


- (CGSize)sizeForText:(NSString *)text {
    if (text == nil) {
        return CGSizeZero;
    }

    CGSize size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName : self};
    CGRect r = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:attributes
                                  context:nil];
    CGFloat width = ceilf(r.size.width + 1);
    CGFloat height = ceilf(r.size.height + 1);

    return CGSizeMake(width, height);
}


@end
