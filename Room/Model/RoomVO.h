//
//  RoomVO.h
//  Room
//
//  Created by zjq on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface RoomItem:NSObject
@property (nonatomic, strong) NSString *roomName;           // 会议名字
@property (nonatomic, strong) NSString *roomID;             // 会议id
@property (nonatomic, strong) NSString *userID;             // 会议创建者
@property (nonatomic, strong) NSString *canNotification;    // 是否可以推送
@property (nonatomic, assign) long jointime;                // 开会时间
@property (nonatomic, strong) NSString *mettingNum;         // 入会人员
@property (nonatomic, assign) NSInteger mettingType;        // 会议类型
@property (nonatomic, strong) NSString *mettingDesc;        // 会议描述
@property (nonatomic, assign) NSInteger mettingState;       // 会议状态  0:不可用  1：可用   2：私密会议
@property (nonatomic, assign) BOOL isOwn;                   // 是否属于自己  1：是自己的会议  0：他人的会议室


- (id)initWithParams:(NSDictionary *)params;
@end

@interface RoomVO : NSObject

@property (nonatomic, strong) NSMutableArray *deviceItemsList;

- (id)initWithParams:(NSArray *)params;

@end
