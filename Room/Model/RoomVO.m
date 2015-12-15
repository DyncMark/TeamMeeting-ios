//
//  RoomVO.m
//  Room
//
//  Created by zjq on 15/11/17.
//  Copyright © 2015年 yangyangwang. All rights reserved.
//

#import "RoomVO.h"
#import "ToolUtils.h"
#import "TimeManager.h"

@implementation RoomItem
- (id)init{
    self = [super init];
    if (self) {
        self.roomID = @"";
        self.roomName = @"";
        self.canNotification = [self canPush];
        self.mettingState = 0;
        self.jointime = [[TimeManager shead] timeTransformationTimestamp];
    }
    return self;
}
- (id)initWithParams:(NSDictionary *)params{
    if (self = [super init]) {
        if (params) {
            self.roomID = [params valueForKey:@"meetingid"];
            self.roomName = [params valueForKey:@"meetname"];
            self.canNotification = [[params valueForKey:@"pushable"] stringValue];
            self.jointime = [[params valueForKey:@"jointime"] longValue];
            self.mettingDesc = [params valueForKey:@"meetdesc"];
            self.mettingNum = [[params valueForKey:@"memnumber"] stringValue];
            self.mettingType = [[params valueForKey:@"meettype"] integerValue];
            self.mettingState = [[params valueForKey:@"meetusable"] integerValue];
            self.userID = [params valueForKey:@"meetinguserid"];
            self.isOwn = [[params valueForKey:@"owner"] boolValue];
        }
    }
    return self;
}
- (NSString*)canPush
{
    if ([ToolUtils isAllowedNotification]) {
        return @"1";
    }else{
        return @"2";
    }
    return @"0";
}


@end

@implementation RoomVO
- (id)initWithParams:(NSArray *)params{
    if (self = [super init]) {
        if ([params count] > 0) {
            NSMutableArray *list = [[NSMutableArray alloc]initWithCapacity:1];
            for (NSInteger i=0; i<params.count; i++) {
                NSDictionary *itemsDict = [params objectAtIndex:i];
                if (itemsDict.allKeys.count!=0) {
                    RoomItem *item = [[RoomItem alloc] initWithParams:itemsDict];
                    [list addObject:item];
                }
            }
            self.deviceItemsList = list;
        }
    }
    return self;
}
@end
