//
//  SimpleGotoCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/30/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimpleGotoCellDelegate;
@class CMBitmapNumberView;


@interface SimpleGotoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *button0;
@property (nonatomic, strong) IBOutlet UIButton *button1;
@property (nonatomic, strong) IBOutlet UIButton *button2;
@property (nonatomic, strong) IBOutlet UIButton *button3;
@property (nonatomic, weak) id<SimpleGotoCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label0;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label1;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label2;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label3;

- (IBAction)selectCell:(id)sender;

@end



@protocol SimpleGotoCellDelegate
@optional
- (void)didSelect:(NSInteger)tag;
@end