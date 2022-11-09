//
//  ScoresCell.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 8/20/10.
//  Copyright 2010 Manbolo. All rights reserved.
//

#import "ScoresCell.h"


@implementation ScoresCell


- (void)setIndex:(NSInteger)newIndex {
    _index = newIndex;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld.", (long)_index];
}


@end
