//
//  STOrientationManager.h
//  Status
//
//  Created by Joe Nguyen on 3/06/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STOrientationManager : NSObject

+ (STOrientationManager*)sharedInstance;

- (UIDeviceOrientation)currentDeviceOrientation;

- (void)beginGeneratingDeviceOrientationNotificationsCompleted:(void(^)())completed;

- (BOOL)isCorrectDeviceOrientation;

- (BOOL)isDeviceOrientationLandscapeLeft;

- (BOOL)isDeviceOrientationLandscapeRight;

- (void)showRotatePhoneViewInWindow:(UIWindow*)window;

@end
