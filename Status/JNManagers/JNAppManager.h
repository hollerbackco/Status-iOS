//
//  JNAppManager.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 11/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kJNiPhoneHeight3_5inch 480.0

@interface JNAppManager : NSObject

+ (NSString*)getAppVersion;

+ (NSString*)modelName;

+ (BOOL)canUseFaceDetection;

+ (BOOL)deviceHasA4ChipOrSlower;

+ (BOOL)is3_5InchScreenSize;

+ (void)printAppState;

+ (void)printAppState:(UIApplication*)application;

@end
