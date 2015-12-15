//
//  ServerVisit.m
//  Room
//
//  Created by yangyang on 15/12/4.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "ServerVisit.h"
#import "NetRequestUtils.h"
@implementation ServerVisit
- (id)init
{
    self = [super init];
    if (self) {
        self.deviceToken = @"";
        self.authorization = @"";
    }
    return self;
}
static ServerVisit *_server = nil;
+ (ServerVisit*)shead
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _server = [[ServerVisit alloc] init];
    });
    return _server;
}


+ (void)userInitWithUserid:(NSString *)uid uactype:(NSString *)utype uregtype:(NSString *)gtype ulogindev:(NSString *)ltype upushtoken:(NSString *)token completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:uid,@"userid",utype,@"uactype",gtype,@"uregtype",ltype,@"ulogindev",token,@"upushtoken", nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"users/init" withRequestType:PostType parameters:parameters completion:completion];
}
+ (void)applyRoomWithSign:(NSString *)gn mettingId:(NSString*)mid mettingname:(NSString *)mname mettingCanPush:(NSString*)pushNum mettingtype:(NSString *)mtype mettingdesc:(NSString *)mdesc completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",mname,@"meetingname",mtype,@"meetingtype",mdesc,@"meetdesc",mid,@"meetingid",pushNum,@"pushable", nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/applyRoom" withRequestType:PostType parameters:parameters completion:completion];
}

+ (void)updatateRoomNameWithSign:(NSString*)gn mettingID:(NSString*)mid mettingName:(NSString*)mname completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",mname,@"meetingname",mid,@"meetingid", nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/updateMeetRoomName" withRequestType:PostType parameters:parameters completion:completion];
}

+ (void)updateDeviceTokenWithSign:(NSString*)gn withToken:(NSString*)token completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",token,@"upushtoken",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"users/updatePushtoken" withRequestType:PostType parameters:parameters completion:completion];
}

+ (void)deleteRoomWithSign:(NSString *)gn meetingID:(NSString *)mid completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",mid,@"meetingid",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/deleteRoom" withRequestType:PostType parameters:parameters completion:completion];
    
}

+ (void)addMemRoomWithSign:(NSString *)gn meetingID:(NSString *)mid completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",mid,@"meetingid",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/updateRoomAddMemNumber" withRequestType:PostType parameters:parameters completion:completion];
}

+ (void)reduceMemRoomWithSign:(NSString *)gn meetingID:(NSString *)mid completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",mid,@"meetingid",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/updateRoomMinuxMemNumber" withRequestType:PostType parameters:parameters completion:completion];
}

+ (void)updateRoomPushableWithSign:(NSString *)gn meetingID:(NSString *)mid pushable:(NSString *)able completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",mid,@"meetingid",able,@"pushable",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/updateRoomPushable" withRequestType:PostType parameters:parameters completion:completion];
    
}

+ (void)updateRoomEnableWithSign:(NSString *)gn meetingID:(NSString *)mid enable:(NSString *)able completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",mid,@"meetingid",able,@"enable",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/updateRoomEnable" withRequestType:PostType parameters:parameters completion:completion];
    
}
+ (void)getRoomListWithSign:(NSString *)gn
                withPageNum:(int)pageNum
               withPageSize:(int)pageSize
                 completion:(void (^)(AFHTTPRequestOperation *operation ,id responseData,NSError *error))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",[NSString stringWithFormat:@"%d",pageNum],@"pageNum",[NSString stringWithFormat:@"%d",pageSize],@"pageSize",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"meeting/getRoomList" withRequestType:PostType parameters:parameters completion:completion];
}


+ (void)signoutRoomWithSign:(NSString *)gn completion:(void (^)(AFHTTPRequestOperation *, id, NSError *))completion {
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:gn,@"sign",nil];
    [NetRequestUtils requestWithInterfaceStrWithHeader:@"users/signout" withRequestType:PostType parameters:parameters completion:completion];
}

@end
