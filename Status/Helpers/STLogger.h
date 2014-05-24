//
//  STLogger.h
//  Status
//
//  Created by Joe Nguyen on 24/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNLogger.h"

@interface STLogger : JNLogger

#pragma mark - Singleton

+ (STLogger*)sharedInstance;

#pragma mark - 

- (void)sendLogFile;
- (void)sendLogWithSuffix:(NSString*)filenamePrefix;
- (void)sendLogFileWithParams:(NSDictionary*)params;
- (void)sendCrashLogFile;
- (void)sendCrashLogFileWithParams:(NSDictionary*)params;
+ (void)sendDailyLog;

// this uses TransferManager without delegate callbacks
- (void)sendLogWithSuffix:(NSString*)suffix completed:(void(^)())completed;

+ (void)sendLogFileOnAppBackground;

@end
