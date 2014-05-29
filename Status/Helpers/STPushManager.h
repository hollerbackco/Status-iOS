//
//  STPushManager.h
//  Status
//
//  Created by Joe Nguyen on 28/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STPushManager : NSObject

@property (nonatomic) BOOL willEnterFromPush;

#pragma mark - Singleton

+ (STPushManager*)sharedInstance;

#pragma mark -

- (void)handlePush:(NSDictionary*)userInfo;

@end
