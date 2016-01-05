//
//  RoomViewCell.m
//  Room
//
//  Created by zjq on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "RoomViewCell.h"
#import "TimeManager.h"
#import "MemberView.h"

#define cellHeight  60

@interface RoomViewCell()

@property (nonatomic, strong) UILabel *roomNameLabel;;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) MemberView *memberView;
@property (nonatomic, strong) UIImageView *notificationImageView;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIImageView *toplineImageView;
@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation RoomViewCell

@synthesize timeLabel,roomNameLabel,memberView,notificationImageView,settingButton,toplineImageView,lineImageView;
@synthesize delegate;
@synthesize parIndexPath;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSubviews];
        [self setLayout];
        
    }
    return self;
}

- (void)initSubviews
{
    self.roomNameLabel = [UILabel new];
    self.roomNameLabel.backgroundColor = [UIColor clearColor];
    self.roomNameLabel.numberOfLines = 0;
    self.roomNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.roomNameLabel.font = [UIFont boldSystemFontOfSize:17];
    self.roomNameLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.roomNameLabel];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.timeLabel.font = [UIFont systemFontOfSize:14];
    self.timeLabel.textColor = [UIColor colorWithRed:186.0/255.0 green:180.0/255.0 blue:189.0/255.0 alpha:1.0];
    [self.contentView addSubview:self.timeLabel];
    
    self.memberView = [MemberView new];
    [self.contentView addSubview:self.memberView];
    
    self.notificationImageView = [UIImageView new];
    self.notificationImageView.image = [UIImage imageNamed:@"notification_not_main"];
    self.notificationImageView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.notificationImageView];
    
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingButton setImage:[UIImage imageNamed:@"setting_main_point"] forState:UIControlStateNormal];
    [self.settingButton addTarget:self action:@selector(settingButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.settingButton.backgroundColor = [UIColor clearColor];
//    self.accessoryView = self.settingButton;
    [self.contentView addSubview:self.settingButton];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.contentView addSubview:self.activityIndicatorView];
    
    self.toplineImageView = [UIImageView new];
    self.toplineImageView.image = [UIImage imageNamed:@""];
    self.toplineImageView.backgroundColor = [UIColor colorWithRed:133.0/255.0 green:138.0/255.0 blue:141.0/255.0 alpha:1];
    [self.contentView addSubview:self.toplineImageView];
    
    self.lineImageView = [UIImageView new];
    self.lineImageView.image = [UIImage imageNamed:@""];
    self.lineImageView.backgroundColor = [UIColor colorWithRed:133.0/255.0 green:138.0/255.0 blue:141.0/255.0 alpha:1];
    [self.contentView addSubview:self.lineImageView];
}

- (void)setLayout
{
    for (UIView *view in self.contentView.subviews)
    {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    self.settingButton.translatesAutoresizingMaskIntoConstraints = NO;
//    NSDictionary *views = NSDictionaryOfVariableBindings(roomNameLabel, timeLabel, numLabel, notificationImageView,settingButton,lineImageView);
//    
//    // 时间和名字label距离左边10像素
//     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[roomNameLabel]-5-[timeLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
//    
//     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15.0-[roomNameLabel]" options:NSLayoutFormatAlignAllLeft metrics:nil views:views]];
//    
//    
//    
//     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[settingButton]-15-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];
//    
//     [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[settingButton]-15.0-|" options:NSLayoutFormatAlignAllRight metrics:nil views:views]];
//
//    
//    // 设置下划线左右对齐，并靠下
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[lineImageView]-0-|" options:NSLayoutFormatAlignAllBottom metrics:nil views:views]];
    
//    self.settingButton.frame = CGRectMake(0, 0, 40, 20);
    
    self.toplineImageView.frame = CGRectMake(0, -.5, [UIScreen mainScreen].bounds.size.width, .5);
    self.lineImageView.frame = CGRectMake(0, cellHeight - .5, [UIScreen mainScreen].bounds.size.width, .5);
    
    CGFloat offset = (cellHeight - 35)/2;
    // 设置按钮坐标
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.settingButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-15.0f];
    
    NSLayoutConstraint * constraint1 = [NSLayoutConstraint constraintWithItem:self.settingButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
    
     NSLayoutConstraint * constraint2 = [NSLayoutConstraint constraintWithItem:self.settingButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:20.0f];
    
    NSLayoutConstraint * constraint3 = [NSLayoutConstraint constraintWithItem:self.settingButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.f];

    
    // 房间名字坐标
    NSLayoutConstraint * constraint4 = [NSLayoutConstraint constraintWithItem:self.roomNameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:offset];
    
    NSLayoutConstraint * constraint5 = [NSLayoutConstraint constraintWithItem:self.roomNameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:15.0f];
    
    NSLayoutConstraint * constraint6 = [NSLayoutConstraint constraintWithItem:self.roomNameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.0f];
    
    NSLayoutConstraint * constraint7 = [NSLayoutConstraint constraintWithItem:self.roomNameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.3f constant:0.f];
    
    // 时间坐标
    NSLayoutConstraint * constraint8 = [NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.roomNameLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:offset/3];
    
    NSLayoutConstraint * constraint9 = [NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:15.0f];
    
    NSLayoutConstraint * constraint10 = [NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:0.5f constant:0.0f];
    
    NSLayoutConstraint * constraint11 = [NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeHeight multiplier:0.25f constant:0.f];
    
    // 旋转坐标
    NSLayoutConstraint * constraint12 = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-20.0f];
    
    NSLayoutConstraint * constraint13 = [NSLayoutConstraint constraintWithItem:self.activityIndicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.f];
    
    
    // 通知坐标
    NSLayoutConstraint * constraint14 = [NSLayoutConstraint constraintWithItem:self.notificationImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    
    NSLayoutConstraint * constraint15 = [NSLayoutConstraint constraintWithItem:self.notificationImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    
    NSLayoutConstraint * constraint16 = [NSLayoutConstraint constraintWithItem:self.notificationImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.0f];
    
    NSLayoutConstraint * constraint17 = [NSLayoutConstraint constraintWithItem:self.notificationImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.settingButton attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-30.f];
    
   // 人数
    NSLayoutConstraint * constraint18 = [NSLayoutConstraint constraintWithItem:self.memberView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:60.0f];
    
    NSLayoutConstraint * constraint19 = [NSLayoutConstraint constraintWithItem:self.memberView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:25.0f];
    
    NSLayoutConstraint * constraint20 = [NSLayoutConstraint constraintWithItem:self.memberView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.0f];
    
    NSLayoutConstraint * constraint21 = [NSLayoutConstraint constraintWithItem:self.memberView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.settingButton attribute:NSLayoutAttributeLeft multiplier:1.0f constant:-30.f];
    
    [self.contentView addConstraint:constraint];
    [self.contentView addConstraint:constraint1];
    [self.contentView addConstraint:constraint2];
    [self.contentView addConstraint:constraint3];
    [self.contentView addConstraint:constraint4];
    [self.contentView addConstraint:constraint5];
    [self.contentView addConstraint:constraint6];
    [self.contentView addConstraint:constraint7];
    [self.contentView addConstraint:constraint8];
    [self.contentView addConstraint:constraint9];
    [self.contentView addConstraint:constraint10];
    [self.contentView addConstraint:constraint11];
    [self.contentView addConstraint:constraint12];
    [self.contentView addConstraint:constraint13];
    [self.contentView addConstraint:constraint14];
    [self.contentView addConstraint:constraint15];
    [self.contentView addConstraint:constraint16];
    [self.contentView addConstraint:constraint17];
    
    [self.contentView addConstraint:constraint18];
    [self.contentView addConstraint:constraint19];
    [self.contentView addConstraint:constraint20];
    [self.contentView addConstraint:constraint21];
    
//    self.roomNameLabel.frame = CGRectMake(15, offset, 100, 18);
//    self.timeLabel.frame = CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame)+ 5, [UIScreen mainScreen].bounds.size.width/2, 14);
//    
//    self.settingButton.frame = CGRectMake(0, 0, 40, 20);
//    
//    self.notificationImageView.frame = CGRectMake(CGRectGetMinX(self.settingButton.frame) - 40, (cellHeight - 30)/2, 20, 30);
//    
//    self.numLabel.frame = CGRectMake(CGRectGetMinX(self.notificationImageView.frame)-80, (cellHeight - 30)/2, 60,30);
//    
  
//    
//    self.activityIndicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 40, cellHeight/2);
}

// 事件处理
- (void)settingButtonEvent:(UIButton*)button
{
    if (delegate && [delegate respondsToSelector:@selector(roomViewCellDlegateSettingEvent:)]) {
        [delegate roomViewCellDlegateSettingEvent:parIndexPath.row];
    }
}

- (void)setShow:(RoomItem*)item
{
    if (item.mettingState == 0) {
        self.settingButton.hidden = YES;
        [self.activityIndicatorView startAnimating];
        
    }else{
        [self.activityIndicatorView stopAnimating];
        self.settingButton.hidden = NO;
    }
}

- (void)setItem:(RoomItem*)item
{
    if ([item.roomName isEqualToString:@""]) {
        
        self.roomNameLabel.text = @"";
        self.timeLabel.text = @"";

        [self setShow:item];
        
        self.memberView.hidden = YES;
        self.notificationImageView.hidden = YES;
       
    }else{
        [self setShow:item];
        
        self.roomNameLabel.text = item.roomName;
        self.timeLabel.text = [NSString stringWithFormat:@"创建:%@",[[TimeManager shead] friendTimeWithTimesTamp:item.jointime]];
        if ([item.mettingNum isEqualToString:@"0"]) {
            self.memberView.hidden = YES;
            if ([item.canNotification isEqualToString:@"1"]) {
                self.notificationImageView.hidden = YES;
            }else{
                self.notificationImageView.hidden = NO;
            }
        }else{
            self.memberView.hidden = NO;
            if ([item.canNotification isEqualToString:@"1"]) {
                self.notificationImageView.hidden = YES;
            }else{
                self.notificationImageView.hidden = NO;
            }
        }
       

    }
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
