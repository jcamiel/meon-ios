//
//  SimpleGotoCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 10/30/11.
//  Copyright (c) 2011 Manbolo. All rights reserved.
//

#import "SimpleGotoCell.h"

@implementation SimpleGotoCell

- (IBAction)selectCell:(id)sender {
    if ([sender respondsToSelector:@selector(tag)]) {
        [self.delegate didSelect:[sender tag]];
    }
}


@end
