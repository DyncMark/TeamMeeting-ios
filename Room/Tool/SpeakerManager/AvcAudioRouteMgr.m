//
//  AvcAudioRouteMgr.m
//  DBing
//
//  Created by Tao Eric on 12-12-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AvcAudioRouteMgr.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface AvcAudioRouteMgr()
- (BOOL)checkSpeakerOn;
- (BOOL)hasHeadset;
- (BOOL)hasMicphone;
- (void)resetOutputTarget;
@end

@implementation AvcAudioRouteMgr

@synthesize _isSpeakerOn;
@synthesize delegate;

- (id) init 
{
    self = [super init];
    if (self) {
        _isSpeakerOn = NO;
        // Set audio propety.
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *audioSessionError;
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&audioSessionError];  
        
        AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                        audioRouteChangeListenerCallbacks, (__bridge void *)(self));
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    
    return self;
}

- (void) dealloc
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange,audioRouteChangeListenerCallbacks,(__bridge void *)(self));
}

- (void)setSpeakerOn
{
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    _isSpeakerOn = [self checkSpeakerOn];
}

- (void)setSpeakerOff
{
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    _isSpeakerOn = [self checkSpeakerOn];
}

- (BOOL)checkSpeakerOn
{
    CFStringRef route; 
    UInt32 propertySize = sizeof(CFStringRef); 
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route); 
    
    if((route == NULL) || (CFStringGetLength(route) == 0))
    { 
        // Silent Mode 
        NSLog(@"AudioRoute: SILENT, do nothing!"); 
    } 
    else 
    { 
        NSString* routeStr = (__bridge NSString*)route; 
        NSRange speakerRange = [routeStr rangeOfString : @"Speaker"]; 
        if (speakerRange.location != NSNotFound) 
            return YES;
    }
    
    return NO;
}

- (BOOL)hasHeadset 
{
    CFStringRef route; 
    UInt32 propertySize = sizeof(CFStringRef); 
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route); 
           
    if((route == NULL) || (CFStringGetLength(route) == 0))
    { 
        // Silent Mode 
        NSLog(@"AudioRoute: SILENT, do nothing!"); 
    } 
    else 
    { 
        NSString* routeStr = (__bridge NSString*)route; 
        NSLog(@"AudioRoute: %@", routeStr); 

        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"]; 
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"]; 
        if (headphoneRange.location != NSNotFound) 
        { 
            return YES; 
        } else if(headsetRange.location != NSNotFound) 
        { 
            return YES; 
        } 
    } 
    return NO;
} 
- (void)erjiOutPutTarget
{
    BOOL hasHeadset = [self hasHeadset];
    NSLog (@"Will Set output target is_headset = %@ .", hasHeadset?@"YES":@"NO");
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

- (BOOL)hasMicphone 
{ 
    return [[AVAudioSession sharedInstance] inputIsAvailable]; 
}

- (void)resetOutputTarget 
{ 
    BOOL hasHeadset = [self hasHeadset]; 
    NSLog (@"Will Set output target is_headset = %@ .", hasHeadset?@"YES":@"NO"); 
    UInt32 audioRouteOverride = _isSpeakerOn ? kAudioSessionOverrideAudioRoute_Speaker:kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
} 

void audioRouteChangeListenerCallbacks (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueS, const void *inPropertyValue)
{ 
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) 
        return; 
    
    // Determines the reason for the route change, to ensure that it is not 
    // because of a category change. 
    CFDictionaryRef routeChangeDictionary = inPropertyValue; 
          
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason)); 
          
    SInt32 routeChangeReason;
          
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason); 
//    NSLog(@"<<<RouteChangeReason: %ld",routeChangeReason);
    
    AvcAudioRouteMgr *pMgr = (__bridge AvcAudioRouteMgr *)inUserData;
    //没有耳机
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
    {
        [pMgr resetOutputTarget];
        [pMgr setSpeakerOn];
    }
    else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable)
    {
        [pMgr erjiOutPutTarget];
    }else if (routeChangeReason == kAudioSessionRouteChangeReason_Override){
        [pMgr resetOutputTarget];
        [pMgr setSpeakerOn];
        
    }
    
//    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
//    {
//        if ([pMgr.delegate respondsToSelector:@selector(audioManager:plugginHeadset:)]) {
//            [pMgr.delegate audioManager:pMgr plugginHeadset:NO];
//        }
//        [pMgr resetOutputTarget];
////        if (![pMgr hasHeadset]) 
////        { 
////            [[NSNotificationCenter defaultCenter] postNotificationName:@"ununpluggingHeadse" object:nil]; 
////        } 
//    }
//    else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) 
//    { 
//        [pMgr resetOutputTarget];
////        if (![pMgr hasMicphone]) 
////        { 
////            [[NSNotificationCenter defaultCenter] postNotificationName:@"pluggInMicrophone" object:nil]; 
////        } 
//    }
////    else if (routeChangeReason == kAudioSessionRouteChangeReason_NoSuitableRouteForCategory) 
////    { 
////        [pMgr resetOutputTarget];
////        [[NSNotificationCenter defaultCenter] postNotificationName:@"lostMicroPhone" object:nil]; 
////    }
}

@end
