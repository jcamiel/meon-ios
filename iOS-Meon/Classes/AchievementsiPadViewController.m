//
//  AchievementsiPadViewController.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/31/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AchievementsiPadViewController.h"
#import "UIView+Helper.h"
#import "AchievementiPadCell.h"
#import "Achievement.h"


@interface AchievementsiPadViewController ()

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation AchievementsiPadViewController




- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addHeaderImageNamed:@"Common/achievements_header@2x.png"];
    
    //-- add the table view
    self.tableView = [[UITableView alloc] initWithFrame:(CGRect){{0,107},{self.view.width, self.view.height-107}}
                                              style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.view addSubview:self.tableView];
    
    //-- custom font for cell
    self.cellFont = [UIFont fontWithName:@"BradyBunchRemastered" size:25];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *plistPath = [mainBundle pathForResource:@"achievements_description" 
                                               ofType:@"plist"];
    self.achievementsDescription = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.achievements.count;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 122.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *kCellIdentifier = @"AchievementiPadCell";
    AchievementiPadCell *cell = nil;
	
    cell = (AchievementiPadCell*) [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:kCellIdentifier owner:self options:nil];
		cell = self.genericCell;
        cell.descriptionLabel.font = self.cellFont;
        self.genericCell = nil;
	}
	
    Achievement *achievement = self.achievements[indexPath.row];
	[cell setAchievement:achievement];
    NSDictionary *achievementLabel = self.achievementsDescription[achievement.identifier];
    cell.descriptionLabel.text = achievement.completed ?  
    achievementLabel[@"done"] : achievementLabel[@"todo"];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}
@end
