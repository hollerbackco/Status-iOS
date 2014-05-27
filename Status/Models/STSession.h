//
//  STSession.h
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STSessionDelegate <NSObject>

@optional

- (void)didLogin:(BOOL)loggedIn;
- (void)didNotLogin;

@end

@interface STSession : NSObject

#pragma mark - Singleton

+ (STSession*)sharedInstance;

#pragma mark -

- (BOOL)isLoggedIn;
- (void)login:(id<STSessionDelegate>)delegate;

@end

