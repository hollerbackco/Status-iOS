//
//  STConstants.h
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <Foundation/Foundation.h>

#if ENTERPRISE
#define kSTisEnterpriseBuild 1
#else
#define kSTisEnterpriseBuild 0
#endif

#define kSTAmazonS3AccessKeyID @"AKIAIRGS2GLW2KC6JVKQ"
#define kSTAmazonS3SecretKey @"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"
#define kSTAmazonS3LogBucket @"st-ios-logs"
#define kSTTransferManagerTimeout 30.0


@interface STConstants : NSObject

@end
