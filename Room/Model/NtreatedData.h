//
//  ntreatedData.h
//  Room
//
//  Created by yangyang on 15/12/18.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RoomVO.h"
typedef enum  ActionType {
    
    ModifyRoomName,
    CreateRoom,
    DeleteRoom,
    
} ActionType;

@interface NtreatedData : NSObject<NSCoding>


@property(nonatomic,retain)NSDate *lastModifyDate;
@property(nonatomic,assign)ActionType actionType;
@property(nonatomic,retain)RoomItem* item;
@property(nonatomic,assign)BOOL isPrivate;
@property(nonatomic,retain)NSString *udid;
@end
