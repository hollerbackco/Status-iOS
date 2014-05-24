//
//  STTransferManager.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 22/10/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <AmazonS3Client.h>
#import <S3TransferManager.h>

@interface STTransferManager : NSObject

#pragma mark - Singleton

+ (STTransferManager*)sharedInstance;

#pragma mark -

@property (nonatomic, strong) AmazonS3Client *s3;
@property (nonatomic, strong) S3TransferManager *transferManager;

@end
