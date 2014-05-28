//
//  STStatusFeedTableViewController.h
//  Status
//
//  Created by Joe Nguyen on 20/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STStatus.h"

@interface STStatusFeedTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, copy) void(^didSelectStatus)(STStatus *status);
@property (nonatomic, copy) void(^didTapShowShareActivityBlock)();

#pragma mark - Fetch

- (void)performFetchWithCachePolicy:(PFCachePolicy)cachePolicy;

@end
