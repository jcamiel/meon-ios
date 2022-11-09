//
//  AchievementsViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 12/9/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "AchievementsViewController.h"
#import "GameCenterManager.h"
#import "GameManager.h"
#import "Achievement.h"
#import <QuartzCore/QuartzCore.h>
#import "AchievementCell.h"
#import "UIView+Helper.h"
#import "UIViewController+Helper.h"

@implementation AchievementsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addHeaderImageNamed:@"Common/achievements_header.png"];
    
    int height = self.view.height - 64;
    CGRect frame = {{0,64},{320,height}};
        
    UIView *containerView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:containerView];
    containerView.backgroundColor = [UIColor clearColor];
    [self addMaskOnView:containerView];

    
    self.tableView = [self addTableView:(CGRect){{0,0}, {320,height}}
                                      parent:containerView
                                  dataSource:self
                                    delegate:self];
    _tableView .backgroundColor = [UIColor clearColor];
    _tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    
    // -- load achievements and populate the list
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(updateAchievements:) 
												 name:GameManagerUpdateAchievements
											   object:nil];
	
	self.achievements = [_gameManager.gameCenterManager.achievements.allValues
						 sortedArrayUsingSelector:@selector(compare:)];
	
	_tableView.separatorStyle =  UITableViewCellSeparatorStyleNone;
	_tableView.sectionHeaderHeight = 8.0;
    self.cellFont = [UIFont fontWithName:@"BradyBunchRemastered" size:14];

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *plistPath = [mainBundle pathForResource:@"achievements_description" 
                                                        ofType:@"plist"];
    self.achievementsDescription = [NSDictionary dictionaryWithContentsOfFile:plistPath];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)addMaskOnView:(UIView*)view
{
    CAGradientLayer *mask = [CAGradientLayer layer];
    mask.locations = @[@0.0f,@0.05f,@1.0f];
    
    mask.colors = @[(id)[UIColor clearColor].CGColor,
    (id)[UIColor whiteColor].CGColor,
    (id)[UIColor whiteColor].CGColor];
    
    mask.frame = view.bounds ;
    mask.startPoint = CGPointMake(0, 0);
    mask.endPoint = CGPointMake(0, 1);
    view.layer.mask = mask;
}


- (void)dealloc
{
	DebugLog(@"dealloc");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

- (IBAction)back:(id)sender
{
	[_delegate achievementsDidSelectBack:self];
}

#pragma mark -
#pragma mark TableView Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	CGRect frame = CGRectMake(0, 0, 320, 8);
	UIView *header = [[UIView alloc] initWithFrame:frame];
	header.opaque = NO;
	header.backgroundColor = [UIColor clearColor];
	return header;
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return @"test";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _achievements.count;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 68.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *kCellIdentifier = @"AchievementCell";
    AchievementCell *cell = nil;
	
    // generic case
    cell = (AchievementCell*) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"AchievementCell" 
											 owner:self 
										   options:nil];
		cell = self.genericCell;
        cell.descriptionLabel.font = _cellFont;
		self.genericCell = nil;
	}
	
	Achievement *achievement = _achievements[indexPath.row];
	cell.achievement = achievement;
    NSDictionary *achievementLabel = _achievementsDescription[achievement.identifier];
    cell.descriptionLabel.text = achievement.completed ?  
        achievementLabel[@"done"] : achievementLabel[@"todo"];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

#pragma mark -
#pragma mark Notification
- (void)updateAchievements:(NSNotification*)theNotification
{
	[_tableView	reloadData];
}


@end
