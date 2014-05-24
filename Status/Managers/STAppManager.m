//
//  STAppManager.m
//  Status
//
//  Created by Joe Nguyen on 21/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <SWFSemanticVersion.h>

#import "JNAlertView.h"

#import "STAppManager.h"

@implementation STAppManager

+ (void)updateAppVersion
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSString *appVersion = [PFUser currentUser][@"appVersion"];
        if ([NSString isNotEmptyString:appVersion]) {
            
            SWFSemanticVersion *userVersion = [SWFSemanticVersion semanticVersionWithString:appVersion];
            SWFSemanticVersion *appVersion = [SWFSemanticVersion semanticVersionWithString:[self.class getAppVersion]];
            
            JNLogObject(userVersion);
            JNLogObject(appVersion);
            
            if ([userVersion compare:appVersion] == NSOrderedAscending) {
                
                currentUser[@"appVersion"] = [self.class getAppVersion];
                [currentUser saveEventually];
                
            }
            
        } else {
            
            currentUser[@"appVersion"] = [self.class getAppVersion];
            [currentUser saveEventually];
            
            [currentUser refresh];
            
        }
    }
}

+ (void)checkForUpdates
{
    // determine beta true or false (ie. enterprise build is beta, appstore is not beta)
    NSString *isBeta = nil;
    if (kSTisEnterpriseBuild) {
        isBeta = @"true";
    } else {
        isBeta = @"false";
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"AppVersion"];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        if (error) {
            
            [JNLogger logExceptionWithName:THIS_METHOD reason:@"countObjectsInBackgroundWithBlock" error:error];
            
        } else {
            
            if (number > 0) {
                
                PFQuery *query2 = [PFQuery queryWithClassName:@"AppVersion"];
                [query2 orderByDescending:@"updatedAt"];
                [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    
                    if (error) {
                        
                        [JNLogger logExceptionWithName:THIS_METHOD reason:@"getFirstObjectInBackgroundWithBlock" error:error];
                        
                    } else {
                        
                        NSString *releaseAppVersion = object[@"releaseAppVersion"];
                        if ([NSString isNotEmptyString:releaseAppVersion]) {
                            
                            BOOL shouldUpdate = [self.class isAppVersion:[self.class getAppVersion] earlierThanAppVersion:releaseAppVersion];
                            
                            if (shouldUpdate) {
                                
                                NSString *title = object[@"alertTitle"];
                                NSString *message = object[@"alertMessage"];
                                NSString *buttonText = object[@"alertButtonText"];
                                NSString *urlString = object[@"alertURL"];
                                NSURL *url = nil;
                                if ([NSString isNotEmptyString:urlString]) {
                                    url = [NSURL URLWithString:urlString];
                                }
                                [[self class] alertTitle:title message:message buttonText:buttonText url:url];
                            }
                            
                        } else {
                            
                        }
                    }
                }];
            } else {
                
                [JNLogger logExceptionWithName:THIS_METHOD reason:@"number == 0" error:error];
            }
        }
    }];
}

+ (BOOL)isAppVersion:(NSString*)appVersion1 earlierThanAppVersion:(NSString*)appVersion2
{
    SWFSemanticVersion *semVer1 = [SWFSemanticVersion semanticVersionWithString:
                                   [self.class normalizeAppVersion:appVersion1]];
    SWFSemanticVersion *semVer2 = [SWFSemanticVersion semanticVersionWithString:
                                   [self.class normalizeAppVersion:appVersion2]];
    return [semVer1 compare:semVer2] == NSOrderedAscending;
}

+ (NSString*)normalizeAppVersion:(NSString*)appVersion
{
    // strip any tailing full stops
    if ([[appVersion substringFromIndex:appVersion.length - 1] isEqualToString:@"."]) {
        appVersion = [appVersion stringByReplacingCharactersInRange:NSMakeRange(appVersion.length - 1, 1) withString:@""];
    }
    // suffix invalid schema versions with 0s
    NSArray *values = [appVersion componentsSeparatedByString:@"."];
    if ([NSArray isNotEmptyArray:values]) {
        if (values.count == 3) {
            return appVersion;
        } if (values.count == 2) {
            return [NSString stringWithFormat:@"%@.0", appVersion];
        } else if (values.count == 1) {
            return [NSString stringWithFormat:@"%@.0.0", appVersion];
        } else {
            return appVersion;
        }
    } else {
        return appVersion;
    }
}

+ (void)alertTitle:(NSString*)title
           message:(NSString*)message
          buttonText:(NSString*)buttonText
                 url:(NSURL*)url
{
    title = title ?: @"Updates available";
    message = message ?: @"Get the latest version!";
    buttonText = buttonText ?: @"OK";
    if ([NSString isNotEmptyString:message]) {
        
        JNAlertView *alertView =
        [JNAlertView
         showWithTitle:title
         body:message
         okAction:^{
             
             if (url && [url isKindOfClass:[NSURL class]]) {
                 [[UIApplication sharedApplication] openURL:url];
             }
         }
         okText:buttonText
         cancelAction:^{
             
             [alertView dismissWithClickedButtonIndex:1 animated:YES];
             
         } cancelText:@"Cancel"];
    }
}

@end
