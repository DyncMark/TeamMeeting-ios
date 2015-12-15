//
//  ServerVisit.h
//  Room
//
//  Created by yangyang on 15/12/4.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@interface ServerVisit : NSObject

+ (ServerVisit*)shead;

@property (nonatomic, strong) NSString *deviceToken;

@property (nonatomic, strong) NSString *authorization;  // 验证头信息


+ (void)userInitWithUserid:(NSString *)uid
                   uactype:(NSString *)utype
                  uregtype:(NSString *)gtype
                 ulogindev:(NSString *)ltype
                upushtoken:(NSString *)token
                completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)applyRoomWithSign:(NSString *)gn
                mettingId:(NSString*)mid
              mettingname:(NSString *)mname
           mettingCanPush:(NSString*)pushNum
              mettingtype:(NSString *)mtype
              mettingdesc:(NSString *)mdesc
               completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)updatateRoomNameWithSign:(NSString*)gn
                       mettingID:(NSString*)mid
                     mettingName:(NSString*)mname
                      completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)updateDeviceTokenWithSign:(NSString*)gn
                        withToken:(NSString*)token
                       completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)deleteRoomWithSign:(NSString *)gn
                 meetingID:(NSString *)mid
                completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)addMemRoomWithSign:(NSString *)gn
                 meetingID:(NSString *)mid
                completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)reduceMemRoomWithSign:(NSString *)gn
                    meetingID:(NSString *)mid
                   completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)updateRoomPushableWithSign:(NSString *)gn
                         meetingID:(NSString *)mid
                          pushable:(NSString *)able
                        completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)updateRoomEnableWithSign:(NSString *)gn
                         meetingID:(NSString *)mid
                          enable:(NSString *)able
                      completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)getRoomListWithSign:(NSString *)gn
                withPageNum:(int)pageNum
               withPageSize:(int)pageSize
                 completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

+ (void)signoutRoomWithSign:(NSString *)gn
                 completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion;

@end
