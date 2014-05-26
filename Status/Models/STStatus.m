//
//  STStatus.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STStatus.h"

@implementation STStatus

+ (STStatus*)new
{
    return [super objectWithClassName:@"Status"];
}

+ (void)object:(PFObject*)object fetchSenderNameCompleted:(void(^)(NSString *senderName))completed
{
    NSString *senderName = object[@"senderName"];
    if ([NSString isNotEmptyString:senderName]) {
        
        if (completed) {
            completed(senderName);
        }
        
    } else {
        
        // old code
        PFUser *user = object[@"user"];
        if ([user isDataAvailable]) {
            
            if (completed) {
                completed(user[@"fbName"]);
            }
            
        } else {
            
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                if (completed) {
                    completed(object[@"fbName"]);
                }
            }];
        }
    }
}

@end
