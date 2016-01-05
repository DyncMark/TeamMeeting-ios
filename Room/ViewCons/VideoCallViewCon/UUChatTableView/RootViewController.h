//
//  RootViewController.h
//  UUChatTableView
//
//  Created by shake on 15/1/4.
//  Copyright (c) 2015年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController


@property(nonatomic,assign)id parentViewCon;
- (void)resetInputFrame:(CGRect)rect;
- (void)hidenInput;
- (void)resginKeyBord;
@end
