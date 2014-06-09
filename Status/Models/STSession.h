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
- (void)didNotAllowPermission;

@end

@interface STSession : NSObject

#pragma mark - Singleton

+ (STSession*)sharedInstance;

#pragma mark -

- (BOOL)isLoggedIn;
- (void)login:(id<STSessionDelegate>)delegate;
- (void)logout;

#pragma mark - Key Value store

- (void)setValue:(id)value forKey:(NSString*)key;

- (id)getValueForKey:(NSString*)key;

@end

