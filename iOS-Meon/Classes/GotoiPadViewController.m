//
//  GotoiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 9/17/11.
//  Copyright 2011 Manbolo. All rights reserved.
//
#import "GotoiPadViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CMBitmapNumberView.h"
#import "UIView+Helper.h"


@interface GotoiPadViewController ()

@property (nonatomic, strong) NSMutableArray *digitNames;

@end

@implementation GotoiPadViewController

@dynamic delegate;

- (void)dealloc {
    [self.gameManager removeObserver:self forKeyPath:@"levelMaximum"];
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addHeaderImageNamed:@"Common/goto_header@2x.png"];


    //-- add the table view
    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){{0, 103}, {self.view.width, self.view.height - 103}}
                                                  style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.tableView.allowsSelection = NO;
    [self.view addSubview:self.tableView];

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.currentLevel / 4) inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:NO];

    //--
    self.digitNames = [[NSMutableArray alloc] initWithObjects:@"Digit/digit-level0-small.png",
                       @"Digit/digit-level1-small.png",
                       @"Digit/digit-level2-small.png",
                       @"Digit/digit-level3-small.png",
                       @"Digit/digit-level4-small.png",
                       nil];

    //-- observe change in level

    [self.gameManager addObserver:self
                       forKeyPath:@"levelMaximum"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}


#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#if defined(LITE)
    return (31 / 4) + 1;
#else
    return (120 / 4) + 1;
#endif
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 135.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"SimpleGotoCell";
    SimpleGotoCell *cell = nil;

    cell = (SimpleGotoCell *) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"SimpleGotoCell" owner:self options:nil];
        cell = self.genericCell;
        self.genericCell = nil;
        cell.delegate = self;

        cell.label0.letterSpacing = -0.2;
        cell.label0.alignment = NSTextAlignmentRight;
        cell.label1.letterSpacing = -0.2;
        cell.label1.alignment = NSTextAlignmentRight;
        cell.label2.letterSpacing = -0.2;
        cell.label2.alignment = NSTextAlignmentRight;
        cell.label3.letterSpacing = -0.2;
        cell.label3.alignment = NSTextAlignmentRight;
    }

    NSString *imageNamed;

    imageNamed = self.digitNames[((4 * indexPath.row + 0) / 10) % 5];
    cell.label0.digitsImage = [UIImage imageNamed:imageNamed];
    cell.label0.value = 4 * indexPath.row;

    imageNamed = self.digitNames[((4 * indexPath.row + 1) / 10) % 5];
    cell.label1.digitsImage = [UIImage imageNamed:imageNamed];
    cell.label1.value = 4 * indexPath.row + 1;

    imageNamed = self.digitNames[((4 * indexPath.row + 2) / 10) % 5];
    cell.label2.digitsImage = [UIImage imageNamed:imageNamed];
    cell.label2.value = 4 * indexPath.row + 2;

    imageNamed = self.digitNames[((4 * indexPath.row + 3) / 10) % 5];
    cell.label3.digitsImage = [UIImage imageNamed:imageNamed];
    cell.label3.value = 4 * indexPath.row + 3;

    if ((4 * indexPath.row + 0) > self.maxLevel) {
        imageNamed = @"cadena@2x.png";
    }
    else if ((4 * indexPath.row + 0) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld@2x.png", 4 * indexPath.row];
    }
    else {
        imageNamed = @"Miniatures/mini@2x.png";
    }


    [cell.button0 setImage:[UIImage imageNamed:imageNamed]
                  forState:UIControlStateNormal];

    if ((4 * indexPath.row + 1) > self.maxLevel) {
        imageNamed = @"cadena@2x.png";
    }
    else if ((4 * indexPath.row + 1) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld@2x.png", 4 * indexPath.row + 1];
    }
    else {
        imageNamed = @"Miniatures/mini@2x.png";
    }

    [cell.button1 setImage:[UIImage imageNamed:imageNamed]
                  forState:UIControlStateNormal];

    if ((4 * indexPath.row + 2) > self.maxLevel) {
        imageNamed = @"cadena@2x.png";
    }
    else if ((4 * indexPath.row + 2) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld@2x.png", 4 * indexPath.row + 2];
    }
    else {
        imageNamed = @"Miniatures/mini@2x.png";
    }


    [cell.button2 setImage:[UIImage imageNamed:imageNamed]
                  forState:UIControlStateNormal];

    if ((4 * indexPath.row + 3) > self.maxLevel) {
        imageNamed = @"cadena@2x.png";
    }
    else if ((4 * indexPath.row + 3) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld@2x.png", 4 * indexPath.row + 3];
    }
    else {
        imageNamed = @"Miniatures/mini@2x.png";
    }

    [cell.button3 setImage:[UIImage imageNamed:imageNamed]
                  forState:UIControlStateNormal];

    cell.button0.tag = 4 * indexPath.row;
    cell.button1.tag = 4 * indexPath.row + 1;
    cell.button2.tag = 4 * indexPath.row + 2;
    cell.button3.tag = 4 * indexPath.row + 3;


    cell.button1.hidden = (indexPath.row == 30);
    cell.button2.hidden = (indexPath.row == 30);
    cell.button3.hidden = (indexPath.row == 30);

    cell.label1.hidden = (indexPath.row == 30);
    cell.label2.hidden = (indexPath.row == 30);
    cell.label3.hidden = (indexPath.row == 30);

    cell.button0.enabled = ((4 * indexPath.row + 0) <= self.maxLevel);
    cell.button1.enabled = ((4 * indexPath.row + 1) <= self.maxLevel);
    cell.button2.enabled = ((4 * indexPath.row + 2) <= self.maxLevel);
    cell.button3.enabled = ((4 * indexPath.row + 3) <= self.maxLevel);

    return cell;
}



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:@"levelMaximum"]) {
        DebugLog(@"levelMaximum changed !");
        self.maxLevel = self.gameManager.levelMaximum;
        [self.tableView reloadData];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
