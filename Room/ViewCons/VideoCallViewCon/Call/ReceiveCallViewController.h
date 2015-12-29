//
//  ReceiveCallViewController.h
//  Dropeva
//
//  Created by zjq on 15/10/12.
//  Copyright © 2015年 zjq. All rights reserved.
//

#import "BaseViewController.h"
@interface ReceiveCallViewController : BaseViewController

@property (nonatomic, strong) NSString *roomID;

- (void)videoEnable:(BOOL)enable;
- (void)audioEnable:(BOOL)enable;

- (void)switchCamera; // switch camera
- (void)hangeUp;      // hunge up

- (void)sendMessageWithCmmand:(NSString *)cmd userID:(NSString *)userid;

@end
