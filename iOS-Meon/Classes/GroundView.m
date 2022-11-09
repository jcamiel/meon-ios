//
//  GroundView.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 1/2/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "GroundView.h"
#import "tile.h"
#import <QuartzCore/QuartzCore.h>

#define TILE_AT_COL_ROW(A, B) (((A >= 0) && (A <= 11) && (B >= 0) && (B <= 11)) ? \
                               (_dataSource[(A)+12*(B)]) : kTilePlain)

@implementation GroundView



#pragma mark - init

- (void)awakeFromNib {
    self.cellWidthInPoint = 30.0f;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.cellWidthInPoint = 30.0f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {

    int col, row, a, b, c, d, e, f, g, h, i;
    if (!self.dataSource) {return; }

    CGFloat scale = self.contentScaleFactor;
    NSString *imageName = [NSString stringWithFormat:@"wall%lu", (unsigned long)self.theme];

    UIImage *wall = [UIImage imageNamed:imageName];
    CGImageRef wallRef = wall.CGImage;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat subCellWidthInPoint = self.cellWidthInPoint / 2;
    CGFloat subCellWidthInPixel = subCellWidthInPoint * scale;
    CGRect dstSubCellRectInPoint = CGRectMake(0, 0, subCellWidthInPoint, subCellWidthInPoint);


    for(row = 0; row < 12; row++) {
        for(col = 0; col < 12; col++) {

            CGRect dstCellRectInPoint = (CGRect){{col * self.cellWidthInPoint,
                   row * self.cellWidthInPoint},
                                                 {self.cellWidthInPoint,
                                                  self.cellWidthInPoint}};


            if (!CGRectIntersectsRect(dstCellRectInPoint, rect)) {
                continue;
            }

            a = TILE_AT_COL_ROW(col-1, row-1);
            b = TILE_AT_COL_ROW(col+0, row-1);
            c = TILE_AT_COL_ROW(col+1, row-1);
            d = TILE_AT_COL_ROW(col-1, row+0);
            e = TILE_AT_COL_ROW(col+0, row+0);
            f = TILE_AT_COL_ROW(col+1, row+0);
            g = TILE_AT_COL_ROW(col-1, row+1);
            h = TILE_AT_COL_ROW(col+0, row+1);
            i = TILE_AT_COL_ROW(col+1, row+1);

            // fill entire cell
            if (e != kTilePlain) {
                CGContextSetRGBFillColor(context, 41.0f/255, 40.0f/255, 49.0f/255, 1.0f);
                CGContextFillRect(context, dstCellRectInPoint);
                continue;
            }
            else {

                CGImageRef bmp = NULL;
                uint32 type = 0;

                // a Cell is divided in four subcell :
                // 0 1
                // 2 3

                // subcell 0
                dstSubCellRectInPoint.origin.x = col * self.cellWidthInPoint;
                dstSubCellRectInPoint.origin.y = row * self.cellWidthInPoint;

                type = (d == kTilePlain) + 2*(a == kTilePlain) + 4*(b == kTilePlain);
                if (type != 7) {
                    CGRect srcSubCellRectInPixel = (CGRect){   {type * subCellWidthInPixel,
                                                                0 * subCellWidthInPixel},
                                                               {subCellWidthInPixel,
                                                                subCellWidthInPixel}};

                    bmp = CGImageCreateWithImageInRect(wallRef, srcSubCellRectInPixel);
                    CGContextDrawImage(context, dstSubCellRectInPoint, bmp);
                    CGImageRelease(bmp);
                }

                // subcell 1
                dstSubCellRectInPoint.origin.x += subCellWidthInPoint;

                type = (b == kTilePlain) + 2*(c == kTilePlain) + 4*(f == kTilePlain);
                if (type != 7) {
                    CGRect srcSubCellRectInPixel = (CGRect){   {type * subCellWidthInPixel,
                                                                1 * subCellWidthInPixel},
                                                               {subCellWidthInPixel,
                                                                subCellWidthInPixel}};

                    bmp = CGImageCreateWithImageInRect(wallRef, srcSubCellRectInPixel);
                    CGContextDrawImage(context, dstSubCellRectInPoint, bmp);
                    CGImageRelease(bmp);

                }

                // subcell 2
                dstSubCellRectInPoint.origin.x = col * self.cellWidthInPoint;
                dstSubCellRectInPoint.origin.y = row * self.cellWidthInPoint + subCellWidthInPoint;

                type = (h == kTilePlain) + 2*(g == kTilePlain) + 4*(d == kTilePlain);
                if (type != 7) {
                    CGRect srcSubCellRectInPixel = (CGRect){   {type * subCellWidthInPixel,
                                                                2 * subCellWidthInPixel},
                                                               {subCellWidthInPixel,
                                                                subCellWidthInPixel}};

                    bmp = CGImageCreateWithImageInRect(wallRef, srcSubCellRectInPixel);
                    CGContextDrawImage(context, dstSubCellRectInPoint, bmp);
                    CGImageRelease(bmp);

                }

                // subcell 3
                dstSubCellRectInPoint.origin.x = col * self.cellWidthInPoint + subCellWidthInPoint;
                dstSubCellRectInPoint.origin.y = row * self.cellWidthInPoint + subCellWidthInPoint;

                type = (f == kTilePlain) + 2*(i == kTilePlain) + 4*(h == kTilePlain);
                if (type != 7) {
                    CGRect srcSubCellRectInPixel = (CGRect){   {type * subCellWidthInPixel,
                                                                3 * subCellWidthInPixel},
                                                               {subCellWidthInPixel,
                                                                subCellWidthInPixel}};

                    bmp = CGImageCreateWithImageInRect(wallRef, srcSubCellRectInPixel);
                    CGContextDrawImage(context, dstSubCellRectInPoint, bmp);
                    CGImageRelease(bmp);


                }

            }
        }
    }

}

- (void)dealloc {
    self.dataSource = NULL;
}

- (UIImage *)rasterizedImage {
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
