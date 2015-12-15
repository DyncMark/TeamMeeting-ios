//
//  AvcAudioRouteMgr.h
//  DBing
//
//  Created by Tao Eric on 12-12-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AvcAudioRouteMgrDelegate <NSObject>
 @optional
- (void)audioManager:(id)menager plugginHeadset:(BOOL)bPluggin;
@end

@interface AvcAudioRouteMgr : NSObject {
 @private
    BOOL    _isSpeakerOn;
}

@property (atomic, readonly)BOOL _isSpeakerOn;
@property (nonatomic, assign) id<AvcAudioRouteMgrDelegate> delegate;

// 打开扬声器
- (void)setSpeakerOn;
// 关闭扬声器
- (void)setSpeakerOff;

@end
