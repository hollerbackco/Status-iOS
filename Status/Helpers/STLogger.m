//
//  STLogger.m
//  Status
//
//  Created by Joe Nguyen on 24/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <ReactiveCocoa.h>
#import <NSNotificationCenter+RACSupport.h>

#import "JNSimpleDataStore.h"

#import "STLogger.h"
#import "STTransferManager.h"

@implementation STLogger

#pragma mark - Singleton

+ (STLogger*)sharedInstance
{
    static STLogger *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark -

- (NSData*)getLast24hrErrorLogData
{
    NSArray *sortedLogFileInfos = [self.fileLogger.logFileManager sortedLogFileInfos];
    if ([NSArray isNotEmptyArray:sortedLogFileInfos]) {
        return [NSData dataWithContentsOfFile:((DDLogFileInfo*) sortedLogFileInfos.firstObject).filePath];
    }
    return nil;
}

- (NSString*)generateLogFileNameWithSuffix:(NSString*)suffix
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMdd";
    NSString *folderName = [dateFormatter stringFromDate:[NSDate date]];
    dateFormatter.dateFormat = @"yyyyMMdd-HHmm";

    // user id
    NSString *userIdStr = @"nil";
    if ([PFUser currentUser]) {
        userIdStr = [PFUser currentUser].objectId;
    }

    NSString *fileName = [NSString stringWithFormat:@"%@-%@%@",
                          [dateFormatter stringFromDate:[NSDate date]],
                          suffix && suffix.length > 0 ? [NSString stringWithFormat:@"%@-", suffix] : @"",
                          userIdStr];
    NSString *logFileName = [NSString stringWithFormat:@"logs/%@/%@.txt", folderName, fileName];
    return logFileName;
}

- (void)sendLogWithSuffix:(NSString*)suffix
{
    NSData *errorLogData = [self getLast24hrErrorLogData];
    NSString *logFileName = [self generateLogFileNameWithSuffix:suffix];
    [[STTransferManager sharedInstance].transferManager uploadData:errorLogData
                                                            bucket:kSTAWSS3LogBucket
                                                               key:logFileName];
}

- (void)sendLogWithSuffix:(NSString*)suffix completed:(void(^)())completed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *errorLogData = [self getLast24hrErrorLogData];
        NSString *logFileName = [self generateLogFileNameWithSuffix:suffix];
        
        @try {
            // transfer
            [[STTransferManager sharedInstance].transferManager
             synchronouslyUploadData:errorLogData
             bucket:kSTAWSS3LogBucket
             key:logFileName];
        }
        @catch (NSException *exception) {
            JNLogObject(exception);
        }
        !completed ?: completed();
    });
}

- (void)sendLogFile
{
    DDLogError(@"%@ %@\ncall stack: %@", THIS_FILE, THIS_METHOD, [NSThread callStackSymbols]);
    [self sendLogWithSuffix:nil];
}

- (void)sendLogFileWithParams:(NSDictionary*)params
{
    if (params)
        DDLogError(@"params: %@", params);
    [self sendLogFile];
}

- (void)sendCrashLogFile
{
    DDLogError(@"CRASH ERROR %@ %@\ncall stack: %@", THIS_FILE, THIS_METHOD, [NSThread callStackSymbols]);
    [self sendLogWithSuffix:@"CRASH"];
}

- (void)sendCrashLogFileWithParams:(NSDictionary*)params
{
    if (params)
        DDLogError(@"CRASH ERROR params: %@", params);
    [self sendCrashLogFile];
}

+ (void)sendDailyLog
{
    NSDate *lastDailyLogDate = (NSDate*) [JNSimpleDataStore getValueForKey:@"kSTDailyLogDateKey"];
    NSDate *now = [NSDate date];
    if ([NSDate isNotNullDate:lastDailyLogDate]) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar rangeOfUnit:NSDayCalendarUnit startDate:&lastDailyLogDate
                     interval:NULL forDate:lastDailyLogDate];
        [calendar rangeOfUnit:NSDayCalendarUnit startDate:&now
                     interval:NULL forDate:now];
        NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                                   fromDate:lastDailyLogDate toDate:now options:0];
        if (difference.day >= 1) {
            // past 24hrs since last log send, so send the latest log file
            [[STLogger sharedInstance] sendLogWithSuffix:@"daily"];
            // set the last daily log date
            [JNSimpleDataStore setValue:now forKey:@"kSTDailyLogDateKey"];
        }
    } else {
        // send latest log file
        [[STLogger sharedInstance] sendLogWithSuffix:@"daily"];
        // set the last daily log date
        [JNSimpleDataStore setValue:now forKey:@"kSTDailyLogDateKey"];
    }
}

+ (void)sendLogFileOnAppBackground
{
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                            object:nil]
      take:1]
     subscribeNext:^(NSNotification *note) {
         JNLog();
         UIBackgroundTaskIdentifier taskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
             JNLog(@"Background task is being expired.");
         }];
         // send log file to S3
         [[STLogger sharedInstance] sendLogWithSuffix:@"feedback" completed:^{
             [[UIApplication sharedApplication] endBackgroundTask:taskId];
         }];
     }];
}

@end
