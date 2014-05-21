//
//  STStatusFeedTableViewController.m
//  Status
//
//  Created by Joe Nguyen on 20/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIView+JNHelper.h"
#import "JNAlertView.h"

#import "STStatusFeedTableViewController.h"
#import "STStatus.h"
#import "STStatusTableViewCell.h"

@interface STStatusFeedTableViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *tableSpinnerView;

@end

@implementation STStatusFeedTableViewController

#pragma mark - Fetch

- (void)performFetch
{
    [UIView animateWithBlock:^{
        self.tableSpinnerView.alpha = 1.0;
    }];
    [self.tableSpinnerView startAnimating];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Status"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [self fetchFriendIdsCompleted:^(NSArray *friendIds, NSError *error) {
        
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"friendIds"] = friendIds;
        [currentUser saveEventually];
        
        NSString *currentUserFBId = currentUser[@"fbId"];
        JNLogObject(currentUserFBId);
        
        JNLogPrimitive(friendIds.count);
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
                JNLogObject(objects);
                self.statuses = objects;
                
                [self reloadTableView];
            }
            
            [self.tableSpinnerView stopAnimating];
            [UIView animateWithBlock:^{
                self.tableSpinnerView.alpha = 0.0;
            }];
        }];
    }];
    
    [self.refreshControl endRefreshing];
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
    self.tableSpinnerView.center = CGPointMake(self.tableView.bounds.size.width/2, self.tableView.bounds.size.height/2);
    [self.tableView addSubview:self.tableSpinnerView];
    [self.tableSpinnerView startAnimating];
    self.tableSpinnerView.alpha = 0.0;
    
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupRefreshControl];
}

- (void)setupRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(performFetch) forControlEvents:UIControlEventValueChanged];
    
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
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            cell.photoImage = image;
        } progressBlock:^(int percentDone) {
            ;
        }];
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
