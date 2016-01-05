//
//  RoomApp.m
//  Room
//
//  Created by zjq on 15/12/31.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "RoomApp.h"

@implementation RoomApp
static RoomApp *roomApp = nil;
+(RoomApp*)shead
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        roomApp = [[RoomApp alloc] init];
    });
    return roomApp;
}

@end
