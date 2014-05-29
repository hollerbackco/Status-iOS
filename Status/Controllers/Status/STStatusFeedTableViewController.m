//
//  STStatusFeedTableViewController.m
//  Status
//
//  Created by Joe Nguyen on 20/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <SDWebImageManager.h>
#import <RACEXTScope.h>

#import "UIView+JNHelper.h"
#import "UIFont+JNHelper.h"
#import "JNAlertView.h"

#import "STStatusFeedTableViewController.h"
#import "STStatusTableViewCell.h"

@interface STStatusFeedTableViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *tableSpinnerView;

@property (nonatomic) BOOL shouldDisplayExtraBottomCell;

@end

@implementation STStatusFeedTableViewController

#pragma mark - Fetch

- (void)performFetchWithNetworkOnlyCachePolicy
{
    JNLog();
    [self performFetchWithCachePolicy:kPFCachePolicyNetworkOnly];
}

- (void)performFetchWithCachePolicy:(PFCachePolicy)cachePolicy
{
    JNLog();
    self.refreshControl.enabled = NO;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Status"];
    query.cachePolicy = cachePolicy;
    
    [self fetchFriendIdsCompleted:^(NSArray *friendIds, NSError *error) {
        
        JNLogPrimitive(friendIds.count);
        
        PFUser *currentUser = [PFUser currentUser];
//        currentUser[@"friendIds"] = friendIds;
//        [currentUser saveEventually];
        
        NSString *currentUserFBId = currentUser[@"fbId"];
//        JNLogObject(currentUserFBId);
        
//        JNLogPrimitive(friendIds.count);
        if ([NSArray isNotEmptyArray:friendIds]) {
            
            NSMutableArray *allFriendIds = [friendIds mutableCopy];
            [allFriendIds insertObject:currentUserFBId atIndex:0];
            [query whereKey:@"userFBId" containedIn:allFriendIds];
            
        } else {
            
            [query whereKey:@"userFBId" equalTo:currentUserFBId];
        }
        
        [query includeKey:@"user"];
        
        if ((cachePolicy == kPFCachePolicyCacheThenNetwork ||
             cachePolicy == kPFCachePolicyCacheElseNetwork ||
             cachePolicy == kPFCachePolicyCacheOnly) &&
            !query.hasCachedResult) {
            
            query.cachePolicy = kPFCachePolicyNetworkOnly;
        }
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            runOnMainQueue(^{
                
                if (error) {
                    
                    JNLogObject(error);
                    [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem getting statuses. Please try again."];
                    
                } else {
//                    JNLogObject(objects);
                    self.statuses = [self sortedStatues:objects];
                    
                    runOnAsyncDefaultQueue(^{
                        [self predownloadStatusData];
                    });
                    
                    [self reloadTableView];
                    
                    self.shouldDisplayExtraBottomCell = YES;
                }
                
                [self.tableSpinnerView stopAnimating];
                [UIView animateWithBlock:^{
                    self.tableSpinnerView.alpha = 0.0;
                }];
                
                self.refreshControl.enabled = YES;
            });
        }];
    }];
    
    runOnMainQueue(^{
        [self.refreshControl endRefreshing];
    });
}

- (void)fetchFriendIdsCompleted:(void(^)(NSArray *friendIds, NSError *error))completed
{
    JNLog();
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSMutableArray *friendIds = nil;
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            JNLogPrimitive(friendObjects.count);
            
            friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
        } else {
            
            [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:error];
        }
        
        if (completed) {
            completed(friendIds, error);
        }
    }];
}

- (NSArray*)sortedStatues:(NSArray*)statuses
{
    return [statuses sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        STStatus *status1 = (STStatus*) obj1;
        STStatus *status2 = (STStatus*) obj2;
        NSDate *sentAt1 = status1[@"sentAt"];
        NSDate *sentAt2 = status2[@"sentAt"];
        NSDate *updatedAt1 = status1.updatedAt;
        NSDate *updatedAt2 = status2.updatedAt;
        
        NSComparisonResult result;
        if (sentAt1 && sentAt2) {
            
            result = [sentAt1 compare:sentAt2];
            
        } else if (sentAt1 && updatedAt2) {
            
            result = [sentAt1 compare:updatedAt2];
            
        } else if (updatedAt1 && sentAt2) {
            
            result = [updatedAt1 compare:sentAt2];
            
        } else {
            result = [updatedAt1 compare:updatedAt2];
        }
        
        return -result;
    }];
}

- (void)predownloadStatusData
{
    JNLog();
    if (self.statuses) {
        
        [self.statuses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            STStatus *status = (STStatus*) obj;
            PFFile *imageFile = status[@"image"];
            NSURL *imageURL = [NSURL URLWithString:imageFile.url];
            
            if (![[SDWebImageManager sharedManager] diskImageExistsForURL:imageURL]) {

                JNLog(@"predownloading: %@", imageURL);
                
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
                     
                     if (error) {
                         
                         [JNLogger logExceptionWithName:THIS_METHOD reason:nil error:error];
                     }
                 }];
            }
        }];
    }
}

- (void)reloadTableView
{
    JNLog();
    [self.tableView reloadData];
}

#pragma mark - Views

static NSString *CellIdentifier = @"STStatusTableViewCell";
static NSString *ExtraBottomCellIdentifier = @"ExtraBottomCellIdentifier";

- (void)viewDidLoad
{
    JNLog();
    [super viewDidLoad];
    
    self.tableSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.tableSpinnerView.center = CGPointMake(self.tableView.bounds.size.width/2, 120.0);
    [self.tableView addSubview:self.tableSpinnerView];
    [self.tableSpinnerView startAnimating];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:ExtraBottomCellIdentifier];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = self.statuses.count;
    if (self.shouldDisplayExtraBottomCell) {
        count++;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldDisplayExtraBottomCell && indexPath.row > self.statuses.count - 1) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ExtraBottomCellIdentifier];
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.attributedText =
        [[NSAttributedString alloc]
         initWithString:@"You have no more Statuses!\n\nTap to share the app with your friends."
         attributes:@{NSFontAttributeName: [UIFont primaryFontWithSize:20.0]}];
        
        return cell;
    }
    
    STStatus *status = self.statuses[indexPath.row];
    
    STStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    @weakify(cell);
    [STStatus object:status fetchSenderNameCompleted:^(NSString *senderName) {
        
        runOnMainQueue(^{
            
            cell_weak_.senderName = senderName;
        });
    }];
    
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
    if (self.shouldDisplayExtraBottomCell && indexPath.row > self.statuses.count - 1) {
        
        if (self.didTapShowShareActivityBlock) {
            self.didTapShowShareActivityBlock();
        }
        
    } else {
    
        if (self.didSelectStatus) {
            
            STStatus *status = [self.statuses objectAtIndex:indexPath.row];
            self.didSelectStatus(status);
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
