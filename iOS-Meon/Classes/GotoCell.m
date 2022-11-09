//
//  GotoCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 4/29/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "GotoCell.h"
#import "Common.h"
#import "CMBitmapNumberView.h"

@implementation GotoCell



- (IBAction)selectCell:(id)sender
{
    if ([sender respondsToSelector:@selector(tag)]){
        [self.delegate didSelect:[sender tag]];
    }
}

@end
