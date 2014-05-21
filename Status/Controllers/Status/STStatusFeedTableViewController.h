//
//  STStatusFeedTableViewController.h
//  Status
//
//  Created by Joe Nguyen on 20/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

@interface STStatusFeedTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *statuses;

#pragma mark - Fetch

- (void)performFetchWithCachePolicy:(PFCachePolicy)cachePolicy;

@end
