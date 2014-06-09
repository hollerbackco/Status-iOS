//
//  UIViewController+STShareActivity.m
//  Status
//
//  Created by Joe Nguyen on 9/06/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIViewController+STShareActivity.h"

@implementation UIViewController (STShareActivity)

- (void)showShareActivityView:(id)sender
{
    JNLog();
    NSString *string = @"Try out Status!";
    NSURL *URL = [NSURL URLWithString:@"http://thestatusapp.com"];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop,UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo];
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                     }];
}

@end
