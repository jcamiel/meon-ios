//
//  CMButton.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 04/01/15.
//  Copyright (c) 2015 Manbolo. All rights reserved.
//

#import "CMButton.h"
#import "THLabel.h"
#import "UIView+Helper.h"
#import "UIFont+Helper.h"

@interface CMButton ()

@property (nonatomic, strong, readwrite) THLabel *extendedLabel;
@property (nonatomic, copy) NSString *extendedLabelTitle;
@property (nonatomic, copy) NSArray *horizontalConstraints;
@property (nonatomic, copy) NSArray *verticalConstraints;

@end


@implementation CMButton

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    return self;
}

- (void)configure {
    self.backgroundColor = [UIColor clearColor];
    _extendedLabel = [[THLabel alloc] init];
    _extendedLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _extendedLabel.backgroundColor = [UIColor clearColor];
    _extendedLabel.textColor = [UIColor whiteColor];
    _extendedLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_extendedLabel];
    [self addHorizontalConstraints];
    [self addVerticalConstraints];
    
}


- (void)removeAllConstraints {
    if (self.horizontalConstraints) {
        [self removeConstraints:self.horizontalConstraints];
        self.horizontalConstraints = nil;
    }
    if (self.verticalConstraints) {
        [self removeConstraints:self.verticalConstraints];
        self.verticalConstraints = nil;
    }
}


- (void)addHorizontalConstraints {
    if (self.horizontalConstraints) {
        [self removeConstraints:self.horizontalConstraints];
        self.horizontalConstraints = nil;
    }

    self.horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_extendedLabel]-right-|"
                                                                         options:0
                                                                         metrics:@{@"left":@(self.titleEdgeInsets.left), @"right":@(self.titleEdgeInsets.right)}
                                                                           views:NSDictionaryOfVariableBindings(_extendedLabel)];
    [self addConstraints:self.horizontalConstraints];
}


- (void)addVerticalConstraints {
    if (self.verticalConstraints) {
        [self removeConstraints:self.verticalConstraints];
        self.verticalConstraints = nil;
    }

    self.verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[_extendedLabel]-bottom-|"
                                                                       options:0
                                                                       metrics:@{@"top":@(self.titleEdgeInsets.top), @"bottom":@(self.titleEdgeInsets.bottom)}
                                                                         views:NSDictionaryOfVariableBindings(_extendedLabel)];
    [self addConstraints:self.verticalConstraints];
}


- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    [super setTitleEdgeInsets:titleEdgeInsets];
    [self removeAllConstraints];
    [self addHorizontalConstraints];
    [self addVerticalConstraints];
    [self invalidateIntrinsicContentSize];
}


- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    self.extendedLabel.text = title;
    [self setNeedsDisplay];
    [self invalidateIntrinsicContentSize];
}


- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    self.extendedLabel.textColor = color;
    [self setNeedsDisplay];
}


- (NSString *)titleForState:(UIControlState)state {
    return self.extendedLabel.text;
}


- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.extendedLabel.alpha = 0.5;
    }
    else {
        self.extendedLabel.alpha = 1.0;
    }
    [super setHighlighted:highlighted];
}


- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.extendedLabel.alpha = 0.5;
    }
    else {
        self.extendedLabel.alpha = 1.0;
    }
    [super setSelected:selected];
}

- (CGSize)intrinsicContentSize {
    
    UIFont *font = self.extendedLabel.font;
    NSString *text = self.extendedLabel.text;
    CGSize textSize = [font sizeForText:text];
    
    CGFloat marginTop = 15;
    CGFloat marginBottom = 15;
    CGFloat marginLeft = 24;
    CGFloat marginRight = 24;
    
    CGSize size = CGSizeMake(textSize.width + marginLeft + marginRight,
                             textSize.height + marginTop + marginBottom);
    return size;
}

@end
