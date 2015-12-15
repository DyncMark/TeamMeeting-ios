//
//  RoomViewCell.m
//  Room
//
//  Created by zjq on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "RoomViewCell.h"
#import "TimeManager.h"

#define cellHeight  60

@interface RoomViewCell()

@property (nonatomic, strong) UILabel *roomNameLabel;;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *notificationImageView;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIImageView *toplineImageView;
@property (nonatomic, strong) UIImageView *lineImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation RoomViewCell

@synthesize timeLabel,roomNameLabel,numLabel,notificationImageView,settingButton,toplineImageView,lineImageView;
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
    
    self.numLabel = [UILabel new];
    self.numLabel.numberOfLines = 0;
     self.numLabel.backgroundColor = [UIColor yellowColor];
    self.numLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.numLabel.font = [UIFont systemFontOfSize:15];
    self.numLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.numLabel];
    
    
    self.notificationImageView = [UIImageView new];
    self.notificationImageView.image = [UIImage imageNamed:@"notification_not_main"];
    self.notificationImageView.backgroundColor = [UIColor blueColor];
    [self.contentView addSubview:self.notificationImageView];
    
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.numLabel.backgroundColor = [UIColor blackColor];
    [self.settingButton setImage:[UIImage imageNamed:@"setting_main_point"] forState:UIControlStateNormal];
    [self.settingButton addTarget:self action:@selector(settingButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.accessoryView = self.settingButton;
    
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
//    for (UIView *view in self.contentView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
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
    CGFloat offset = (cellHeight - 35)/2;
    
    self.toplineImageView.frame = CGRectMake(0, -.5, [UIScreen mainScreen].bounds.size.width, .5);
    self.roomNameLabel.frame = CGRectMake(15, offset, 100, 18);
    self.timeLabel.frame = CGRectMake(CGRectGetMinX(self.roomNameLabel.frame), CGRectGetMaxY(self.roomNameLabel.frame)+ 5, [UIScreen mainScreen].bounds.size.width/2, 14);
    
    self.settingButton.frame = CGRectMake(0, 0, 40, 20);
    
    self.notificationImageView.frame = CGRectMake(CGRectGetMinX(self.settingButton.frame) - 40, (cellHeight - 30)/2, 20, 30);
    
    self.numLabel.frame = CGRectMake(CGRectGetMinX(self.notificationImageView.frame)-80, (cellHeight - 30)/2, 60,30);
    
    self.lineImageView.frame = CGRectMake(0, cellHeight - .5, [UIScreen mainScreen].bounds.size.width, .5);
    
    self.activityIndicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 40, cellHeight/2);
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
        
    }else if(item.mettingState == 1){
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
       
    }else{
        [self setShow:item];
        
        self.roomNameLabel.text = item.roomName;
        self.timeLabel.text = [NSString stringWithFormat:@"创建:%@",[[TimeManager shead] friendTimeWithTimesTamp:item.jointime]];

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
