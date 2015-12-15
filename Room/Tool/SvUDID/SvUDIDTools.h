//
//  SvUDIDTools.h
//  SvUDID
//
//  Created by  maple on 8/18/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
// 该类不是ARC机制的，所以-fno-objc-arc
@interface SvUDIDTools : NSObject


/*
 * @brief obtain Unique Device Identity
 */
+ (NSString*)UDID;

@end
