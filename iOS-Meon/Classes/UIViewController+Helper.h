//
//  UIViewController+Helper.h
//  Meon
//
//  Created by Jean-Christophe Amiel on 7/11/12.
//  Copyright (c) 2012 Manbolo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Helper)

- (UIButton *)addButton:(CGPoint)origin
                 parent:(UIView *)parent
                  title:(NSString *)title
                 action:(SEL)action
       defaultImageName:(NSString *)defaultImageName;


- (UIButton *)addButton:(CGPoint)origin
                parent:(UIView *)parent
                 title:(NSString *)title
                action:(SEL)action 
      defaultImageName:(NSString *)defaultImageName
  highlightedImageName:(NSString *)highlightedImageName
      autoresizingMask:(UIViewAutoresizing)autoresizingMask;

- (UIButton *)addButton:(CGPoint)origin
                 parent:(UIView *)parent
                  title:(NSString *)title
                 action:(SEL)action
 backgroundOffImageName:(NSString *)backgroundOffImageName
       autoresizingMask:(UIViewAutoresizing)autoresizingMask;

- (UIImageView *)addImageView:(CGPoint)origin
                      parent:(UIView *)parent
            defaultImageName:(NSString *)defaultImageName
        highlightedImageName:(NSString *)highlightedImageName
            autoresizingMask:(UIViewAutoresizing)autoresizingMask;

-(UITableView *)addTableView:(CGRect)frame
                     parent:(UIView *)parent
                 dataSource:(id<UITableViewDataSource>)dataSource
                   delegate:(id<UITableViewDelegate>)delegate;

- (UILabel *)addLabel:(CGRect)frame
              parent:(UIView *)parent
                text:(NSString *)text
                font:(UIFont *)font;

+ (CGRect)fullscreenFrame;

@end
