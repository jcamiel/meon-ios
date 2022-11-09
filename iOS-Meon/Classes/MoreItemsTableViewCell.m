//
//  MoreItemsTableViewCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/8/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "MoreItemsTableViewCell.h"
#import "Common.h"

@implementation MoreItemsTableViewCell


-(void)startAnimating
{
    if (!self.loadingIndicator){
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingIndicator = activity;
        [activity startAnimating];
        self.accessoryView = activity;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.textColor = [UIColor grayColor];
        self.textLabel.highlightedTextColor = [UIColor grayColor];
    }
    
}
-(void)stopAnimating
{
    [self.loadingIndicator stopAnimating];
    self.loadingIndicator = nil;
    self.accessoryView = nil;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.highlightedTextColor = [UIColor whiteColor];
    
}



@end
