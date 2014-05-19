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

@end

@interface STSession : NSObject

+ (BOOL)isLoggedIn;

+ (void)login:(id<STSessionDelegate>)delegate;

@end
