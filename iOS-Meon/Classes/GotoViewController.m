//
//  GotoViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/10.
//  Copyright 2010 Manbolo. All rights reserved.
//
#import "GotoViewController.h"

#import "CMBitmapNumberView.h"
#import "GotoCell.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"


@interface GotoViewController ()
@property (nonatomic, strong) NSMutableArray *digitNames;
@end


@implementation GotoViewController

- (void)dealloc {
    [self.gameManager removeObserver:self forKeyPath:@"levelMaximum"];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)loadView {
    [super loadView];

    [self addHeaderImageNamed:@"Common/goto_header.png"];

    self.backButtonType = ModalViewControllerButtonCancel;

    int height = self.view.height - 62;
    self.tableView = [self addTableView:(CGRect){{0, 62}, {320, height}}
                                 parent:self.view
                             dataSource:self
                               delegate:self];
    self.tableView.backgroundColor = [UIColor colorWithRed:40.0 / 255 green:39.0 / 255 blue:48.0 / 255 alpha:1.0];
    self.tableView.opaque = YES;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;


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


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.currentLevel / 4) inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:NO];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.tableView = nil;
    self.genericCell = nil;
}


#pragma mark - UITableView Delegate/Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79.0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#if defined(LITE)
    return (31 / 4) + 1;
#else
    return (120 / 4) + 1;
#endif
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"GotoCell";
    // generic cell
    GotoCell *cell = (GotoCell *) [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"GotoCell" owner:self options:nil];
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

    NSString *imageNamed = nil;

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
        imageNamed = @"cadena.png";
    }
    else if ((4 * indexPath.row + 0) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld.png", (long)(4 * indexPath.row)];
    }
    else {
        imageNamed = @"Miniatures/mini.png";
    }


    [cell.button0 setImage:[UIImage imageNamed:imageNamed]
                  forState:UIControlStateNormal];

    if ((4 * indexPath.row + 1) > self.maxLevel) {
        imageNamed = @"cadena.png";
    }
    else if ((4 * indexPath.row + 1) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld.png", (long)(4 * indexPath.row + 1)];
    }
    else {
        imageNamed = @"Miniatures/mini.png";
    }

    [cell.button1 setImage:[UIImage imageNamed:imageNamed]
                  forState:UIControlStateNormal];

    if ((4 * indexPath.row + 2) > self.maxLevel) {
        imageNamed = @"cadena.png";
    }
    else if ((4 * indexPath.row + 2) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld.png", (long)(4 * indexPath.row + 2)];
    }
    else {
        imageNamed = @"Miniatures/mini.png";
    }


    [cell.button2 setImage:[UIImage imageNamed:imageNamed]
                  forState:UIControlStateNormal];

    if ((4 * indexPath.row + 3) > self.maxLevel) {
        imageNamed = @"cadena.png";
    }
    else if ((4 * indexPath.row + 3) < self.maxLevel) {
        imageNamed = [NSString stringWithFormat:@"Miniatures/mini_%03ld.png", (long)(4 * indexPath.row + 3)];
    }
    else {
        imageNamed = @"Miniatures/mini.png";
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


- (IBAction)cancel:(id)sender {
    [self.delegate didCancel:self];
}


#pragma mark - Cell delegate

- (void)didSelect:(NSInteger)tag {
    [self.delegate didSelectLevel:tag controller:self];
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
