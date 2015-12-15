//
//  PushView.h
//  DemoAnnitation
//
//  Created by yangyang on 15/11/3.
//  Copyright © 2015年 yangyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomVO.h"

typedef NS_ENUM(NSInteger, PushViewType) {
    PushViewTypeDefault = 0,                         // default type
    PushViewTypeSetting ,                            // setting type
};

@protocol PushViewDelegate <NSObject>
@required
- (void)pushViewInviteViaMessages:(RoomItem*)obj;
- (void)pushViewInviteViaWeiXin:(RoomItem*)obj;
- (void)pushViewInviteViaLink:(RoomItem*)obj;
- (void)pushViewJoinRoom:(RoomItem*)obj;
- (void)pushViewCloseOrOpenNotifications:(RoomItem*)obj withOpen:(BOOL)isOpen withIndex:(NSInteger)index;
- (void)pushViewRenameRoom:(RoomItem*)obj;
- (void)pushViewDelegateRoom:(RoomItem*)obj withIndex:(NSInteger)index;
@end


@interface PushView : UIView
@property (nonatomic, strong)RoomItem *roomItem;
@property (nonatomic, weak)id<PushViewDelegate>delegate;

- (void)showWithType:(PushViewType)type withObject:(id)object withIndex:(NSInteger)index;

@end
