//
//  STTransferManager.m
//  HollerbackApp
//
//  Created by Joe Nguyen on 22/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import "STTransferManager.h"

@interface STTransferManager () <AmazonServiceRequestDelegate>

@property (nonatomic, strong) NSNumber *numberOfDownloads;

@end

@implementation STTransferManager

#pragma mark - Singleton

+ (STTransferManager*)sharedInstance
{
    static STTransferManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark -

- (id)init
{
    if (self = [super init]) {
        _s3 = [[AmazonS3Client alloc] initWithAccessKey:kSTAWSS3AccessKeyID withSecretKey:kSTAWSS3SecretKey];
        _s3.timeout = kSTTransferManagerTimeout;
        _s3.maxRetries = 1;
        _transferManager = [S3TransferManager new];
        _transferManager.s3 = self.s3;
        _transferManager.delegate = self;
    }
    return self;
}

#pragma mark - AmazonServiceRequestDelegate

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    JNLog();
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite {}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    JNLog();
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    JNLog();
}

@end
