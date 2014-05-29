//
//  STPushManager.m
//  Status
//
//  Created by Joe Nguyen on 28/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STPushManager.h"

@implementation STPushManager

#pragma mark - Singleton

+ (STPushManager*)sharedInstance
{
    static STPushManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - 

- (void)handlePush:(NSDictionary*)userInfo
{
    [PFPush handlePush:userInfo];
 
    self.willEnterFromPush = YES;
}

@end
