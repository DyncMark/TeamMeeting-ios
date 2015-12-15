//
//  RTKPMPClient.m
//  AppRTCDemo
//
//  Created by EricTao on 15/6/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*! @brief 会议接口
 *
 *  @attention 会议的相关接口
 */
@class DyncM2MClient;

/*! @brief 会议接口处理结果回调
 *
 *  @attention 请保证在初始化入口里设置回调
 */
@protocol DyncM2MClientDelegate <NSObject>

/*! @brief 远程图像进入会议
 *
 *  @param remoteVideoTrack 远程图像通道
 *  @param strTag  通道标识符
 */
- (void)appClient:(DyncM2MClient *)client didReceiveRemoteVideoView:(UIView *)remoteVideoView withTag:(NSString *)strTag;

/*! @brief 远程图像离开会议
 *
 *  @param strTag  通道标识符
 */
- (void)appClient:(DyncM2MClient *)client didReceiveRemoteVideoViewLeaveWithTag:(NSString *)strTag;

/*! @brief 有人进入房间
 *
 *  @param userName  用户ID
 *  @param nickName  用户昵称
 */
- (void)appClient:(DyncM2MClient *)client didMemberInRoom:(NSString *)userID withNickName:(NSString*)nickName;

/*! @brief 有人离开房间
 *
 *  @param userID  用户ID
 *  @param nickName  用户昵称
 */
- (void)appClient:(DyncM2MClient *)client didMemberLeaveRoom:(NSString *)userID;


/*! @brief 初始化房间成功（自己进入会议）
 *  @param roomID 房间号
 */
- (void)appClientInRoomScuess:(DyncM2MClient *)client withRoomId:(NSString*)roomID;

/*! @brief 初始化房间失败（自己进入会议）
 */
- (void)appClientInRoomFaile:(DyncM2MClient *)client;

/*! @brief 发布自己成功(自己主动发布自己的回调)
 */
- (void)appClientPublishScuess:(DyncM2MClient *)client;

/*! @brief 离开房间(自己主动退出会议的回调)
 *
 *  @param info
 *  @param info （退会返回的信息）
 */
- (void)appClient:(DyncM2MClient *)client didReceiveLeaveRoomwithInfo:(NSString*)info;

/*! @brief 事件处理(会议室中成员的音频状态监听回调（当会议室或者P2P呼叫连接中的成员打开或者关闭音频时，该接口有回调信息）)
 *
 *  @param peerId  音频状态改变的成员的Id
 *  @param enable （音频的状态：YES：该peerId的音频已打开；NO：该peerId的音频已关闭；
 */
- (void)appClient:(DyncM2MClient *)client onRoomAudioStatus:(NSString*)peerId isEnable:(BOOL)enable;

/*! @brief 事件处理(会议室中成员的视频状态监听回调（当会议室或者P2P呼叫连接中的成员打开或者关闭视频时，该接口有回调信息）)
 *
 *  @param peerId  音频状态改变的成员的Id
 *  @param enable  视频的状态：YES：该peerId的视频已打开；NO：该peerId的视频已关闭
 */
- (void)appClient:(DyncM2MClient *)client onRoomVideoStatus:(NSString*)peerId isEnable:(BOOL)enable;

/*! @brief 通道打开(对方通道打开)
 *
 *  @param userID  用户的id
 */
- (void)appClient:(DyncM2MClient *)client OnChannelOpen:(NSString*)userID;
/*! @brief 通道关闭(对方通道关闭)
 *
 *  @param userID  用户的id
 */
- (void)appClient:(DyncM2MClient *)client OnChannelClose:(NSString*)userID;

/*! @brief 当前接收的数据大小
 *
 *  @param bytes 数据大小
 */
- (void)appClient:(DyncM2MClient *)client didReceiveBytes:(int)bytes;

/*! @brief 当前接收的文本消息
 *
 *  @param data 数据信息
 *  @param userID 用户的id
 */
- (void)appClient:(DyncM2MClient *)client didReceiveMessage:(NSString*)data withUser:(NSString*)userID;

/*! @brief 当视频大小变化的时候
 *
 *  @param videoView 视频窗口对象
 *  @param size 视频窗口大小
 */
- (void)appClient:(DyncM2MClient *)client videoView:(UIView*)videoView didChangeVideoSize:(CGSize)size;

@end

/*! @brief 会议接口函数类
 *
 * 该类封装了Dync 会议呼叫的的所有接口
 */
@interface DyncM2MClient : NSObject

@property (nonatomic, weak) UIView *localView;

@property (nonatomic, assign) BOOL videoEnable;  // 视频是否可用
/*! @brief 初始化接口
 *
 * @param delegate 代理（回调各种结果）
 * @param localVideoView 本地图像（摄像头图像）
 */
- (instancetype)initWithDelegate:(id<DyncM2MClientDelegate>)delegate;

/*! @brief 主动进入会议
 *
 * @param roomID 房间号（会议名字）
 * @param isPresenter 是否是主持人
 * @result (结果见回调)
 */
- (void)signInWithRoomId:(NSString*)roomID withIsPresenter:(BOOL)isPresenter;

/*! @brief 邀请进入会议
 *
 * @param roomID 房间号（会议名字）
 * @result (结果见回调)
 */
- (void)invateInWithRoomId:(NSString*)roomID;

/*! @brief 发布自己(如果是被邀请的人，不要手动发布)
 *
 * @result (结果见回调)
 */
- (void)publicMySelf;


/*! @brief 退出会议
 *
 *  @result (结果见回调)
 */
- (void)signOut;

/*! @brief 转换摄像头
 *
 */
- (void)switchCamear;

/*! @brief 打开或关闭本地音频
 *      默认是开启的
 *  @return 成功返回YES，失败返回NO。
 */
- (int)setLocalAudioEnable:(BOOL)enable;

/*! @brief 打开或关闭本地视频
 *      默认是开启的
 *  @return 成功返回YES，失败返回NO。
 */
- (int)setLocalVideoEnable:(BOOL)enable;

/*! @brief 发送自定义消息
 * @param message 消息json 字符串
 */
- (void)sendCustomMessage:(NSString *)message withPeerID:(NSString*)peerID;


@end
