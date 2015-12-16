//
//  VideoCallViewController.m
//  Room
//
//  Created by yangyang on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "VideoCallViewController.h"
#import "RootViewController.h"
#import "LockerView.h"
#import "DXPopover.h"
#import "AppDelegate.h"
#import "UILabel+Category.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "ReceiveCallViewController.h"
#import <GLKit/GLKit.h>
#import "TalkView.h"
@implementation UINavigationController (Orientations)


- (NSUInteger)supportedInterfaceOrientations {

    return [self.topViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

@end

typedef enum ViewState {
    
    UNKNOWN,
    CHATSTATE,
    VIDEOSTATE

} ViewState;

@interface VideoCallViewController ()<UINavigationControllerDelegate,LockerDelegate,MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate>


@property(nonatomic,strong)UIControl *barView;
@property(nonatomic,strong)UIControl *chatBarView;
@property(nonatomic,strong)LockerView *menuView;
@property(nonatomic,strong)RootViewController *rootView;
@property(nonatomic,assign)ViewState state;
@property(nonatomic,strong)UIImageView *micStateImage;
@property(nonatomic,strong)UIImageView *videoGroudImage;
@property(nonatomic,strong)DXPopover *popver;
@property(nonatomic,strong)ReceiveCallViewController *callViewCon;
@property(nonatomic,strong)UIView *lineView;
@property(nonatomic,strong)UIView *shareViewGround;
@property(nonatomic,strong)TalkView *talkView;
@property(nonatomic,strong)UILabel *noUserTip;

- (void)hidenMenuView:(BOOL)enable;
- (void)hidenBarView;
- (void)showBarView;
- (void)sendMessage;
@end

@implementation VideoCallViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openVideo) name:OPENVIDEO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteVideoChange:) name:@"REMOTEVIDEOCHANGE" object:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.state = VIDEOSTATE;
    [self initBar];
    [self initChatBar];
    self.callViewCon = [[ReceiveCallViewController alloc] init];
    self.callViewCon.roomID = @"123";
    self.callViewCon.view.frame = self.view.bounds;
    self.talkView = [[TalkView alloc] initWithFrame:self.view.bounds];
    self.talkView.userInteractionEnabled = NO;
    self.menuView = [[LockerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 90, 300, 60)];
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.menuView setCenter:CGPointMake(self.view.bounds.size.width/2, self.menuView.center.y)];
    self.menuView.delegate = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.micStateImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"micState"]];
    self.micStateImage.frame = CGRectMake(self.view.bounds.size.width - 40, 66, 40, 40);
    self.micStateImage.hidden = YES;
    
    self.videoGroudImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"videoBackgroud"]];
    self.videoGroudImage.userInteractionEnabled = NO;
    self.videoGroudImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoGroudImage.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.videoGroudImage.alpha = 0;
    self.videoGroudImage.hidden = YES;
    [self.view addSubview:self.videoGroudImage];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, self.view.bounds.size.width, 0.3)];
    self.lineView.hidden = YES;
    [[self.lineView layer] setCornerRadius:1];
    [[self.lineView layer] setBorderWidth:0.3];
    [[self.lineView layer] setBorderColor:[UIColor colorWithWhite:0.7 alpha:1].CGColor];
    [self.view addSubview:self.lineView];
    UIView *touchEvent = [[UIView alloc] initWithFrame:self.view.bounds];
    touchEvent.userInteractionEnabled = YES;
    touchEvent.tag = 500;
    touchEvent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    touchEvent.backgroundColor = [UIColor clearColor];
    [self.view addSubview:touchEvent];
    
    [self.view addSubview:self.callViewCon.view];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [self.view addSubview:self.menuView];
    [delegate.window addSubview:self.talkView];
    
    self.noUserTip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 80, 80)];
    [self.noUserTip setUserInteractionEnabled:NO];
    [self.noUserTip setTextColor:[UIColor whiteColor]];
    [self.noUserTip setNumberOfLines:0];
    [self.noUserTip setTextAlignment:NSTextAlignmentCenter];
    self.noUserTip.text = @"Waiting for others to join the room";
    [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, CGRectGetMidY(self.menuView.frame) - 80)];
    [self.view addSubview:self.noUserTip];
    [self.view addSubview:self.micStateImage];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    return YES;
}

- (void)adjustUI {
    
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    BOOL isVertical = width > height ? NO : YES;
    if (isVertical) {
        
        self.micStateImage.frame = CGRectMake(self.view.bounds.size.width - 40, 66, 40, 40);
        [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, CGRectGetMidY(self.menuView.frame) - 80)];
        
    } else {
        
        self.micStateImage.frame = CGRectMake(self.view.bounds.size.width - 40, 30, 40, 40);
        [self.noUserTip setCenter:CGPointMake(self.view.bounds.size.width/2, CGRectGetMidY(self.menuView.frame) - 80)];
    }
    if (self.menuView.isHiden) {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.barView.frame = CGRectMake(self.barView.frame.origin.x, 0 - self.barView.bounds.size.height - 20, self.barView.bounds.size.width, self.barView.bounds.size.height);
            
        } completion:^(BOOL finished) {
            
        
        }];

    } else {
        
        [UIView animateWithDuration:0.1 animations:^{
            
            self.barView.frame = CGRectMake(self.barView.frame.origin.x, -20, self.barView.bounds.size.width, self.barView.bounds.size.height);
            
        }];
    }
    [UIView animateWithDuration:0.1 animations:^{
        
        self.micStateImage.alpha = 1;
        self.noUserTip.alpha = 1;
        self.menuView.frame =  CGRectMake(self.menuView.frame.origin.x, self.menuView.isHiden ? self.view.bounds.size.height + 20 : (self.view.bounds.size.height - 90) , 300, 60);
        
    }];
}

- (void)messageTest
{
    [self.talkView sendMessageView:@"abcdefgabcdefgabcdefgabcdefgabcdefgabcdefgabcdefg" withUser:@"abc"];
}

- (void)remoteVideoChange:(NSNotification *)noti {
    
    NSNumber *object = [noti object];
    NSInteger remoteCount = [object integerValue];
    if (remoteCount >0) {
        
        [self.noUserTip setHidden:YES];
        
    } else {
        
        [self.noUserTip setHidden:NO];
    }
}

- (void)openVideo {
    
    [self.callViewCon videoEnable:YES];
}

- (void)tapEvent {
    
    if (self.popver) {
        
        [self.popver dismiss];
        [self.shareViewGround performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
        self.popver = nil;
        return;
    }
    
    if (self.state == VIDEOSTATE)

        [self.menuView showEnable:YES];
    
    if (self.state == UNKNOWN || self.state == CHATSTATE)
        return;
    
    if (self.menuView.isHiden) {
        
        self.barView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            
            self.barView.frame = CGRectMake(self.barView.frame.origin.x, -20, self.barView.bounds.size.width, self.barView.bounds.size.height);
            
        }];
        [self hidenMenuView:NO];
        
    } else {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.barView.frame = CGRectMake(self.barView.frame.origin.x, 0 - self.barView.bounds.size.height - 20, self.barView.bounds.size.width, self.barView.bounds.size.height);
            
        } completion:^(BOOL finished) {
            
            self.barView.hidden = YES;
        }];
        [self hidenMenuView:YES];
    }
}

- (void)hidenMenuView:(BOOL)enable {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.menuView.isHiden = enable;
        self.menuView.frame =  CGRectMake(self.menuView.frame.origin.x, enable ? self.view.bounds.size.height + 20 : (self.view.bounds.size.height - 90) , 300, 60);
    }];
    
}

- (void)hidenBarView {

    [UIView animateWithDuration:0.3 animations:^{
        
        self.barView.frame = CGRectMake(self.barView.frame.origin.x, 0 - self.barView.bounds.size.height, self.barView.bounds.size.width, self.barView.bounds.size.height);
        
    } completion:^(BOOL finished) {
        
        self.barView.hidden = YES;
    }];
}

- (void)showBarView {
    
    self.barView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        
        self.barView.frame = CGRectMake(self.barView.frame.origin.x, -20, self.barView.bounds.size.width, self.barView.bounds.size.height);
        
    }];
}

- (void)initBar {
    
    
    [self.barView removeFromSuperview];
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    if (isVertical) {
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.navigationController.delegate = self;
        self.barView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 66)];
        [self.barView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.barView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.7];
        self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [chatButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [chatButton addTarget:self action:@selector(goToChat) forControlEvents:UIControlEventTouchUpInside];
        [chatButton setBackgroundColor:[UIColor clearColor]];
        chatButton.frame = CGRectMake(10, 0, 49, 40);
        [chatButton setCenter:CGPointMake(chatButton.center.x, self.barView.bounds.size.height/2 + 10)];
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareView) forControlEvents:UIControlEventTouchUpInside];
        shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        shareButton.frame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 50);
        shareButton.center = CGPointMake(shareButton.center.x, self.barView.bounds.size.height/2 + 10);
        
        UILabel *naiTitle = [[UILabel alloc] init];
        naiTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [naiTitle setTextColor:[UIColor whiteColor]];
        naiTitle.text = @"5566";
        [naiTitle setFont:[UIFont boldSystemFontOfSize:18]];
        [naiTitle setTextAlignment:NSTextAlignmentCenter];
        [naiTitle setLineBreakMode:NSLineBreakByWordWrapping];
        CGSize labelsize = [naiTitle boundingRectWithSize:CGSizeMake(100, 40)];
        [naiTitle setFrame:CGRectMake(0, 30, labelsize.width, labelsize.height)];
        [naiTitle setBackgroundColor:[UIColor clearColor]];
        naiTitle.center = CGPointMake(self.barView.bounds.size.width/2, self.barView.bounds.size.height/2 + 10);
        
        [self.barView addSubview:naiTitle];
        [self.barView addSubview:shareButton];
        [self.barView addSubview:chatButton];
        
    } else {
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.navigationController.delegate = self;
        self.barView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 50)];
        [self.barView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.barView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.7];
        self.barView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [chatButton setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
        [chatButton addTarget:self action:@selector(goToChat) forControlEvents:UIControlEventTouchUpInside];
        [chatButton setBackgroundColor:[UIColor clearColor]];
        chatButton.frame = CGRectMake(10, 0, 49, 40);
        [chatButton setCenter:CGPointMake(chatButton.center.x, self.barView.bounds.size.height/2 + 10)];
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareButton addTarget:self action:@selector(shareView) forControlEvents:UIControlEventTouchUpInside];
        shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        shareButton.frame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 50);
        shareButton.center = CGPointMake(shareButton.center.x, self.barView.bounds.size.height/2 + 10);
        
        UILabel *naiTitle = [[UILabel alloc] init];
        //naiTitle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [naiTitle setTextColor:[UIColor whiteColor]];
        naiTitle.text = @"5566";
        [naiTitle setFont:[UIFont boldSystemFontOfSize:18]];
        [naiTitle setTextAlignment:NSTextAlignmentCenter];
        [naiTitle setLineBreakMode:NSLineBreakByWordWrapping];
        CGSize labelsize = [naiTitle boundingRectWithSize:CGSizeMake(100, 40)];
        [naiTitle setFrame:CGRectMake(0, 30, labelsize.width, labelsize.height)];
        [naiTitle setBackgroundColor:[UIColor clearColor]];
        naiTitle.center = CGPointMake(self.barView.bounds.size.width/2, self.barView.bounds.size.height/2 + 10);
        
        [self.barView addSubview:naiTitle];
        [self.barView addSubview:shareButton];
        [self.barView addSubview:chatButton];
    }
    [self.navigationController.navigationBar addSubview:self.barView];
}

- (void)initChatBar {
    
    [self.chatBarView removeFromSuperview];
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    if (isVertical) {
        
        [self.rootView resetInputFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
        self.lineView.frame = CGRectMake(0, 66, self.view.bounds.size.width, 0.3);
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        self.chatBarView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 66)];
        [self.chatBarView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.chatBarView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.8];
        self.chatBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"cancelChat"] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeChatView) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        closeButton.frame = CGRectMake(15, 30, 25, 25);
        closeButton.center = CGPointMake(closeButton.center.x, closeButton.center.y);
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,30, 60, 20)];
        title.center = CGPointMake(self.chatBarView.bounds.size.width/2, title.center.y);
        [title setFont:[UIFont boldSystemFontOfSize:18]];
        title.text = @"Chat";
        [title setBackgroundColor:[UIColor clearColor]];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        [self.chatBarView addSubview:title];
        [self.chatBarView addSubview:closeButton];
        
    } else {
        
        [self.rootView resetInputFrame:CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40)];
        self.lineView.frame = CGRectMake(0, 30, self.view.bounds.size.width, 0.3);
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.chatBarView = [[UIControl alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, 50)];
        [self.chatBarView addTarget:self action:@selector(topBarTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        self.chatBarView.backgroundColor = [UIColor colorWithRed:24.f/255.f green:24.f/255.f blue:24.f/255.f alpha:0.8];
        self.chatBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"cancelChat"] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeChatView) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        closeButton.frame = CGRectMake(15, 0, 25, 25);
        closeButton.center = CGPointMake(closeButton.center.x, self.chatBarView.bounds.size.height/2 + 10);
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0,30, 60, 20)];
        title.center = CGPointMake(self.chatBarView.bounds.size.width/2, self.chatBarView.bounds.size.height/2 + 10);
        [title setFont:[UIFont boldSystemFontOfSize:18]];
        title.text = @"Chat";
        [title setBackgroundColor:[UIColor clearColor]];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        [self.chatBarView addSubview:title];
        [self.chatBarView addSubview:closeButton];
    }
    [self.navigationController.navigationBar addSubview:self.chatBarView];
    self.chatBarView.hidden = YES;
}

- (void)topBarTouchEvent {
    
    if (self.popver) {
        
        [self.popver dismiss];
        [self.shareViewGround performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.2];
        self.popver = nil;
    }
}

- (void)shareView {
    
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    
    UIView *shareView = [[UIView alloc] init];
    shareView.backgroundColor = [UIColor colorWithRed:205.f/255.f green:205.f/255.f blue:203.f/255.f alpha:1];
    if (!isVertical) {
        
        shareView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 30, self.view.bounds.size.height - 66);
        
    } else {
        
        shareView.frame = CGRectMake(0, 0, self.view.bounds.size.width - 30, 400);
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 8;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:19],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.bounds.size.width-40, 60)];
    title.attributedText = [[NSAttributedString alloc] initWithString:@"How do you want to invite people to the room?" attributes:attributes];
    title.autoresizingMask = UIViewContentModeBottom;
    [title setTextAlignment:NSTextAlignmentCenter];
    //[title setFont:[UIFont boldSystemFontOfSize:19]];
    [title setTextColor:[UIColor blackColor]];
    [title setNumberOfLines:0];
    [shareView addSubview:title];
    
    UIButton *messageImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [messageImage addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [messageImage setBackgroundImage:[UIImage imageNamed:@"messageInvite"] forState:UIControlStateNormal];
    messageImage.backgroundColor = [UIColor clearColor];
    [shareView addSubview:messageImage];
    
    UIImageView *mailImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [mailImage setImage:[UIImage imageNamed:@"mailInvite"]];
    mailImage.backgroundColor = [UIColor clearColor];
    [shareView addSubview:mailImage];
    
    
    UIImageView *bottomBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharebackgroud"]];
    bottomBar.autoresizingMask = UIViewContentModeBottom;
    bottomBar.backgroundColor = [UIColor redColor];
    [shareView addSubview:bottomBar];
    
    UILabel *messageTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [messageTitle setFont:[UIFont systemFontOfSize:12]];
    messageTitle.text = @"Message";
    [messageTitle setTextColor:[UIColor blackColor]];
    [messageTitle setTextAlignment:NSTextAlignmentCenter];
    
    UILabel *mailTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [mailTitle setFont:[UIFont systemFontOfSize:12]];
    mailTitle.text = @"Mail";
    [mailTitle setTextColor:[UIColor blackColor]];
    [mailTitle setTextAlignment:NSTextAlignmentCenter];
    [shareView addSubview:messageTitle];
    [shareView addSubview:mailTitle];
    
    
    UILabel *descriptionTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.bounds.size.width - 40, 80)];
    
    descriptionTitle.attributedText = [[NSAttributedString alloc] initWithString:@"You can also copy adn paste the secure room link to invite others" attributes:attributes];
    [descriptionTitle setFont:[UIFont systemFontOfSize:17]];
    [descriptionTitle setNumberOfLines:0];
    [descriptionTitle setTextColor:[UIColor grayColor]];
    [descriptionTitle setTextAlignment:NSTextAlignmentCenter];
    [descriptionTitle setBackgroundColor:[UIColor clearColor]];
    [shareView addSubview:descriptionTitle];
    
    UILabel *linkTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, shareView.bounds.size.width - (isVertical ? 60 : 120), 56)];
    [linkTitle setFont:[UIFont systemFontOfSize:12]];
    linkTitle.text = @"room.com/#/...EE83927489327";
    [linkTitle setTextColor:[UIColor grayColor]];
    [linkTitle setBackgroundColor:[UIColor clearColor]];
    [linkTitle setTextAlignment:NSTextAlignmentCenter];
    [shareView addSubview:linkTitle];
    
    UIButton *copyLink = [[UIButton alloc] init];
    [copyLink setTitle:@"Copy" forState:UIControlStateNormal];
    [copyLink setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [copyLink setBackgroundColor:[UIColor clearColor]];
    [shareView addSubview:copyLink];
    
    if (!isVertical) {
        
        [title setCenter:CGPointMake(shareView.bounds.size.width/2, 40)];
        messageImage.center = CGPointMake(shareView.bounds.size.width/2 - 40, CGRectGetMaxY(title.frame) + 30);
        mailImage.center = CGPointMake(shareView.bounds.size.width/2 + 40, CGRectGetMaxY(title.frame) + 30);
        bottomBar.frame = CGRectMake(0, shareView.bounds.size.height - 36, shareView.bounds.size.width +1, 36);
        [messageTitle setCenter:CGPointMake(messageImage.center.x, CGRectGetMaxY(messageImage.frame) + 15)];
        [mailTitle setCenter:CGPointMake(mailImage.center.x, CGRectGetMaxY(mailImage.frame) + 15)];
        [descriptionTitle setCenter:CGPointMake(shareView.bounds.size.width/2, CGRectGetMaxY(mailTitle.frame) + 25)];
        [linkTitle setCenter:CGPointMake(linkTitle.center.x, shareView.bounds.size.height - 20)];
        [copyLink setFrame:CGRectMake(CGRectGetMaxX(linkTitle.frame), 0, shareView.bounds.size.width - CGRectGetMaxX(linkTitle.frame), 45)];
        [copyLink setCenter:CGPointMake(copyLink.center.x, shareView.bounds.size.height - 20)];
        
    }  else {
        
        [title setCenter:CGPointMake(shareView.bounds.size.width/2, 60)];
        messageImage.center = CGPointMake(shareView.bounds.size.width/2 - 40, CGRectGetMaxY(title.frame) + 50);
        mailImage.center = CGPointMake(shareView.bounds.size.width/2 + 40, CGRectGetMaxY(title.frame) + 50);
        bottomBar.frame = CGRectMake(0, shareView.bounds.size.height - 56, shareView.bounds.size.width +1, 56);
        [messageTitle setCenter:CGPointMake(messageImage.center.x, CGRectGetMaxY(messageImage.frame) + 15)];
        [mailTitle setCenter:CGPointMake(mailImage.center.x, CGRectGetMaxY(mailImage.frame) + 15)];
        [descriptionTitle setCenter:CGPointMake(shareView.bounds.size.width/2, CGRectGetMaxY(mailTitle.frame) + 35)];
        [linkTitle setCenter:CGPointMake(linkTitle.center.x, shareView.bounds.size.height - 30)];
        [copyLink setFrame:CGRectMake(CGRectGetMaxX(linkTitle.frame), 0, shareView.bounds.size.width - CGRectGetMaxX(linkTitle.frame), 56)];
        [copyLink setCenter:CGPointMake(copyLink.center.x, shareView.bounds.size.height - 30)];
        
    }
    if (self.popver) {
        
        [self.popver dismiss];
        self.popver = nil;
    }
    self.popver = [DXPopover popover];
    self.popver.sideEdge = 15;
    self.popver.arrowSize = CGSizeMake(15, 15);
    if (_shareViewGround) {
        
        [_shareViewGround removeFromSuperview];
    }
    _shareViewGround = [[UIView alloc] initWithFrame:self.view.bounds];
    _shareViewGround.userInteractionEnabled = YES;
    _shareViewGround.tag = 500;
    _shareViewGround.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _shareViewGround.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_shareViewGround];
    if (!isVertical) {
    
        [self.popver showAtPoint:CGPointMake(self.view.bounds.size.width - 25, 32) popoverPostion:DXPopoverPositionDown withContentView:shareView inView:_shareViewGround];
        
    } else {
        
        [self.popver showAtPoint:CGPointMake(self.view.bounds.size.width - 25, 65) popoverPostion:DXPopoverPositionDown withContentView:shareView inView:_shareViewGround];
        
    }
}

- (void)closeChatView {
    
    [self showBarView];
    self.lineView.hidden = YES;
    self.chatBarView.hidden = YES;
    [UIView animateWithDuration:0.1 animations:^{
        
        self.menuView.alpha = 1;
        self.videoGroudImage.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        self.videoGroudImage.hidden = YES;
        [self.rootView.view removeFromSuperview];
        //[self initBar];
    }];
    self.state = VIDEOSTATE;
}

- (void)oritionChange {
    
    [self.rootView.view removeFromSuperview];
    [self hidenBarView];
    [self initChatBar];
    self.lineView.hidden = NO;
    self.chatBarView.hidden = NO;
    self.videoGroudImage.hidden = NO;
    [self.view addSubview:self.rootView.view];
    self.rootView.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.videoGroudImage.alpha = 1;
        self.menuView.alpha = 0;
    }];
    self.state = CHATSTATE;
}

- (void)goToChat {
    
    [self.rootView.view removeFromSuperview];
    self.rootView = [[RootViewController alloc] init];
    self.rootView.parentViewCon = self;
    self.rootView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rootView.view.frame = self.view.bounds;
    
    [self hidenBarView];
    [self initChatBar];
    self.lineView.hidden = NO;
    self.chatBarView.hidden = NO;
    self.videoGroudImage.hidden = NO;
    [self.view addSubview:self.rootView.view];
    self.rootView.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.videoGroudImage.alpha = 1;
        self.menuView.alpha = 0;
    }];
    self.state = CHATSTATE;
}

- (void)menuClick:(LockerButton *)item {
    
    if (item.tag == 10) {
        
        if (self.callViewCon) {
            [self.callViewCon hangeUp];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else if (item.tag == 20) {
       
        item.isSelect = !item.isSelect;
        if (self.callViewCon) {
            [self.callViewCon audioEnable:!item.isSelect];
        }
        if (!item.isSelect) {
    
            [self.micStateImage setHidden:YES];
            [item setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            [item setBackgroundImage:[UIImage imageNamed:@"micselect"] forState:UIControlStateHighlighted];
            
        } else {
            
            [self.micStateImage setHidden:NO];
            [item setBackgroundImage:[UIImage imageNamed:@"noMic"] forState:UIControlStateNormal];
            [item setBackgroundImage:[UIImage imageNamed:@"noMicselect"] forState:UIControlStateHighlighted];
        }
    }else if(item.tag == 30){
        
        if (self.callViewCon) {
            [self.callViewCon switchCamera];
        }
        
    }else if (item.tag == 40){
        
        item.isSelect = !item.isSelect;
        if (self.callViewCon) {
            [self.callViewCon videoEnable:!item.isSelect];
        }
        [self.menuView showEnable:YES];
    }
}

- (void)sendMessage {
    
    [_popver dismiss];
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"test";
        
        controller.recipients = nil;
        
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    if (self.popver) {
        
        [self.popver dismiss];
        self.popver = nil;
    }
    self.micStateImage.alpha = 0;
    self.noUserTip.alpha = 0;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    if (self.state == CHATSTATE) {
        
        [self oritionChange];
        
    } else if (self.state == VIDEOSTATE){
        
        [self closeChatView];
        [self initBar];
    }
    if (self.popver) {
        
       [self performSelector:@selector(shareView) withObject:nil afterDelay:0.3];
    }
    [self adjustUI];
}

- (BOOL)isVertical {
    
    BOOL isVertical = YES;
    NSUInteger width = self.view.bounds.size.width;
    NSUInteger height = self.view.bounds.size.height;
    isVertical = width > height ? NO : YES;
    return isVertical;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self.rootView hidenInput];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
