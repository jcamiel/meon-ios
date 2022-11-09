//
//  MoreItemsTableViewCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/8/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MoreItemsTableViewCell : UITableViewCell


@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

-(void)startAnimating;
-(void)stopAnimating;

@end
