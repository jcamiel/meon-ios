//
//  UIViewController+Helper.m
//  Meon
//
//  Created by Jean-Christophe Amiel on 7/11/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import "UIViewController+Helper.h"

@implementation UIViewController (Helper)

- (UIButton *)addButton:(CGPoint)origin
                 parent:(UIView*)parent
                  title:(NSString*)title
                 action:(SEL)action
       defaultImageName:(NSString*)defaultImageName
{
    return [self addButton:origin
                    parent:parent
                     title:title
                    action:action
          defaultImageName:defaultImageName
      highlightedImageName:nil
          autoresizingMask:UIViewAutoresizingNone];
}


- (UIButton*)addButton:(CGPoint)origin
                parent:(UIView*)parent
                 title:(NSString*)title
                action:(SEL)action 
      defaultImageName:(NSString*)defaultImageName
  highlightedImageName:(NSString*)highlightedImageName
      autoresizingMask:(UIViewAutoresizing)autoresizingMask
{
    UIImage *imageOff, *imageOn;
    imageOff = [UIImage imageNamed:defaultImageName];
    CGFloat width = imageOff.size.width;
    CGFloat height = imageOff.size.height;
    CGRect frame = (CGRect){{origin.x, origin.y}, {width, height}};
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.autoresizingMask = autoresizingMask;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (defaultImageName){
        [button setImage:imageOff forState:UIControlStateNormal];
    }
    
    if (highlightedImageName){
        imageOn = [UIImage imageNamed:highlightedImageName];
        [button setImage:imageOn forState:UIControlStateHighlighted];
    }
    
    [parent addSubview:button];
    
    return button;
}

- (UIButton *)addButton:(CGPoint)origin
                 parent:(UIView *)parent
                  title:(NSString *)title
                 action:(SEL)action
 backgroundOffImageName:(NSString *)backgroundOffImageName
       autoresizingMask:(UIViewAutoresizing)autoresizingMask
{
    UIImage *imageOff = [UIImage imageNamed:backgroundOffImageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = autoresizingMask;
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (backgroundOffImageName){
        [button setBackgroundImage:imageOff forState:UIControlStateNormal];
    }
    
    [parent addSubview:button];
    
    return button;
}



- (UIImageView*)addImageView:(CGPoint)origin
                parent:(UIView*)parent
      defaultImageName:(NSString*)defaultImageName
  highlightedImageName:(NSString*)highlightedImageName
      autoresizingMask:(UIViewAutoresizing)autoresizingMask
{
    UIImage *imageOff=nil, *imageOn=nil;
    imageOff = [UIImage imageNamed:defaultImageName];

    if (highlightedImageName){
        imageOn = [UIImage imageNamed:highlightedImageName];
    }
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:imageOff 
                                                highlightedImage:imageOn];
    imageView.autoresizingMask = autoresizingMask;
    CGRect frame = (CGRect){{origin.x, origin.y}, {imageView.frame.size.width, imageView.frame.size.height}};
    imageView.frame = frame;
    
    [parent addSubview:imageView];
    
    return imageView;
}




-(UITableView*)addTableView:(CGRect)frame
                     parent:(UIView*)parent
                 dataSource:(id<UITableViewDataSource>)dataSource
                   delegate:(id<UITableViewDelegate>)delegate
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame
                                                           style:UITableViewStylePlain];
    [parent addSubview:tableView];
    tableView.dataSource = dataSource;
    tableView.delegate = delegate;
    return tableView;
}


- (UILabel*)addLabel:(CGRect)frame
              parent:(UIView*)parent
                text:(NSString*)text
                font:(UIFont*)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.textAlignment = NSTextAlignmentRight;
    [parent addSubview:label];
    return label;
}

+ (CGRect)fullscreenFrame
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    CGRect frame = CGRectMake(0,0,applicationFrame.size.width, applicationFrame.size.height);
    return frame;
}

@end
