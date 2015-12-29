//
//  MainViewController.m
//  Room
//
//  Created by yangyang on 15/11/16.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "MainViewController.h"
#import "PushView.h"
#import "RoomViewCell.h"
#import "UIImageView+LBBlurredImage.h"
#import "GetRoomView.h"
#import "VideoCallViewController.h"
#import "RoomVO.h"
#import "ServerVisit.h"
#import "SvUDIDTools.h"
#import "ToolUtils.h"
#import "ASHUD.h"
#import <MessageUI/MessageUI.h>
#import "ASNetwork.h"
#import "RoomAlertView.h"
#import "UINavigationBar+Category.h"
#import "NavView.h"

static NSString *kRoomCellID = @"RoomCell";

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,RoomViewCellDelegate,GetRoomViewDelegate,PushViewDelegate,MFMessageComposeViewControllerDelegate>


@property (nonatomic, strong) UITableView *roomList;
@property (nonatomic, strong) UIButton *getRoomButton;
@property (nonatomic, strong) PushView *push;
@property (nonatomic, strong) GetRoomView *getRoomView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *tempDataArray; // 临时数据
@property (nonatomic, strong) UIButton *cancleButton;    // 取消创建房间
@property (nonatomic, strong) RoomAlertView *netAlertView;
@property (nonatomic, strong) NavView *navView;
@property (nonatomic, assign) UIInterfaceOrientation oldInterface;

@end

@implementation MainViewController
@synthesize dataArray;
@synthesize tempDataArray;

- (void)dealloc
{
    [[ASNetwork sharedNetwork] removeObserver:self forKeyPath:@"_netType" context:nil];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"房间";
    self.oldInterface = self.interfaceOrientation;
    self.view.backgroundColor = [UIColor clearColor];
    
    [[ASNetwork sharedNetwork] addObserver:self forKeyPath:@"_netType" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    if (!dataArray) {
        dataArray = [[NSMutableArray alloc] initWithCapacity:5];
        tempDataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [self initUser];
    [self setBackGroundImageView];
    
    self.navView = [NavView new];
    self.navView.title = @"房间";
    [self.view addSubview:self.navView];
    
    self.roomList = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.roomList.backgroundColor = [UIColor clearColor];
    self.roomList.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.roomList.delegate = self;
    self.roomList.dataSource = self;
    [self.view addSubview:self.roomList];
    [self.roomList registerClass:[RoomViewCell class] forCellReuseIdentifier:kRoomCellID];
    
    self.getRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.getRoomButton setTitle:@"获取房间" forState:UIControlStateNormal];
     [self.getRoomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getRoomButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:self.getRoomButton];
    [self.getRoomButton addTarget:self action:@selector(getRoomButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.getRoomButton setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:139.0/255.0 blue:75.0/255.0 alpha:1.0]];
    self.getRoomButton.layer.cornerRadius = 2;
    
    self.push = [[PushView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.rootViewController.view.bounds];
    self.push.delegate = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.push];
    
    self.getRoomView = [[GetRoomView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, CGRectGetHeight(self.view.frame)) withParView:self.view];
    self.getRoomView.delegate = self;
    
    self.cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancleButton.frame = CGRectMake(15, 25, 35, 28);
    [self.cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    self.cancleButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.cancleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.cancleButton addTarget:self action:@selector(cancleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *cancleItem =[[UIBarButtonItem alloc] initWithCustomView:self.cancleButton];
//    self.navigationItem.leftBarButtonItem = cancleItem;
    [self.navView addSubview:self.cancleButton];
    self.cancleButton.hidden = YES;
    
    if (ISIPAD) {
        
    }else{
        self.navView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
        self.roomList.frame = CGRectMake(0, 64, self.view.bounds.size.width,CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.navView.frame) -75);
        self.getRoomButton.frame = CGRectMake(15, CGRectGetMaxY(self.view.frame) - 60,self.view.bounds.size.width -30, 45);

    }
}
// 旋转屏幕适配
- (void)viewDidLayoutSubviews
{
    NSLog(@"viewDidLayoutSubviews:%ld",(long)self.interfaceOrientation);
    if (self.oldInterface == self.interfaceOrientation || !ISIPAD) {
        return;
    }else{
         UIView *initView = [[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:400];
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            if (initView) {
                initView.frame = [UIScreen mainScreen].bounds;
            }
            
        }else if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
            if (initView) {
                initView.frame = [UIScreen mainScreen].bounds;
            }
        }
    }
    self.oldInterface = self.interfaceOrientation;
    
}
#pragma mark -private methods

- (void)initUser
{
    UIView *initView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    initView.backgroundColor = [UIColor clearColor];
    initView.tag = 400;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:initView];
    
    UIImageView *initViewBg = [UIImageView new];
    [initView addSubview:initViewBg];
    
    initViewBg.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(initViewBg);
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[initViewBg]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[initViewBg]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    

    int height = CGRectGetHeight(self.view.bounds);
    NSString *imageName;
    switch (height) {
        case 480:
            imageName = @"LaunchImage-700@2x.png";
            break;
        case 568:
            imageName = @"LaunchImage-700-568h@2x.png";
            break;
        case 667:
            imageName = @"LaunchImage-800-667h@2x.png";
            break;
        case 736:
            imageName = @"LaunchImage-800-Portrait-736h@3x";
            break;
        default:
            imageName = @"LaunchImage-800-Portrait-736h@3x.png";
            
            break;
    }
    initViewBg.image = [UIImage imageNamed:imageName];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [initView addSubview:activityIndicatorView];
    
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* acViews = NSDictionaryOfVariableBindings(activityIndicatorView);
    //设置高度
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[activityIndicatorView]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:acViews]];
   // 上面的代码可以让prgrssView 水平居中。垂直代码如下
    [initView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[activityIndicatorView]-380-|" options:NSLayoutFormatAlignAllTop metrics:nil views:acViews]];
    [activityIndicatorView startAnimating];
}

- (void)deviceInit
{
    __weak MainViewController *weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ServerVisit userInitWithUserid:[SvUDIDTools UDID] uactype:@"0" uregtype:@"3" ulogindev:@"3" upushtoken:[ServerVisit shead].deviceToken completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
            if (!error) {
                NSDictionary *dict = (NSDictionary*)responseData;
                if ([[dict objectForKey:@"code"] integerValue] == 200) {
                    [ServerVisit shead].authorization = [dict objectForKey:@"authorization"];
                    [weakSelf getData];
                }else{
                    
                }
            }else{
                
            }
        }];
    });
}

- (void)getData
{
    __weak MainViewController *weakSelf = self;
    [ServerVisit getRoomListWithSign:[ServerVisit shead].authorization withPageNum:1 withPageSize:20 completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        if (!error) {
            NSDictionary *dict = (NSDictionary*)responseData;
            if ([[dict objectForKey:@"code"] integerValue] == 200) {
                RoomVO *roomVO = [[RoomVO alloc] initWithParams:[dict objectForKey:@"meetingList"]];
                if (roomVO.deviceItemsList.count!=0) {
                    [weakSelf.dataArray addObjectsFromArray:roomVO.deviceItemsList];
                }
                [weakSelf.roomList reloadData];
                UIView *initView = [[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:400];
                if (initView) {
                    [UIView animateWithDuration:0.3 animations:^{
                        initView.alpha = 0.0;
                    }completion:^(BOOL finished) {
                        [initView removeFromSuperview];
                    }];
                }
            }else{
                
            }
        }else{
            
        }
    }];
}

- (void)setBackGroundImageView
{
    UIImageView *bgImageView = [[UIImageView alloc] init];
    [self.view addSubview:bgImageView];
    bgImageView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(bgImageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[bgImageView]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bgImageView]-0-|" options:NSLayoutFormatAlignmentMask metrics:nil views:views]];
    
    int height = CGRectGetHeight(self.view.bounds);
    
    NSString *imageName;
    switch (height) {
        case 480:
            imageName = @"blackimg-Default@2x.png";
            break;
        case 568:
            imageName = @"blackimg-Default-568h@2x.png";
            break;
        case 667:
            imageName = @"blackimg-Default-667h@2x.png";
            break;
        case 736:
            imageName = @"blackimg-Default-736h@3x.png";
            break;
        default:
            imageName = @"blackimg-Default-736h@3x.png";
            
            break;
    }
    bgImageView.image = [UIImage imageNamed:imageName];
//    UIImageView *bg = [[UIImageView alloc] initWithFrame:bgImageView.bounds];
//    [bgImageView addSubview:bg];
//    bg.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:90.0/255.0 blue:97.0/255.0 alpha:.6];
//    
//    [bgImageView setImageToBlur:[UIImage imageNamed:imageName]
//                                                blurRadius:30
//                                           completionBlock:^(){
//     
//                                           }];
    
  
}

-(void)displaySMSComposerSheet:(NSString*)roomID
{
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate =self;
    NSString *smsBody =[NSString stringWithFormat:@"Let's meet on room now! https://anyrtc.io/#%@",roomID];
    
    picker.body=smsBody;
    
    [self presentViewController:picker animated:YES completion:^{
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}



#pragma mark - button events
- (void)getRoomButtonEvent:(UIButton*)button
{
    
    if (self.roomList.isEditing) {
        self.roomList.editing = NO;
    }
    [self.getRoomView showGetRoomView];
    
    RoomItem *roomItem = [[RoomItem alloc] init];
    [dataArray insertObject:roomItem atIndex:0];
    // 先把数据添加上，在搞下面的
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [indexPaths addObject: indexPath];
    
    [self.roomList beginUpdates];
    
    [self.roomList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
}
// 点击取消无用，做此判断
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];    //返回与当前接收者有关的所有的触摸对象
    UITouch *touch = [allTouches anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]];
    if (CGRectContainsPoint(self.cancleButton.frame, point)) {
        [self cancleButtonEvent:self.cancleButton];
    }
}

- (void)cancleButtonEvent:(UIButton*)button
{
    if (self.getRoomView) {
        [self.getRoomView dismissView];
    }
}
#pragma mark - publish server methods
- (void)updataDataWithServerResponse:(NSDictionary*)dict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RoomItem *roomItem = [dataArray objectAtIndex:0];
        roomItem.roomID = [dict objectForKey:@"meetingid"];
        roomItem.jointime = [[dict objectForKey:@"jointime"] longValue];
        roomItem.mettingType = [[dict objectForKey:@"meettype"] integerValue];
        roomItem.mettingState = [[dict objectForKey:@"meetusable"] integerValue];
        
        [dataArray replaceObjectAtIndex:0 withObject:roomItem];
        [self.roomList reloadData];
    });
}
// 添加
- (void)addRoomWithRoomName:(NSString*)roomName
{
    RoomItem *roomItem = [dataArray objectAtIndex:0];
    roomItem.roomName = roomName;
    
    [dataArray replaceObjectAtIndex:0 withObject:roomItem];
    [self.roomList reloadData];
    
    // 显示设置项目
    if (self.push) {
        [self.push showWithType:PushViewTypeDefault withObject:roomItem withIndex:0];
    }
    self.cancleButton.hidden = YES;
    
    __weak MainViewController *weakSelf = self;
    // 上传信息
    [ServerVisit applyRoomWithSign:[ServerVisit shead].authorization mettingId:roomItem.roomID mettingname:roomItem.roomName mettingCanPush:roomItem.canNotification mettingtype:@"0" mettingdesc:@"" completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"create room");
        NSDictionary *dict = (NSDictionary*)responseData;
        if (!error) {
            if ([[dict objectForKey:@"code"] intValue]== 200) {
                [weakSelf updataDataWithServerResponse:[dict objectForKey:@"meetingInfo"]];
                
            }
        }
    }];
}

// 更新名字
- (void)addTempDeleteData:(NSString*)roomName
{
    // 更改一下对象
    RoomItem *roomItem = [dataArray objectAtIndex:0];
    roomItem.roomName = roomName;
    [dataArray replaceObjectAtIndex:0 withObject:roomItem];
    
    
    // 先把数据添加上，在搞下面的
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (NSInteger i = tempDataArray.count-1; i>-1; i--) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject: indexPath];
        // 把之前删除的数据加上
        RoomItem *item = [tempDataArray objectAtIndex:i];
        [dataArray insertObject:item atIndex:0];
    }
    
    
    [self.roomList beginUpdates];
    
    [self.roomList insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
    [ServerVisit updatateRoomNameWithSign:[ServerVisit shead].authorization mettingID:roomItem.roomID mettingName:roomName completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"updata name");
    }];
}
// 删除room
- (void)deleteRoomWithItem:(RoomItem*)item withIndex:(NSInteger)index
{
    [dataArray removeObject:item];
    // 先把数据添加上，在搞下面的
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:index inSection:0];
    
    [indexPaths addObject: indexP];
    
    [self.roomList beginUpdates];
    
    [self.roomList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
    [ServerVisit deleteRoomWithSign:[ServerVisit shead].authorization meetingID:item.roomID completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"delete room");
    }];
}
// 更新推送与否
- (void)updateNotification:(RoomItem*)item withClose:(BOOL)close withIndex:(NSInteger)index
{
    [dataArray replaceObjectAtIndex:index withObject:item];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexP = [NSIndexPath indexPathForRow:index inSection:0];
    
    [indexPaths addObject: indexP];
    
    [self.roomList beginUpdates];
    
    [self.roomList reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.roomList endUpdates];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.roomList reloadData];
    });
    
    
    [ServerVisit updateRoomPushableWithSign:[ServerVisit shead].authorization meetingID:item.roomID pushable:[NSString stringWithFormat:@"%d",close] completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
        NSLog(@"open or close push");
    }];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RoomViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRoomCellID forIndexPath:indexPath];
    cell.delegate = self;
    cell.parIndexPath = indexPath;
    [cell setItem:[dataArray objectAtIndex:indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        VideoCallViewController *video = [[VideoCallViewController alloc] init];
        video.roomItem = [dataArray objectAtIndex:indexPath.row];
        UINavigationController *nai = [[UINavigationController alloc] initWithRootViewController:video];
        [self presentViewController:nai animated:YES completion:^{
            
        }];
    });
 
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
  //当在Cell上滑动时会调用此函数
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return  UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RoomItem *deleteItem = [dataArray objectAtIndex:indexPath.row];
    [self deleteRoomWithItem:deleteItem withIndex:indexPath.row];
    
}
-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath
{
    return @"删除";
}

#pragma mark - RoomViewCellDelegate
- (void)roomViewCellDlegateSettingEvent:(NSInteger)index
{
    if (self.roomList.isEditing) {
        return;
    }
    RoomItem *roomItem = [dataArray objectAtIndex:index];
    
   [self.push showWithType:PushViewTypeSetting withObject:roomItem withIndex:index];
}

#pragma mark - GetRoomViewDelegate

- (void)showCancleButton//显示 button
{
   self.cancleButton.hidden = NO;
}

- (void)getRoomWithRoomName:(NSString*)roomName
{
    [self addRoomWithRoomName:roomName];
    
}
- (void)cancleGetRoom
{
    [dataArray removeObjectAtIndex:0];
    // 先把数据添加上，在搞下面的
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [indexPaths addObject: indexPath];
    
    [self.roomList beginUpdates];
    
    [self.roomList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    
    [self.roomList endUpdates];
    
     self.cancleButton.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [self.roomList reloadData];
    });
}

- (void)renameRoomNameScuess:(NSString*)roomName
{
    [self addTempDeleteData:roomName];
    self.cancleButton.hidden = YES;
    
}

// 取消更改名字
- (void)cancleRename:(NSString*)oldName
{
    [self addTempDeleteData:oldName];
     self.cancleButton.hidden = YES;
}


#pragma mark - PushViewDelegate
- (void)pushViewInviteViaMessages:(RoomItem*)obj
{
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
        // Check whether the current device is configured for sending SMS messages
        if ([messageClass canSendText]) {
            
            [self displaySMSComposerSheet:obj.roomID];
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""message:@"设备不支持短信功能" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

- (void)pushViewInviteViaWeiXin:(RoomItem*)obj
{
    
}
- (void)pushViewInviteViaLink:(RoomItem*)obj
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"www.baidu.com";
    [ASHUD showHUDWithCompleteStyleInView:self.view content:@"拷贝成功" icon:@"messageInvite"];
}

- (void)pushViewJoinRoom:(RoomItem*)obj
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        VideoCallViewController *video = [[VideoCallViewController alloc] init];
        video.roomItem = obj;
        UINavigationController *nai = [[UINavigationController alloc] initWithRootViewController:video];
        [self presentViewController:nai animated:YES completion:^{
        }];
    });
}
- (void)pushViewCloseOrOpenNotifications:(RoomItem *)obj withOpen:(BOOL)isOpen withIndex:(NSInteger)index
{
    [self updateNotification:obj withClose:isOpen withIndex:index];
}

- (void)pushViewRenameRoom:(RoomItem*)obj
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.roomList.isEditing) {
            self.roomList.editing = NO;
        }
        if (tempDataArray.count!=0) {
            [tempDataArray removeAllObjects];
        }
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i<dataArray.count; i++ ) {
            RoomItem *item = [dataArray objectAtIndex:i];
            if (item != obj) {
                [tempDataArray addObject:item];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }else{
                break;
            }
            
        }
        [dataArray removeObjectsInArray:tempDataArray];
        
        [self.roomList beginUpdates];
        
        [self.roomList deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        
        [self.roomList endUpdates];
        
        [self.getRoomView showWithRenameRoom:obj.roomName];
    });
    
    
}
- (void)pushViewDelegateRoom:(RoomItem*)obj withIndex:(NSInteger)index
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self deleteRoomWithItem:obj withIndex:index];
    });
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"短信发送成功" icon:nil];
    }else{
        [controller dismissViewControllerAnimated:YES completion:nil];
        [ASHUD showHUDWithCompleteStyleInView:self.view content:@"短信发送失败" icon:nil];
    }
    
}

#pragma mark - 监听网络状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_netType"]){
        NSInteger type = [[change valueForKey:NSKeyValueChangeNewKey] integerValue];
        NSLog(@"observeValueForKeyPath:%ld",(long)type);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (type!=NoNet) {
                if ([[ServerVisit shead].authorization isEqualToString:@""]) {
                    [self deviceInit];
                }else{
                     UIView *initView = [[UIApplication sharedApplication].keyWindow.rootViewController.view viewWithTag:400];
                    if (initView) {
                        [self getData];
                    }else{
                        if (self.netAlertView) {
                            [self.netAlertView dismiss];
                            self.netAlertView = nil;
                        }
                    }
                }
            }else{
                if (!self.netAlertView) {
                    self.netAlertView = [[RoomAlertView alloc] initType:AlertViewNotNetType];
                    [self.netAlertView show];
                }
                
            }
        });
        
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (ISIPAD) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    }else{
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    
}

- (BOOL)shouldAutorotate
{
    if (ISIPAD) {
        return YES;
    }else{
        return NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (ISIPAD) {
        return UIInterfaceOrientationMaskAll;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
    
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
