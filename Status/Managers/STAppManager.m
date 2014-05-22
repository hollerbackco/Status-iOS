//
//  STAppManager.m
//  Status
//
//  Created by Joe Nguyen on 21/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <SWFSemanticVersion.h>

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

@end
