//
//  GotoCell.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GotoCellDelegate;
@class CMBitmapNumberView;

@interface GotoCell : UITableViewCell 


@property (nonatomic, strong) IBOutlet UIButton *button0;
@property (nonatomic, strong) IBOutlet UIButton *button1;
@property (nonatomic, strong) IBOutlet UIButton *button2;
@property (nonatomic, strong) IBOutlet UIButton *button3;
@property (nonatomic, weak) id<GotoCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label0;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label1;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label2;
@property (nonatomic, strong) IBOutlet CMBitmapNumberView *label3;


- (IBAction)selectCell:(id)sender;

@end



@protocol GotoCellDelegate
- (void)didSelect:(NSInteger)tag;
@end