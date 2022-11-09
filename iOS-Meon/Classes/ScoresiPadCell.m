//
//  ScoresiPadCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 5/29/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "ScoresiPadCell.h"

@implementation ScoresiPadCell


- (void)setIndex:(NSInteger)newIndex {
    _index = newIndex;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld.", _index];
}


@end
