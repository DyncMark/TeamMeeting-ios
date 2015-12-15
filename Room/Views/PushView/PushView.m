//
//  PushView.m
//  DemoAnnitation
//
//  Created by yangyang on 15/11/3.
//  Copyright © 2015年 yangyang. All rights reserved.
//

#import "PushView.h"
#import "ToolUtils.h"
#define CellHeight 60
@protocol SelectedItemCellDelegate <NSObject>

- (void)selectedItemCell:(NSInteger)index;

- (void)openOrCloseNotification:(BOOL)isOpen;

@end

@interface SelectedItemCell : UIView<UIAlertViewDelegate>
{
    UIImageView  *iconImageView;
    UILabel      *titleLabel;
    UISwitch     *switchView;
    NSInteger    indexPath;
    PushViewType viewType;
    
    BOOL tryOpen;
}

@property (nonatomic, weak)id<SelectedItemCellDelegate>delegate;

- (id)initWithFrame:(CGRect)frame
          withTitle:(NSString*)title
      withImageName:(NSString*)imageName
           withType:(PushViewType)type
          withIndex:(NSInteger)index
           withItem:(RoomItem*)item;

@end

@implementation SelectedItemCell
@synthesize delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
          withTitle:(NSString*)title
      withImageName:(NSString*)imageName
           withType:(PushViewType)type
          withIndex:(NSInteger)index
           withItem:(RoomItem *)item {
    
    self = [super initWithFrame:frame];
    
    if (self) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        indexPath = index;
        viewType = type;
        
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (frame.size.height - 35)/2, 35, 35)];
        iconImageView.image = [UIImage imageNamed:imageName];
        [self addSubview:iconImageView];
        
       
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame)+ 15, (frame.size.height-25)/2, 150, 25)];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        titleLabel.text = title;
        [self addSubview:titleLabel];
        
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, frame.size.height-1, frame.size.width -30, 1)];
        lineImageView.backgroundColor = [UIColor grayColor];
        [self addSubview:lineImageView];
        
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickSelectedItemCell:)]];
        
        if (type == PushViewTypeSetting && index == 4) {
            tryOpen = NO;
            switchView = [[UISwitch alloc] initWithFrame:CGRectMake(self.frame.size.width - 65, (frame.size.height -28)/2, 60.0f, 28.0f)];
            switchView.onTintColor = [UIColor colorWithRed:235.0/255.0 green:139.0/255.0 blue:75.0/255.0 alpha:1.0];
            
            [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [self addSubview:switchView];
            
            if ([item.canNotification isEqualToString:@"1"]) {
                UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:iconImageView.frame];
                lineImageView.transform = CGAffineTransformMakeScale(.0, .0);
                lineImageView.tag = 300;
                lineImageView.center = iconImageView.center;
                lineImageView.image = [UIImage imageNamed:@"notification_line_main"];
                [self addSubview:lineImageView];
                switchView.on = YES;
            }else{
                UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:iconImageView.frame];
                lineImageView.tag = 300;
                lineImageView.center = iconImageView.center;
                lineImageView.image = [UIImage imageNamed:@"notification_line_main"];
                [self addSubview:lineImageView];
                switchView.on = NO;
            }
          
        }
        
    }
    return self;
}
- (void)notificationShow:(BOOL)isShow
{
    UIImageView *lineImageView = (UIImageView*)[self viewWithTag:300];
    if (!isShow) {
        [UIView animateWithDuration:.3
                         animations:^{
                             lineImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }];
        
       
    }else{
        [UIView animateWithDuration:.3
                         animations:^{
                             lineImageView.transform = CGAffineTransformMakeScale(0, 0);
                         }];
    }
}
// 点击cell
- (void)onClickSelectedItemCell:(UITapGestureRecognizer*)tapGestureRecognizer
{
    if (viewType == PushViewTypeSetting && indexPath == 4) {
        if (switchView) {
            if (switchView.isOn) {
                [switchView setOn:NO animated:YES];
                [self notificationShow:NO];
            }else{
                // 先判断能否打开在打开否则回去
                [self getNOtificationAuthority];
            }
        }
    }else{
        if (delegate && [delegate respondsToSelector:@selector(selectedItemCell:)]) {
            [delegate selectedItemCell:indexPath];
        }
    }
}
//
- (void)switchAction:(UISwitch*)view
{
    // 打开
    if (view.isOn) {
        // 先判断能否打开在打开否则回去
        [self getNOtificationAuthority];
    }else{// 关闭
        [self notificationShow:NO];
        if (delegate && [delegate respondsToSelector:@selector(openOrCloseNotification:)]) {
            [delegate openOrCloseNotification:NO];
        }
    }
}

- (void)getNOtificationAuthority
{
    
    if ([ToolUtils isAllowedNotification]) {
        [switchView setOn:YES animated:YES];
        [self notificationShow:YES];
        // 允许推送
        if (delegate && [delegate respondsToSelector:@selector(openOrCloseNotification:)]) {
            [delegate openOrCloseNotification:NO];
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            tryOpen = YES;
            [switchView setOn:NO animated:YES];
        });
        
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"打开通知" message:@"去设置当中，把推送通知打开" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置", nil];
        [alerView show];
    }
}
- (void)applicationDidBecomeActive
{
    if (tryOpen) {
        [switchView setOn:YES animated:YES];
        if (delegate && [delegate respondsToSelector:@selector(openOrCloseNotification:)]) {
            [delegate openOrCloseNotification:YES];
        }
    }
   
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        tryOpen = NO;
    }else{
        
        if (UIApplicationOpenSettingsURLString != NULL) {
            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:appSettings];
        }else{
            NSURL*url=[NSURL URLWithString:@"app-settings:"];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end


@interface PushView ()<UIScrollViewDelegate,SelectedItemCellDelegate>

@property (nonatomic, strong) UIScrollView *mainScrllView;
@property (nonatomic) PushViewType lastPushViewType;
@property (nonatomic, strong) UIButton *upButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *lineImageView;

@property (nonatomic, assign) NSInteger index;
@end


@implementation PushView
@synthesize delegate;
@synthesize lastPushViewType;
@synthesize titleLabel;
@synthesize lineImageView;

@synthesize roomItem;

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        lastPushViewType = -1;
        
        self.upButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.frame.size.width, 40)];
        [self.upButton setTitle:@"Close" forState:UIControlStateNormal];
        [self.upButton setCenter:CGPointMake(self.bounds.size.width/2, self.upButton.center.y)];
        [self.upButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.upButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        self.backgroundColor = [UIColor blackColor];
        self.mainScrllView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.mainScrllView.delegate = self;
      
        self.mainScrllView.backgroundColor = [UIColor blackColor];
        [self addSubview:self.mainScrllView];
        
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 80, self.bounds.size.width, 40)];
        [self addSubview:shadowView];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = shadowView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.1].CGColor,
                    
                           (id)[UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.9].CGColor,nil];
        [shadowView.layer insertSublayer:gradient atIndex:0];
        [self addSubview:self.upButton];
        
    }
    self.hidden = YES;
    self.alpha = 0;
    self.upButton.alpha = 0;
    [self.mainScrllView setFrame:CGRectMake(0, self.mainScrllView.frame.size.height, self.mainScrllView.bounds.size.width, self.mainScrllView.frame.size.height)];
    return self;
}

- (void)showViewOptionWithType:(PushViewType)type
{
    CGFloat startY = self.frame.size.height/2 - 40;
    
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, startY, self.frame.size.width - 40, 30)];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.text = roomItem.roomName;
        [self.mainScrllView addSubview:titleLabel];
    }else{
        titleLabel.text = roomItem.roomName;
    }
    if (!lineImageView) {
        lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame)+ 20, self.frame.size.width, 1)];
        lineImageView.backgroundColor = [UIColor grayColor];
        [self.mainScrllView addSubview:lineImageView];
    }
    // 把之前的清除掉
    for (id itemView in self.mainScrllView.subviews) {
        if ([itemView isKindOfClass:[SelectedItemCell class]]) {
            [itemView removeFromSuperview];
        }
    }
    startY = CGRectGetMaxY(lineImageView.frame);
    
    if (type == PushViewTypeDefault) {
        SelectedItemCell *inviteMessage = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, startY, self.frame.size.width, CellHeight) withTitle:@"短信邀请" withImageName:@"message_main" withType:PushViewTypeDefault withIndex:0 withItem:roomItem];
        inviteMessage.delegate = self;
        
         SelectedItemCell *inviteMail = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inviteMessage.frame), self.frame.size.width, CellHeight) withTitle:@"微信邀请" withImageName:@"mail_main" withType:PushViewTypeDefault withIndex:1 withItem:roomItem];
        inviteMail.delegate = self;
        
         SelectedItemCell *inviteLink = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inviteMail.frame), self.frame.size.width, CellHeight) withTitle:@"拷贝链接" withImageName:@"link_main" withType:PushViewTypeDefault withIndex:2 withItem:roomItem];
        inviteLink.delegate = self;
        
        [self.mainScrllView addSubview:inviteMessage];
        [self.mainScrllView addSubview:inviteMail];
        [self.mainScrllView addSubview:inviteLink];
    }else{
        SelectedItemCell *joinRoom = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, startY, self.frame.size.width, CellHeight) withTitle:@"进入会议" withImageName:@"enter_main" withType:PushViewTypeSetting withIndex:0 withItem:roomItem];
        joinRoom.delegate = self;
        
        SelectedItemCell *inviteMessage = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(joinRoom.frame), self.frame.size.width, CellHeight) withTitle:@"短信邀请" withImageName:@"message_main" withType:PushViewTypeSetting withIndex:1 withItem:roomItem];
        inviteMessage.delegate = self;
        
        SelectedItemCell *inviteMail = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inviteMessage.frame), self.frame.size.width, CellHeight) withTitle:@"微信邀请" withImageName:@"weixin_main" withType:PushViewTypeSetting withIndex:2 withItem:roomItem];
        inviteMail.delegate = self;
        
        SelectedItemCell *inviteLink = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inviteMail.frame), self.frame.size.width, CellHeight) withTitle:@"拷贝链接" withImageName:@"link_main" withType:PushViewTypeSetting withIndex:3 withItem:roomItem];
        inviteLink.delegate = self;
        
        SelectedItemCell *notifications = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(inviteLink.frame), self.frame.size.width, CellHeight) withTitle:@"通知" withImageName:@"notification_not_main" withType:PushViewTypeSetting withIndex:4 withItem:roomItem];
        notifications.delegate = self;
        
        SelectedItemCell *renameRoom = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(notifications.frame), self.frame.size.width, CellHeight) withTitle:@"修改会议名称" withImageName:@"rename_main" withType:PushViewTypeSetting withIndex:5 withItem:roomItem];
        renameRoom.delegate = self;
        
        SelectedItemCell *delegateRoom = [[SelectedItemCell alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(renameRoom.frame), self.frame.size.width, CellHeight) withTitle:@"删除会议" withImageName:@"delegate_main" withType:PushViewTypeSetting withIndex:6 withItem:roomItem];
        delegateRoom.delegate = self;
        
        [self.mainScrllView addSubview:joinRoom];
        [self.mainScrllView addSubview:inviteMessage];
        [self.mainScrllView addSubview:inviteMail];
        [self.mainScrllView addSubview:inviteLink];
        [self.mainScrllView addSubview:notifications];
        [self.mainScrllView addSubview:renameRoom];
        [self.mainScrllView addSubview:delegateRoom];
        
    }
}

- (void)showWithType:(PushViewType)type withObject:(id)object withIndex:(NSInteger)index {
    self.index = index;
    roomItem = object;
    if (type == PushViewTypeSetting) {
          self.mainScrllView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height + self.frame.size.height/4);
    }else{
          self.mainScrllView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    [self showViewOptionWithType:type];
    lastPushViewType = type;
    
    self.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        
        self.alpha = 1;
        self.upButton.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4 animations: ^{
            [self.mainScrllView setFrame:CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height - 90)];
            
             self.upButton.frame = CGRectMake(0, self.bounds.size.height - 50, self.frame.size.width, 40);
        }];
    }];

}
- (void)close
{
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.mainScrllView setFrame:CGRectMake(0, self.frame.size.height, self.bounds.size.width, self.frame.size.height)];
        self.upButton.frame = CGRectMake(0, self.bounds.size.height, self.frame.size.width, 40);
        
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
           
            self.alpha = 0;
            self.upButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            self.hidden = YES;
            // 还原
            [self.mainScrllView setContentOffset:CGPointMake(0, 0) animated:NO];

        }];
    }];

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y < -1.5) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self.mainScrllView setFrame:CGRectMake(0, self.frame.size.height, self.bounds.size.width, self.frame.size.height)];
            self.upButton.frame = CGRectMake(0, self.bounds.size.height, self.frame.size.width, 40);

            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                
                self.alpha = 0;
                self.upButton.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                self.hidden = YES;
                // 还原
                [self.mainScrllView setContentOffset:CGPointMake(0, 0) animated:NO];
            }];

        }];
    }
}

#pragma mark - SelectedItemCellDelegate

- (void)selectedItemCell:(NSInteger)index
{
    if (!delegate) {
        return;
    }
    if (lastPushViewType ==  PushViewTypeDefault) {
        [self close];
        
        if (index == 0) {
            if ([delegate respondsToSelector:@selector(pushViewInviteViaMessages:)]) {
                [delegate pushViewInviteViaMessages:roomItem];
            }
        }else if (index == 1){
            if ([delegate respondsToSelector:@selector(pushViewInviteViaWeiXin:)]) {
                [delegate pushViewInviteViaWeiXin:roomItem];
            }
        }else if (index == 2){
            if ([delegate respondsToSelector:@selector(pushViewInviteViaLink:)]) {
                [delegate pushViewInviteViaLink:roomItem];
            }
        }
        
        
    }else if (lastPushViewType == PushViewTypeSetting){
        if (index !=  4) {
            [self close];
        }
        if (index == 0) {
            if ([delegate respondsToSelector:@selector(pushViewJoinRoom:)]) {
                [delegate pushViewJoinRoom:roomItem];
            }
        }else  if (index == 1) {
            if ([delegate respondsToSelector:@selector(pushViewInviteViaMessages:)]) {
                [delegate pushViewInviteViaMessages:roomItem];
            }
        }else if (index == 2){
            if ([delegate respondsToSelector:@selector(pushViewInviteViaWeiXin:)]) {
                [delegate pushViewInviteViaWeiXin:roomItem];
            }
        }else if (index == 3){
            if ([delegate respondsToSelector:@selector(pushViewInviteViaLink:)]) {
                [delegate pushViewInviteViaLink:roomItem];
            }
        }else if (index == 5){
            if ([delegate respondsToSelector:@selector(pushViewRenameRoom:)]) {
                [delegate pushViewRenameRoom:roomItem];
            }
        }else if (index == 6){
            if ([delegate respondsToSelector:@selector(pushViewDelegateRoom:withIndex:)]) {
                [delegate pushViewDelegateRoom:roomItem withIndex:self.index];
            }
        }
    }
}

- (void)openOrCloseNotification:(BOOL)isOpen
{
    if (roomItem) {
        roomItem.canNotification = [[NSNumber numberWithBool:isOpen] stringValue];
        if ([delegate respondsToSelector:@selector(pushViewCloseOrOpenNotifications:withOpen:withIndex:)]) {
            [delegate pushViewCloseOrOpenNotifications:roomItem withOpen:isOpen withIndex:self.index];
        }
    }
}

@end
