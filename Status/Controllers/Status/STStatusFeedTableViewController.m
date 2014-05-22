//
//  STStatusFeedTableViewController.m
//  Status
//
//  Created by Joe Nguyen on 20/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIView+JNHelper.h"
#import "JNAlertView.h"

#import <SDWebImageManager.h>

#import "STStatusFeedTableViewController.h"
#import "STStatus.h"
#import "STStatusTableViewCell.h"

@interface STStatusFeedTableViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *tableSpinnerView;

@end

@implementation STStatusFeedTableViewController

#pragma mark - Fetch

- (void)performFetchWithNetworkOnlyCachePolicy
{
    [self performFetchWithCachePolicy:kPFCachePolicyNetworkOnly];
}

- (void)performFetchWithCachePolicy:(PFCachePolicy)cachePolicy
{
    self.refreshControl.enabled = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Status"];
    query.cachePolicy = cachePolicy;
    
    [self fetchFriendIdsCompleted:^(NSArray *friendIds, NSError *error) {
        
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"friendIds"] = friendIds;
        [currentUser saveEventually];
        
        NSString *currentUserFBId = currentUser[@"fbId"];
//        JNLogObject(currentUserFBId);
        
//        JNLogPrimitive(friendIds.count);
        if ([NSArray isNotEmptyArray:friendIds]) {
            
            NSMutableArray *allFriendIds = [friendIds mutableCopy];
            [allFriendIds insertObject:currentUserFBId atIndex:0];
            [query whereKey:@"userFBId" containedIn:allFriendIds];
            
            [query orderByDescending:@"updatedAt"];
            
        } else {
            
            [query whereKey:@"userFBId" equalTo:currentUserFBId];
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (error) {
                
                JNLogObject(error);
                [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem getting statuses. Please try again."];
                
            } else {
//                JNLogObject(objects);
                self.statuses = objects;
                
                runOnAsyncDefaultQueue(^{
                    [self predownloadStatusData];
                });
                
                [self reloadTableView];
            }
            
            [self.tableSpinnerView stopAnimating];
            [UIView animateWithBlock:^{
                self.tableSpinnerView.alpha = 0.0;
            }];
            
            self.refreshControl.enabled = YES;
        }];
    }];
    
    [self.refreshControl endRefreshing];
}

- (void)predownloadStatusData
{
    if (self.statuses) {
        [self.statuses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            STStatus *status = (STStatus*) obj;
            PFFile *imageFile = status[@"image"];
            NSURL *imageURL = [NSURL URLWithString:imageFile.url];
//            JNLogObject(imageURL);
            [[SDWebImageManager sharedManager]
             downloadWithURL:imageURL
             options:0
             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                 JNLog(@"receivedSize: %@    expectedSize: %@", @(receivedSize), @(expectedSize));
             }
             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//                 JNLogObject(image);
//                 JNLogObject(error);
//                 JNLogObject(@(cacheType));
             }];
        }];
    }
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

#pragma mark - Views

static NSString *CellIdentifier = @"STStatusTableViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.tableSpinnerView.center = CGPointMake(self.tableView.bounds.size.width/2, 120.0);
    [self.tableView addSubview:self.tableSpinnerView];
    [self.tableSpinnerView startAnimating];
    
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupRefreshControl];
}

- (void)setupRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(performFetchWithNetworkOnlyCachePolicy) forControlEvents:UIControlEventValueChanged];
    
    [self setRefreshControl:refreshControl];
}

#pragma mark - PFQueryTableViewController

- (void)fetchFriendIdsCompleted:(void(^)(NSArray *friendIds, NSError *error))completed
{
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSMutableArray *friendIds = nil;
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
        } else {
            
            JNLogObject(error);
        }
        if (completed) {
            completed(friendIds, error);
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STStatus *status = self.statuses[indexPath.row];
    
    STStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFUser *user = status[@"user"];
    if ([user isDataAvailable]) {
        
        cell.senderName = user[@"fbName"];
        
    } else {
        
        [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            cell.senderName = object[@"fbName"];
            
        }];
    }
    
    PFFile *imageFile = status[@"image"];
    if (imageFile) {
        
        cell.photoImageURL = [NSURL URLWithString:imageFile.url];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
