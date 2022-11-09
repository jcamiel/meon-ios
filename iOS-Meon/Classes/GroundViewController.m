//
//  GroundViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 6/13/11.
//  Copyright 2011 Manbolo. All rights reserved.
//
#import "GroundViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "GroundView.h"
#import "Level.h"
#import "UIView+Helper.h"

@interface GroundViewController ()

@property (nonatomic, strong) NSMutableDictionary * selectedSprites;

@end

@implementation GroundViewController



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    CGFloat cellWidth = self.level.cellWidthInPoint;

    self.touchesInteractionEnabled = YES;

    self.selectedSprites = [[NSMutableDictionary alloc] init];

    //UIColor *backgroundColor = [UIColor colorWithRed:37.0f/255 green:44.0f/255 blue:64.0f/255 alpha:1.0f];
    UIColor *backgroundColor = [UIColor clearColor];

    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12*cellWidth, 12*cellWidth)];
    self.view.backgroundColor = backgroundColor;

    // create ground view
    self.groundView = [[GroundView alloc] initWithFrame:(CGRect){{0, 0}, {12*cellWidth, 12*cellWidth}}];
    self.groundView.backgroundColor = [UIColor clearColor];
    self.groundView.cellWidthInPoint = cellWidth;
    self.level.layoutView = self.groundView;
    self.groundView.dataSource = self.level.cells;
    self.groundView.multipleTouchEnabled = YES;

    [self.view addSubview:self.groundView];


}

- (void)updateViewFrame:(NSNotification *)theNotif {
    CGFloat gameWidth = 12 * self.level.cellWidthInPoint;
    CGFloat gameHeight = 12 * self.level.cellWidthInPoint;

    CGSize contentSize = self.view.bounds.size;

    CGSize aspectSize = contentSize;
    CGFloat scale;
    if ((aspectSize.width / aspectSize.height) > (gameWidth / gameHeight)) {
        scale = aspectSize.height / gameHeight;
        aspectSize.width = (CGFloat)(aspectSize.height * (gameWidth / gameHeight));
    }
    else {
        scale = aspectSize.width / gameWidth;
        aspectSize.height = (CGFloat)(aspectSize.width * (gameHeight / gameWidth));
    }

    self.groundView.layer.transform = CATransform3DMakeScale(scale, scale, 1.0f);
    self.groundView.layer.frame =
        CGRectMake(
            floor(0.5f * (contentSize.width - aspectSize.width)),
            floor(0.5f * (contentSize.height - aspectSize.height)),
            floor(aspectSize.width),
            floor(aspectSize.height));

}

/*
   // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
   - (void)viewDidLoad
   {
    [super viewDidLoad];
   }
 */

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Touch managment
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    DebugLog(@"touchesBegan %d",touches.count);
    if (!self.touchesInteractionEnabled) {
        [self.delegate touchesBegan:touches withEvent:event];
        return;
    }

    for(UITouch *touch in touches) {
        CGPoint pt = [touch locationInView:self.groundView];
        Sprite *sprite = [self.level nearestSprite:pt inRadius:(CGFloat)1.5*30 meonFiltered:YES];
        if (!sprite) {continue; }

        NSNumber *key = @([touch hash]);
        self.selectedSprites[key] = sprite;
        [sprite touchesBegan];
    }

    [self touchesMoved:touches withEvent:event];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    DebugLog(@"touchesMoved %d",touches.count);
    if (!self.touchesInteractionEnabled) {
        [self.delegate touchesMoved:touches withEvent:event];
        return;
    }

    int colDst, rowDst, colSrc, rowSrc;
    CGFloat cellWidth = self.level.cellWidthInPoint;


    for(UITouch *touch in touches) {

        NSNumber *key = @([touch hash]);
        Sprite * selectedSprite = self.selectedSprites[key];
        CGPoint pt = [touch locationInView:self.groundView];

        colDst = (int)(pt.x / cellWidth);
        rowDst = (int)(pt.y / cellWidth);
        colSrc = (int)(selectedSprite.center.x / cellWidth);
        rowSrc = (int)(selectedSprite.center.y / cellWidth);


        //DebugLog(@"colDst= %d rowDst= %d", colDst, rowDst);

        if (((colDst == colSrc) && (rowDst == rowSrc)) ||
            ([self.level tileAtCol:colDst row:rowDst] >= kTilePlain) ||
            (colDst <= 0) || (colDst >= 11) ||
            (rowDst <= 0) || (rowDst >= 11) ||
            !selectedSprite) {
            continue;
        }

        selectedSprite.center = (CGPoint){(colDst * cellWidth) + (cellWidth/2),
                                          (rowDst * cellWidth) + (cellWidth/2)};

        [self.level moveSprite:selectedSprite colSrc:colSrc rowSrc:rowSrc colDst:colDst rowDst:rowDst];
    }

    if ([self.level isCompleted]) {
        [self.selectedSprites removeAllObjects];
        [self.delegate groundViewLevelDidCompleted:self];
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    DebugLog(@"touchesEnded %d",touches.count);
    if (!self.touchesInteractionEnabled) {
        [self.delegate touchesEnded:touches withEvent:event];
        return;
    }


    for(UITouch *touch in touches) {
        NSNumber *key = @([touch hash]);
        [self.selectedSprites removeObjectForKey:key];
    }

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    DebugLog(@"touchesCancelled %d",touches.count);
    if (!self.touchesInteractionEnabled) {
        [self.delegate touchesCancelled:touches withEvent:event];
        return;
    }

    [self touchesEnded:touches withEvent:event];
}

- (void)setLevel:(Level *)level {
    _level = level;

    self.groundView.dataSource = _level.cells;
    _level.layoutView = self.groundView;

    [self.groundView setNeedsDisplay];
}

- (void)rasterizeGroundView {
    UIImage *image = [self.groundView rasterizedImage];
    self.rasterizedGroundView = [[UIImageView alloc] initWithImage:image];
    self.rasterizedGroundView.frame = self.groundView.frame;
    [self.view addSubview:self.rasterizedGroundView];
    [self.groundView removeFromSuperview];
    self.groundView = nil;

}

@end
