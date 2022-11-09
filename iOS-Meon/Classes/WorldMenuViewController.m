//
//  WorldMenuViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/3/11.
//  Copyright 2011 Manbolo. All rights reserved.
//

#import "WorldMenuViewController.h"

#import <QuartzCore/CALayer.h>

#import "GameManager.h"
#import "LevelManager.h"
#import "ThumbnailAnimator.h"
#import "UIView+Helper.h"



@interface WorldMenuViewController ()
@property (nonatomic, strong) NSMutableArray *thumbnailButtons;
@end



@implementation WorldMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)dealloc {
    [[LevelManager sharedLevelManager] removeObserver:self
                                           forKeyPath:@"worldLevels"];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [(UIImageView *)self.view setImage:[UIImage imageNamed:@"Default.png"]];

    // create the thumbnail buttons list
    self.thumbnailButtons = [[NSMutableArray alloc] init];


    // register to modification of the worldLevels
    [[LevelManager sharedLevelManager] addObserver:self
                                        forKeyPath:@"worldLevels"
                                           options:NSKeyValueObservingOptionNew
                                           context:NULL];

    // create the temporary working view to capture level view
    GroundView *levelView = [[GroundView alloc] initWithFrame:CGRectMake(0, 0, 360, 360)];
    levelView.backgroundColor = [UIColor colorWithRed:37.0 / 255 green:44.0 / 255 blue:64.0 / 255 alpha:1.0];
    levelView.opaque = YES;
    CGFloat widthTile = 9.0;

    Level * level = [[Level alloc] init];

    self.completedLevelIndex = [NSMutableIndexSet indexSet];


    for(int i = 0; i < 9; i++) {
        UIImage * thumbnailImage = nil;
        BOOL completed;

        // create a button for level i
        UIButton *thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        thumbnailButton.tag = i;
        thumbnailButton.frame = CGRectMake((i % 3) * 106 + 4, 80 + (i / 3) * 106, widthTile * 11, widthTile * 11);
        thumbnailButton.enabled = NO;
        [thumbnailButton addTarget:self
                            action:@selector(thumbnailDidPress:)
                  forControlEvents:UIControlEventTouchUpInside];
        thumbnailButton.backgroundColor = [UIColor cyanColor];

        [self.view addSubview:thumbnailButton];
        [self.thumbnailButtons addObject:thumbnailButton];

        // load the level at index i
        NSMutableDictionary *levelDictionary = [[LevelManager sharedLevelManager] worldLevels][i];

        thumbnailImage = [self thumbnailImageForLevelDictionary:levelDictionary
                                                   workingLevel:level
                                               workingLevelView:levelView
                                                      widthTile:widthTile
                                                      completed:&completed];

        [thumbnailButton setImage:thumbnailImage forState:UIControlStateNormal];

        // if level is completed
        if (completed) {
            [self.completedLevelIndex addIndex:i];
        }
        else {
            thumbnailButton.enabled = YES;
        }
    }


    // get rid of levelView
}


- (UIImage *)thumbnailImageForLevelDictionary:(NSDictionary *)levelDictionary
                                 workingLevel:(Level *)level
                             workingLevelView:(GroundView *)levelView
                                    widthTile:(CGFloat)widthTile
                                    completed:(BOOL *)completed {
    UIImage * thumbnailImage;
    if (completed) {*completed = NO; }

    if ([levelDictionary isKindOfClass:[NSNull class]]) {
        thumbnailImage = [UIImage imageNamed:@"Miniatures/mini.png"];
        return thumbnailImage;
    }

    // at this point, there is a valid level
    NSString * compressedString = levelDictionary[kLevelOriginalKey];

    // first, create the ground view
    levelView.dataSource = level.cells;
    level.layoutView = levelView;
    [level loadFromString:compressedString centerView:NO];
    [levelView setNeedsDisplay];
    if (completed) {*completed = [level isCompleted]; }


    // capture it
    UIGraphicsBeginImageContext(levelView.bounds.size);
    [levelView.layer renderInContext:UIGraphicsGetCurrentContext()];
    thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // reset levelView
    [level removeSprites];

    // resize level view
//    thumbnailImage = [thumbnailImage resizedImage:CGSizeMake(widthTile * 12, widthTile * 12)
//                             interpolationQuality:kCGInterpolationHigh];

//    thumbnailImage = [thumbnailImage croppedImage:CGRectMake(4, 4, widthTile * 11, widthTile * 11)];

    return thumbnailImage;
}


- (void)viewDidUnload {
    [[LevelManager sharedLevelManager] removeObserver:self
                                           forKeyPath:@"worldLevels"];
    [self setLevel0View:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Actions

- (IBAction)back:(id)sender {
    [self.delegate worldMenuDidSelectBack:self];
}


- (IBAction)thumbnailDidPress:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {

        UIView *view = (UIView *)sender;
        NSInteger levelIndex = view.tag;
        self.view.userInteractionEnabled = NO;

        [self addThumbnailAnimationAtIndex:levelIndex zoomIn:YES];
    }
}


- (void)addThumbnailAnimationAtIndex:(NSInteger)levelIndex zoomIn:(BOOL)zoomIn {
}


- (void)thumbnailZoomInAnimationDidStop {
    [self.delegate worldMenu:self didSelectLevelIndex:self.selectedLevelIndex];
}


- (void)thumbnailZoomOutAnimationDidStop {
    [[LevelManager sharedLevelManager] renewWorldLevelsAtIndexSet:self.completedLevelIndex];
    [self.completedLevelIndex removeAllIndexes];
}


#pragma mark - KVO notifications
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"worldLevels"]) {


        GroundView *levelView = [[GroundView alloc] initWithFrame:CGRectMake(0, 0, 360, 360)];
        levelView.backgroundColor = [UIColor colorWithRed:37.0 / 255
                                                    green:44.0 / 255
                                                     blue:64.0 / 255
                                                    alpha:1.0];
        levelView.opaque = YES;

        Level * level = [[Level alloc] init];

        NSArray * levelDictionarys = change[NSKeyValueChangeNewKey];

        NSIndexSet *indexSet = change[NSKeyValueChangeIndexesKey];

        NSUInteger currentIndex = [indexSet firstIndex];
        NSUInteger levelIndex = 0;

        while (currentIndex != NSNotFound) {

            DebugLog(@"Thumbnail %lu will change", (unsigned long)currentIndex);

            NSDictionary *levelDictionary = levelDictionarys[levelIndex++];

            UIImage * thumbnailImage = [self thumbnailImageForLevelDictionary:levelDictionary
                                                                 workingLevel:level
                                                             workingLevelView:levelView
                                                                    widthTile:9.0
                                                                    completed:NULL];

            UIButton * thumbnailButton = self.thumbnailButtons[currentIndex];

            thumbnailButton.enabled = levelDictionary &&
                                      ![levelDictionary isKindOfClass:[NSNull class]];

            [UIView beginAnimations:@"thumbnailRenewal" context:nil];
            [UIView setAnimationDuration:0.75];
//            [UIView setAnimationDelegate:self];
//            [UIView setAnimationDidStopSelector:@selector(transitionDidStop:finished:context:)];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                                   forView:thumbnailButton
                                     cache:YES];
            [thumbnailButton setImage:thumbnailImage forState:UIControlStateNormal];
            [UIView commitAnimations];


            currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
        }
    }
}


- (void)transitionAnimationDidStopFrom:(NSString *)from to:(NSString *)to {
    DebugLog(@"transition from %@ to %@", from, to);

    if ([from isEqualToString:@"Play"]) {
        [self addThumbnailAnimationAtIndex:self.gameManager.level zoomIn:NO];
    }
    else {
        [[LevelManager sharedLevelManager] renewWorldLevelsAtIndexSet:self.completedLevelIndex];
        [self.completedLevelIndex removeAllIndexes];
    }
}


@end
