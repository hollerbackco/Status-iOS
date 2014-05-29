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

#if DEV
#define kSTiSDevBuild 1
#else
#define kSTiSDevBuild 0
#endif


// PARSE

#if DEV

#define kSTParseAppId @"PgEz1FsFytOqz0gfWrR91qs11FkmE6i5pnd9VdIZ"
#define kSTParseClientKey @"NUfPm6IRKZxYd7CHxvKbCbuignEUH8RejLWTc0DY"

#else

#define kSTParseAppId @"OAawrd6K5rsKQWHGzh0cqtsVz8qnlMQvRewC8E8h"
#define kSTParseClientKey @"ANovqbeOyoQ17I6RSGSVTps3FIrWIj9k1jHkMl4R"

#endif


// AWS S3 

#define kSTAWSS3AccessKeyID @"AKIAIRGS2GLW2KC6JVKQ"
#define kSTAWSS3SecretKey @"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"
#define kSTTransferManagerTimeout 30.0

#if DEV

#define kSTAWSS3LogBucket @"st-ios-dev-logs"

#else 

#define kSTAWSS3LogBucket @"st-ios-logs"

#endif



// Key Value store keys

#define kSTSessionStoreHasNewComments @"kSTSessionStoreHasNewComments"








@interface STConstants : NSObject

@end
