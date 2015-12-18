//
//  NtreatedDataManage.m
//  Room
//
//  Created by yangyang on 15/12/18.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "NtreatedDataManage.h"
#import "SvUDIDTools.h"
@implementation NtreatedDataManage



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

@end
