//
//  STOrientationManager.m
//  Status
//
//  Created by Joe Nguyen on 3/06/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "STOrientationManager.h"

#import "UIView+JNHelper.h"
#import "UIColor+STHelper.h"

#import "STAppDelegate.h"

@interface STOrientationManager ()

@property (nonatomic) AVCaptureVideoOrientation orientation;

@property (nonatomic, strong) UIImageView *rotatePhoneImageView;

@end

@implementation STOrientationManager

+ (STOrientationManager*)sharedInstance
{
    static STOrientationManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (UIDeviceOrientation)currentDeviceOrientation
{
	return [[UIDevice currentDevice] orientation];
}

- (AVCaptureVideoOrientation)currentCaptureVideoOrientation
{
	UIDeviceOrientation deviceOrientation = [self currentDeviceOrientation];
    JNLogPrimitive(deviceOrientation);
	if (deviceOrientation == UIDeviceOrientationPortrait) {
		return AVCaptureVideoOrientationPortrait;
	} else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		return AVCaptureVideoOrientationPortraitUpsideDown;
	} else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
		return AVCaptureVideoOrientationLandscapeRight;
	} else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
		return AVCaptureVideoOrientationLandscapeLeft;
    } else {
        return AVCaptureVideoOrientationPortrait;
    }
}

- (void)beginGeneratingDeviceOrientationNotificationsCompleted:(void(^)())completed
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    if (completed) {
        completed();
    }
}

- (void)endGeneratingDeviceOrientationNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (void)deviceOrientationDidChange
{
    self.orientation = [self currentCaptureVideoOrientation];
    
    if (![self isCorrectDeviceOrientation]) {
        
        STAppDelegate *appDelegate = (STAppDelegate*) [UIApplication sharedApplication].delegate;
        
        [self showRotatePhoneViewInWindow:appDelegate.window];
    } else {
        
        [self hideRotatePhoneViewInWindow];
    }
}

- (BOOL)isCorrectDeviceOrientation
{
    return [self currentDeviceOrientation] == UIDeviceOrientationLandscapeLeft ||
    [self currentDeviceOrientation] == UIDeviceOrientationLandscapeRight ||
    [self currentDeviceOrientation] == UIDeviceOrientationFaceDown ||
    [self currentDeviceOrientation] == UIDeviceOrientationFaceUp;
}

- (BOOL)isDeviceOrientationLandscapeLeft
{
    return [self currentDeviceOrientation] == UIDeviceOrientationLandscapeLeft;
}

- (BOOL)isDeviceOrientationLandscapeRight
{
    return [self currentDeviceOrientation] == UIDeviceOrientationLandscapeRight;
}

- (void)showRotatePhoneViewInWindow:(UIWindow*)window
{
    if (!self.rotatePhoneImageView) {
        
        UIImage *rotatePhoneImage = [UIImage imageNamed:@"rotate-alert.png"];
        self.rotatePhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, rotatePhoneImage.size.width, rotatePhoneImage.size.height)];
        self.rotatePhoneImageView.image = rotatePhoneImage;
        self.rotatePhoneImageView.center = CGPointGetCenter(window.bounds);
        
        UIDeviceOrientation deviceOrientation = [self currentDeviceOrientation];
        switch (deviceOrientation) {
            case UIDeviceOrientationPortrait:
                self.rotatePhoneImageView.transform = CGAffineTransformMakeRotation(0.0);
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                self.rotatePhoneImageView.transform = CGAffineTransformMakeRotation(M_PI);
                break;
            default:
                break;
        }
        
        [window addSubview:self.rotatePhoneImageView];
    }
}

- (void)hideRotatePhoneViewInWindow
{
    if (self.rotatePhoneImageView) {
        [self.rotatePhoneImageView removeFromSuperview];
        self.rotatePhoneImageView = nil;
    }
}

@end
