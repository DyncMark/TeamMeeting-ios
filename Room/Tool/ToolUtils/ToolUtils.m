//
//  ToolUtils.m
//  Room
//
//  Created by zjq on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "ToolUtils.h"
#import "UIDevice+Category.h"

@implementation ToolUtils
/**
 2  *  check if user allow local notification of system setting
 3  *
 4  *  @return YES-allowed,otherwise,NO.
 5  */
+ (BOOL)isAllowedNotification {
    //iOS8 check if user allow notification
    if ([UIDevice isSystemVersioniOS8]) {// system is iOS8
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }
    } else {//iOS7
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type)
            return YES;
    }
    
    return NO;
}
@end
