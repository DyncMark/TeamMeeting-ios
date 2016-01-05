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
        self.mettingNum = @"0";
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


- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.roomName forKey:@"roomName"];
    [aCoder encodeObject:self.roomID forKey:@"roomID"];
    [aCoder encodeObject:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.canNotification forKey:@"canNotification"];
    [aCoder encodeInt:self.jointime forKey:@"jointime"];
    [aCoder encodeObject:self.mettingNum forKey:@"mettingNum"];
    [aCoder encodeInteger:self.mettingType forKey:@"mettingType"];
    [aCoder encodeObject:self.mettingDesc forKey:@"mettingDesc"];
    [aCoder encodeInteger:self.mettingState forKey:@"mettingState"];
    [aCoder encodeBool:self.isOwn forKey:@"isOwn"];
    
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init]) {
        
       _roomName = [aDecoder decodeObjectForKey:@"roomName"];
        _roomID = [aDecoder decodeObjectForKey:@"roomID"];
        _userID = [aDecoder decodeObjectForKey:@"userID"];
        _canNotification = [aDecoder decodeObjectForKey:@"canNotification"];
        _jointime = [aDecoder decodeIntForKey:@"jointime"];
        _mettingNum = [aDecoder decodeObjectForKey:@"mettingNum"];
        _mettingType = [aDecoder decodeIntegerForKey:@"mettingType"];
        _mettingDesc = [aDecoder decodeObjectForKey:@"mettingDesc"];
        _mettingState = [aDecoder decodeIntegerForKey:@"mettingState"];
        _isOwn = [aDecoder decodeBoolForKey:@"isOwn"];
        
    }
    return self;
    
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
