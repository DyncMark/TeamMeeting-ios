//
//  CallOtherViewController.m
//  DropevaDevice
//
//  Created by zjq on 15/10/10.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "ReceiveCallViewController.h"
#import "DyncM2MClient.h"
#import "AvcAudioRouteMgr.h"
#import <AVFoundation/AVFoundation.h>
#import "ASHUD.h"

@interface ReceiveCallViewController ()<DyncM2MClientDelegate,UIGestureRecognizerDelegate>
{
    AvcAudioRouteMgr *_audioManager;
    UIView *_localVideoView;
    
    CGSize _localVideoSize;
    CGSize _videoSize;
    
    NSString *_peerSelectedId;
    
    
    // VIEW
   
    BOOL _isHidden;
    UIView *_toolBarView;
    UIButton *_videoButton;
    UIButton *_muteButton;
    UIButton *_cameraSwitchButton;
     BOOL videoEnable;
    
    UIAlertView *_exitErrorAlertView;   // 退出房间失败的问题
    UIAlertView *_exitRoomAlertView;    // 退出房间
    
}
@property (nonatomic, strong)  NSMutableDictionary *_dicRemoteVideoView;
@property (nonatomic, strong) NSMutableArray *_userArray;
@property (nonatomic, strong) NSMutableArray *_channelArray;

@property(nonatomic, strong) DyncM2MClient *_client;
@property(nonatomic, strong) UIScrollView *videosScrollView;

@end

@implementation ReceiveCallViewController

@synthesize _dicRemoteVideoView;
@synthesize _client;
@synthesize roomID;
@synthesize _userArray,_channelArray;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if (_audioManager) {
        _audioManager = nil;
    }
    
    if (_dicRemoteVideoView) {
        _dicRemoteVideoView = nil;
    }
    
    if (_client) {
        _client  = nil;
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.videosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 210, self.view.bounds.size.width, 120)];
    [self.videosScrollView setUserInteractionEnabled:YES];
    [self.videosScrollView setContentSize:CGSizeMake(self.view.bounds.size.width*2, 120)];
    [self.videosScrollView setContentOffset:CGPointMake(self.videosScrollView.contentSize.width/4, 0) animated:YES];
    self.videosScrollView.backgroundColor = [UIColor clearColor];
    _peerSelectedId = nil;
    _isHidden = NO;
    _userArray = [[NSMutableArray alloc] initWithCapacity:5];
    _channelArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    _dicRemoteVideoView = [[NSMutableDictionary alloc] initWithCapacity:5];
    
    _client = [[DyncM2MClient alloc] initWithDelegate:self];
    _localVideoView =_client.localView;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(locolvideoSingleTap:)];
    singleTapGestureRecognizer.delegate = self;
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [_localVideoView addGestureRecognizer:singleTapGestureRecognizer];
    [self.view addSubview:_localVideoView];
    
    [_client signInWithRoomId:roomID withIsPresenter:NO];
    [ASHUD showHUDWithStayLoadingStyleInView:self.view belowView:nil content:@"接听中。。。"];
    [self.view addSubview:self.videosScrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    Class class = NSClassFromString(@"GLKView");
    if ([touch.view isKindOfClass:class] && CGRectGetWidth(touch.view.frame) < self.view.bounds.size.width/2){
        
        return YES;
        
    }
    return NO;
}


#pragma mark - publish method
- (void)videoEnable:(BOOL)enable
{
    if (_client) {
         [_client setLocalVideoEnable:enable];
    }
}
- (void)audioEnable:(BOOL)enable
{
    if (_client) {
        [_client setLocalAudioEnable:enable];
    }
}

- (void)switchCamera // switch camera
{
    if (_client) {
        [_client switchCamear];
    }
}
- (void)hangeUp      // hunge up
{
    if (_client) {
        [_client signOut];
    }
    return;
    _exitRoomAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"你确定要退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [_exitRoomAlertView show];
}
- (void)sendMessageWithCmmand:(NSString *)cmd userID:(NSString *)userid {
    
}

#pragma mark - notification
// 程序进入后台时，停止视频
- (void)applicationWillResignActive
{
    if (!_videoButton.selected) {
        videoEnable = YES;
        [_client setLocalVideoEnable:NO];
    }
}

// 程序进入前台时，重启视频
- (void)applicationDidBecomeActive
{
    if (videoEnable) {
        videoEnable = NO;
        [_client setLocalVideoEnable:YES];
    }
}

- (void)layoutSubView
{
    
    [ASHUD hideHUD];
    if (_peerSelectedId) {
        UIView* view = nil;
        view = [_dicRemoteVideoView objectForKey:_peerSelectedId];

        if (_videoSize.width>0&& _videoSize.height>0) {
            // Aspect fit local video view into a square box.
            CGRect remoteVideoFrame =
            AVMakeRectWithAspectRatioInsideRect(_videoSize, self.view.bounds);
            CGFloat scale = 1;
            if (remoteVideoFrame.size.width < remoteVideoFrame.size.height) {
                // Scale by height.
                scale = self.view.bounds.size.height / remoteVideoFrame.size.height;
            } else {
                // Scale by width.
                scale = self.view.bounds.size.width / remoteVideoFrame.size.width;
            }
            remoteVideoFrame.size.height *= scale;
            remoteVideoFrame.size.width *= scale;
            view.frame = remoteVideoFrame;
            view.center = CGPointMake(self.view.bounds.size.width/2,self.view.bounds.size.height/2);
            
        }else{
            view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);;
        }
        
        
        [self.view sendSubviewToBack:view];
        
        CGFloat scalelocal = _localVideoSize.width/_localVideoSize.height;
        CGFloat localViewwidth = self.view.bounds.size.width/4;
        CGFloat localViewheight = localViewwidth/scalelocal;
        
        CGFloat remoteViewHeight = 0.0;
        CGFloat remoteViewWidth = 0.0;
        if (_videoSize.width > 0 ) {
            
            CGFloat scale = _videoSize.width/_videoSize.height;
            remoteViewWidth = self.view.bounds.size.width/4;
            remoteViewHeight = remoteViewWidth/scale;
            
        }
        CGFloat x = self.view.bounds.size.width - (_dicRemoteVideoView.count-1)*remoteViewWidth - localViewwidth -20;
        CGFloat y = 180;//self.view.bounds.size.height - localViewheight - 20;
        
        UIView* viewsmail = nil;
        for (id key in [_dicRemoteVideoView allKeys]) {
            if (![key isEqualToString:_peerSelectedId]) {
                viewsmail = [_dicRemoteVideoView objectForKey:key];
                viewsmail.frame = CGRectMake(x, y, remoteViewWidth, remoteViewHeight);
                x+=remoteViewWidth;
            }
        }
        if (_localVideoSize.width && _localVideoSize.height > 0 ) {
            
            _localVideoView.frame =  CGRectMake(0, 0, localViewwidth, localViewheight);
            [_localVideoView removeFromSuperview];
        }
        [self.videosScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        NSMutableArray *videoArrays = [NSMutableArray array];
        [videoArrays addObjectsFromArray:self.videosScrollView.subviews];
        for (NSInteger i = ([videoArrays count]-1) ; i >= 0; i --) {
            UIView *subView = [videoArrays objectAtIndex:i];
            if ([subView isKindOfClass:[UIImageView class]]) {
                
                [videoArrays removeObject:subView];
            }
        }
        if (![videoArrays containsObject:_localVideoView])
            [videoArrays addObject:_localVideoView];
//        if (view)
//            [videoArrays addObject:view];
        
        NSMutableArray *leftVideos = [NSMutableArray array];
        NSMutableArray *rightVideos = [NSMutableArray array];
        for (int i = 0; i < [videoArrays count]; i++) {
            
            UIView *subView = [videoArrays objectAtIndex:i];
            if (i %2 == 0) {
               
                [leftVideos addObject:subView];
                
            } else {
                
                [rightVideos addObject:subView];
            }
            
        }
        for (int i = 0; i < [leftVideos count]; i ++) {
            
            UIView *subView = [videoArrays objectAtIndex:i];
            CGRect rect = CGRectMake(self.videosScrollView.contentSize.width/2 - (i + 1)*subView.bounds.size.width, self.videosScrollView.contentSize.height/2, subView.bounds.size.width, subView.bounds.size.height);
            subView.frame = rect;
            [self.videosScrollView addSubview:subView];
        }
        for (int i = 0; i < [rightVideos count]; i ++) {
            
            UIView *subView = [videoArrays objectAtIndex:i];
            CGRect rect = CGRectMake(self.videosScrollView.contentSize.width/2 + i*subView.bounds.size.width, self.videosScrollView.contentSize.height/2, subView.bounds.size.width, subView.bounds.size.height);
            subView.frame = rect;
            [self.videosScrollView addSubview:subView];
        }
        
    } else {
        
        if (_dicRemoteVideoView.count==0) {
            if (_localVideoSize.width && _localVideoSize.height > 0) {
                float scaleW = self.view.bounds.size.width/_localVideoSize.width;
                float scaleH = self.view.bounds.size.height/_localVideoSize.height;
                if (scaleW>scaleH) {
                    _localVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleW, _localVideoSize.height*scaleW);
                    _localVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
                }else{
                    _localVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleH, _localVideoSize.height*scaleH);
                    _localVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
                }
                
            } else {
                _localVideoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            }
            return;
        }
        if (_localVideoSize.width && _localVideoSize.height > 0) {
            float scaleW = self.view.bounds.size.width/_localVideoSize.width;
            float scaleH = self.view.bounds.size.height/_localVideoSize.height;
            if (scaleW>scaleH) {
                _localVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleW, _localVideoSize.height*scaleW);
                _localVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
            }else{
                _localVideoView.frame = CGRectMake(0, 0, _localVideoSize.width*scaleH, _localVideoSize.height*scaleH);
                _localVideoView.center =  CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));;
            }
        } else {
            _localVideoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        }
        [_localVideoView removeFromSuperview];
        [self.view addSubview:_localVideoView];
        [self.view sendSubviewToBack:_localVideoView];
        
        CGFloat scale = _videoSize.width/_videoSize.height;
        CGFloat remoteViewWidth = self.view.bounds.size.width/4;
        CGFloat remoteViewHeight = remoteViewWidth/scale;
        
        
        
        CGFloat x = self.view.bounds.size.width - _dicRemoteVideoView.count*remoteViewWidth -20;
        CGFloat y = self.view.bounds.size.height - remoteViewHeight - 20;
        
        
        NSMutableArray *videoArrays = [NSMutableArray array];
        UIView* viewsmail = nil;
        for (id key in [_dicRemoteVideoView allKeys]) {
            viewsmail = [_dicRemoteVideoView objectForKey:key];
            viewsmail.frame = CGRectMake(x, y, remoteViewWidth, remoteViewHeight);
            x+=remoteViewWidth;
            [videoArrays addObject:viewsmail];
        }
        for (NSInteger i = ([videoArrays count]-1) ; i >= 0; i --) {
            UIView *subView = [videoArrays objectAtIndex:i];
            if ([subView isKindOfClass:[UIImageView class]]) {
                
                [videoArrays removeObject:subView];
            }
        }
        [videoArrays makeObjectsPerformSelector:@selector(removeFromSuperview)];
        NSMutableArray *leftVideos = [NSMutableArray array];
        NSMutableArray *rightVideos = [NSMutableArray array];
        for (int i = 0; i < [videoArrays count]; i++) {
            
            UIView *subView = [videoArrays objectAtIndex:i];
            if (i %2 == 0) {
                
                [leftVideos addObject:subView];
                
            } else {
                
                [rightVideos addObject:subView];
            }
            
        }
        for (int i = 0; i < [leftVideos count]; i ++) {
            
            UIView *subView = [videoArrays objectAtIndex:i];
            CGRect rect = CGRectMake(self.videosScrollView.contentSize.width/2 - (i + 1)*subView.bounds.size.width, self.videosScrollView.contentSize.height/2, subView.bounds.size.width, subView.bounds.size.height);
            subView.frame = rect;
            [self.videosScrollView addSubview:subView];
        }
        for (int i = 0; i < [rightVideos count]; i ++) {
            
            UIView *subView = [videoArrays objectAtIndex:i];
            CGRect rect = CGRectMake(self.videosScrollView.contentSize.width/2 + i*subView.bounds.size.width, self.videosScrollView.contentSize.height/2, subView.bounds.size.width, subView.bounds.size.height);
            subView.frame = rect;
            [self.videosScrollView addSubview:subView];
        }
    }
}



#pragma mark - Private

- (void)setRemoteVideoView:(UIView *)remoteVideoView withTag:(NSString*)strTag{
    UIView* findView = [_dicRemoteVideoView objectForKey:strTag];
    if (findView == remoteVideoView) {
        return;
    }
    if (!_peerSelectedId) {
        _peerSelectedId = strTag;
    }
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    singleTapGestureRecognizer.delegate = self;
    [remoteVideoView addGestureRecognizer:singleTapGestureRecognizer];
    [self.view addSubview:remoteVideoView];
    
    [_dicRemoteVideoView setObject:remoteVideoView forKey:strTag];
    [self layoutSubView];
    //While the number of remote image change, send a notification
    NSNumber *remoteVideoCount = [NSNumber numberWithInteger:[_dicRemoteVideoView count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOTEVIDEOCHANGE" object:remoteVideoCount];
}

// 删除一个
- (void)setRemoveVideoView:(NSString*)strTag
{
    UIView *findView = [_dicRemoteVideoView objectForKey:strTag];
    if (findView) {
        if ([strTag isEqualToString:_peerSelectedId]) {
            [findView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:strTag];
            if (_dicRemoteVideoView.count!=0) {
                _peerSelectedId =[[_dicRemoteVideoView allKeys] firstObject];
            }else{
                _peerSelectedId = nil;
            }
            [self layoutSubView];
        }else{
            [findView removeFromSuperview];
            [_dicRemoteVideoView removeObjectForKey:strTag];
            [self layoutSubView];
        }
    }
    //While the number of remote image change, send a notification
    NSNumber *remoteVideoCount = [NSNumber numberWithInteger:[_dicRemoteVideoView count]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"REMOTEVIDEOCHANGE" object:remoteVideoCount];
    
}

#pragma mark -  UITapGestureRecognizer
- (void)locolvideoSingleTap:(UITapGestureRecognizer*)gesture
{
    if (_peerSelectedId) {
        _peerSelectedId = nil;
        [self layoutSubView];
        
    }else{
        // 点击的是大图
        _isHidden = !_isHidden;
    }
}
- (void)singleTap:(UITapGestureRecognizer*)gesture
{
    // 像变大(先看是不是点中的)
    UIView  *view = (UIView*)[gesture view];
    // 如果得到的是小图的，变为大图
    if (CGRectGetWidth(view.frame) < self.view.bounds.size.width) {
        for (id key in [_dicRemoteVideoView allKeys]) {
            UIView *item = [_dicRemoteVideoView objectForKey:key];
            if (item == view) {
                _peerSelectedId = key;
                [self layoutSubView];
                return;
            }
        }
    }else{
        _isHidden = !_isHidden;
    }
    
}
#pragma mark -  UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_exitErrorAlertView == alertView) {
//        [self dismissViewControllerAnimated:YES completion:nil];
    }else if (_exitRoomAlertView == alertView){
        if (buttonIndex == 1) {
            [ASHUD showHUDWithStayLoadingStyleInView:self.view belowView:nil content:@"正在退出。。。"];
            [_client signOut];
        }
    }
    
}

#pragma mark - DyncM2MClientDelegate
// 有人进入房间
- (void)appClient:(DyncM2MClient *)client didMemberInRoom:(NSString *)userID withNickName:(NSString *)nickName
{
    [_userArray addObject:userID];
}
// 有人离开房间
- (void)appClient:(DyncM2MClient *)client didMemberLeaveRoom:(NSString *)userID
{
    //做一下判断如果会议中没人了，则推出
    [_userArray removeObject:userID];
    if ([_userArray count]==0) {
        // 对方挂断
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"对方挂断" icon:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_client signOut];
        });
    }
}

- (void)appClient:(DyncM2MClient *)client didReceiveRemoteVideoView:(UIView *)remoteVideoView withTag:(NSString *)strTag
{
    [self setRemoteVideoView:remoteVideoView withTag:strTag];
    if (!_audioManager._isSpeakerOn) {
        [_audioManager setSpeakerOn];
    }
}
- (void)appClient:(DyncM2MClient *)client didReceiveRemoteVideoViewLeaveWithTag:(NSString *)strTag
{
    // 有人离开（更新界面）
    [self setRemoveVideoView:strTag];
}


- (void)appClientInRoomScuess:(DyncM2MClient *)client withRoomId:(NSString*)roomID
{
    // 进入房间后更新界面
    
    [ASHUD hideHUD];
    [self layoutSubView];
}

- (void)appClientInRoomFaile:(DyncM2MClient *)client
{
    // 进入房间失败
    [ASHUD hideHUD];
    [ASHUD showHUDWithCompleteStyleInView:self.view content:@"初始化失败" icon:nil];
}

- (void)appClientPublishScuess:(DyncM2MClient *)client
{
    // 进入房间后更新界面
    [self layoutSubView];
}

- (void)appClient:(DyncM2MClient *)client didReceiveLeaveRoomwithInfo:(NSString*)info
{
    // 自己退出房间
    [ASHUD hideHUD];

}

- (void)appClient:(DyncM2MClient *)client onRoomAudioStatus:(NSString*)peerId isEnable:(BOOL)enable
{
    // 关闭或者打开音频
    [ASHUD hideHUD];
    if (enable) {
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"对方开启了音频" icon:nil];
    }else{
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"对方关闭了音频" icon:nil];
    }
}

- (void)appClient:(DyncM2MClient *)client onRoomVideoStatus:(NSString*)peerId isEnable:(BOOL)enable
{
    // 关闭或者打开视频
    [ASHUD hideHUD];
    if (enable) {
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"对方开启了视频" icon:nil];
    }else{
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"对方关闭了视频" icon:nil];
    }
}
- (void)appClient:(DyncM2MClient *)client OnChannelOpen:(NSString *)userID
{
    if (![_channelArray containsObject:userID]) {
        [_channelArray addObject:userID];
      
    }
}

- (void)appClient:(DyncM2MClient *)client OnChannelClose:(NSString *)userID
{
    if ([_channelArray containsObject:userID]) {
        [_channelArray removeObject:userID];
    }
}
- (void)appClient:(DyncM2MClient *)client didReceiveBytes:(int)bytes
{

}
- (void)appClient:(DyncM2MClient *)client
didReceiveMessage:(NSString*)data withUser:(NSString*)userID
{

}

- (void)appClient:(DyncM2MClient *)client videoView:(UIView *)videoView didChangeVideoSize:(CGSize)size
{
    if (videoView == _localVideoView) {
        _localVideoSize = size;
    }else{
        _videoSize = size;
    }
    [self layoutSubView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
