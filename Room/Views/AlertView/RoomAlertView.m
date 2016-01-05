//
//  RoomAlertView.m
//  Room
//
//  Created by zjq on 15/12/8.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "RoomAlertView.h"

#define IsiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) // 判断设备是不是iPad

@interface RoomAlertView()
{
    UIActivityIndicatorView *activityIndicatorView;
}
@property (nonatomic, strong) UIView *alertView;
@end

@implementation RoomAlertView

- (id)initType:(AlertViewType)type
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.4];
        if (type == AlertViewNotNetType) {
            if (IsiPad) {
                self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
            }else{
                  self.alertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 80, CGRectGetHeight([UIScreen mainScreen].bounds)/2)];
            }
          
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 65, 65)];
            iconImageView.center = CGPointMake(self.alertView.center.x, CGRectGetHeight(iconImageView.frame));
            iconImageView.image = [UIImage imageNamed:@"no_net_alert"];
            [self.alertView addSubview:iconImageView];
            
            UILabel *orderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.alertView.frame), 20)];
            orderLabel.textAlignment = NSTextAlignmentCenter;
            orderLabel.font = [UIFont boldSystemFontOfSize:20];
            orderLabel.text = @"网络连接出错";
            NSLog(@"%f %f",(self.alertView.center.y -30),CGRectGetMaxY(iconImageView.frame) );
            if (self.alertView.center.y - 30 < CGRectGetMaxY(iconImageView.frame)) {
                 orderLabel.center = CGPointMake(self.alertView.center.x, CGRectGetMaxY(iconImageView.frame)+20);
                
            }else{
                orderLabel.center = CGPointMake(self.alertView.center.x, self.alertView.center.y-20);
            }
            [self.alertView addSubview:orderLabel];
            
            
            UILabel *nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(orderLabel.frame), CGRectGetWidth(self.alertView.frame) - 80, 80)];
            
            nextLabel.textAlignment = NSTextAlignmentCenter;
            nextLabel.numberOfLines = 0;
            nextLabel.font = [UIFont systemFontOfSize:16];
            nextLabel.text = @"世界上最遥远得距离就是没网。请检查设置";
            [self.alertView addSubview:nextLabel];
            
            
            UIButton *tryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            tryButton.frame = CGRectMake(0, CGRectGetHeight(self.alertView.frame)- CGRectGetHeight(self.alertView.frame)/6 ,CGRectGetWidth(self.alertView.frame), CGRectGetHeight(self.alertView.frame)/6);
            [tryButton setTitle:@"试一下" forState:UIControlStateNormal];
            [tryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [tryButton setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
            tryButton.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:139.0/255.0 blue:75.0/255.0 alpha:1.0];
            [tryButton addTarget:self action:@selector(tryButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
            [self.alertView addSubview:tryButton];
    
            
            activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicatorView.center = CGPointMake(tryButton.center.x + tryButton.center.x/2, tryButton.center.y);
            [self.alertView addSubview:activityIndicatorView];
            
        }else{
            
        }
        
        self.alertView.backgroundColor = [UIColor colorWithRed:171.0/255.0 green:174.0/255.0 blue:175.0/255.0 alpha:1.0];
        
        self.alertView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [self addSubview:self.alertView];
        
        self.alpha = 0.0;
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self];
        
    }
    return self;
}
- (void)tryButtonEvent:(UIButton*)tryButton
{
    if (activityIndicatorView) {
        [activityIndicatorView startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [activityIndicatorView stopAnimating];
        });
    }
}

- (void)show
{
    self.alertView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
        self.alertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.alertView.transform = CGAffineTransformMakeScale(0.95, 0.95);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.alertView.transform = CGAffineTransformMakeScale(1, 1);
            }];
        }];
    }];

}

- (void)dismiss
{
    [UIView animateWithDuration:0.15 animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.alertView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.alertView removeFromSuperview];
            [self removeFromSuperview];
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
