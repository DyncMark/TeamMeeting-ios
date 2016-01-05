//
//  NtreatedDataManage.m
//  Room
//
//  Created by yangyang on 15/12/18.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "NtreatedDataManage.h"
#import "SvUDIDTools.h"
#import "ServerVisit.h"
@implementation NtreatedDataManage



+ (NtreatedDataManage *)sharedManager
{
    static NtreatedDataManage *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)addData:(NtreatedData *)data {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingPathComponent:@"roomlist.archiver"];
    NSMutableArray *datas = [self getData];
    if (!datas) {
        
        datas = [NSMutableArray array];
    }
    data.udid = [SvUDIDTools UDID];
    data.lastModifyDate = [NSDate new];
    [datas addObject:data];
    return [NSKeyedArchiver archiveRootObject:datas toFile:path];
}

- (BOOL)removeData:(NtreatedData *)data {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingPathComponent:@"roomlist.archiver"];
    NSMutableArray *datas = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!datas)
        return NO;
    for (int i = 0; i < [datas count]; i ++) {
        
        NtreatedData *item = [datas objectAtIndex:i];
        if ([item.udid isEqualToString:data.udid]) {
            
            [datas removeObject:item];
            return [NSKeyedArchiver archiveRootObject:datas toFile:path];
        }
        
    }
    return NO;
}

- (NSMutableArray *)getData {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingPathComponent:@"roomlist.archiver"];
    NSMutableArray *datas = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!datas)
        datas = [NSMutableArray new];
    
    return datas;
}

- (void)dealwithDataWithTarget:(id)target {
    
    NSMutableArray *datas = [self getData];
    [datas sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NtreatedData *item1 = obj1;
        NtreatedData *item2 = obj2;
        NSComparisonResult result = [item1.lastModifyDate compare:item2.lastModifyDate];
        if (result == NSOrderedAscending) {
            
            return NSOrderedAscending;
            
        } else {
            
            return NSOrderedDescending;
        }
        
    }];
    
    for (NtreatedData *item in datas) {
        
        RoomItem *roomItem = item.item;
        if (item.actionType == ModifyRoomName) {
        
            [ServerVisit updatateRoomNameWithSign:[ServerVisit shead].authorization mettingID:roomItem.roomID mettingName:roomItem.roomName completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
            }];
            
        } else if (item.actionType == CreateRoom){
            
            [ServerVisit applyRoomWithSign:[ServerVisit shead].authorization mettingId:roomItem.roomID mettingname:roomItem.roomName mettingCanPush:roomItem.canNotification  mettingtype:@"0" meetenable:item.isPrivate == YES ? @"private" : @"yes" mettingdesc:@"" completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
                
                NSDictionary *dict = (NSDictionary*)responseData;
                if (!error) {
                    if ([[dict objectForKey:@"code"] intValue]== 200) {
                
                        if ([target respondsToSelector:@selector(updataDataWithServerResponse:)]) {
                            [target performSelector:@selector(updataDataWithServerResponse:) withObject:[dict objectForKey:@"meetingInfo"]];
                        }
            
                    }
                }
            }];
            
        } else if (item.actionType == DeleteRoom) {
        
            [ServerVisit deleteRoomWithSign:[ServerVisit shead].authorization meetingID:roomItem.roomID completion:^(AFHTTPRequestOperation *operation, id responseData, NSError *error) {
            }];
        
        }
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingPathComponent:@"roomlist.archiver"];
    [NSKeyedArchiver archiveRootObject:[NSMutableArray new] toFile:path];
    
}

@end
