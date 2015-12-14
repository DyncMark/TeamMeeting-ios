//
//  RoomAlertView.h
//  Room
//
//  Created by zjq on 15/12/8.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,AlertViewType) {
    AlertViewNotNetType = 0,
    AlertViewOpenNotificationType = 1,
};

@interface RoomAlertView : UIView

- (id)initType:(AlertViewType)type;

- (void)show;

- (void)dismiss;

@end
