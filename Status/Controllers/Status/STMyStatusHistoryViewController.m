//
//  STMyStatusHistoryViewController.m
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <RACEXTScope.h>

#import "UIViewController+JNHelper.h"
#import "JNAlertView.h"

#import "STMyStatusHistoryViewController.h"
#import "STStatusHistoryTableViewCell.h"

#import "STStatusHistory.h"

@interface STMyStatusHistoryViewController ()

@property (nonatomic, strong) NSArray *statusHistory;
@property (strong, nonatomic) UIActivityIndicatorView *tableSpinnerView;

@end

@implementation STMyStatusHistoryViewController

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
    
    PFQuery *query = [PFQuery queryWithClassName:@"StatusHistory"];
    query.cachePolicy = cachePolicy;
    
    if ((cachePolicy == kPFCachePolicyCacheThenNetwork ||
         cachePolicy == kPFCachePolicyCacheElseNetwork ||
         cachePolicy == kPFCachePolicyCacheOnly) &&
        !query.hasCachedResult) {
        
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
#warning Todo: remove this when all users have upgraded to 0.2.7+
    [query whereKeyExists:@"statusId"];
    
    [query orderByDescending:@"createdAt"];
    
    query.limit = 10;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            JNLogObject(error);
            [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem getting statuses. Please try again."];
            
        } else {
            
            JNLogObject(objects);
            self.statusHistory = [self sortedStatues:objects];
            
            [self reloadTableView];
        }
        
        [self.tableSpinnerView stopAnimating];
        [UIView animateWithBlock:^{
            self.tableSpinnerView.alpha = 0.0;
        }];
        
        self.refreshControl.enabled = YES;
    }];
    
    [self.refreshControl endRefreshing];
}

- (NSArray*)sortedStatues:(NSArray*)statuses
{
    return [statuses sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        STStatusHistory *status1 = (STStatusHistory*) obj1;
        STStatusHistory *status2 = (STStatusHistory*) obj2;
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

- (void)reloadTableView
{
    JNLog();
    [self.tableView reloadData];
}

#pragma mark - Views

static NSString *CellIdentifier = @"STStatusHistoryTableViewCell";

- (void)viewDidLoad
{
    JNLog();
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    self.tableSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.tableSpinnerView.center = CGPointMake(self.tableView.bounds.size.width/2, 120.0);
    [self.tableView addSubview:self.tableSpinnerView];
    [self.tableSpinnerView startAnimating];
    
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self setupRefreshControl];
}

- (void)setupNavigationBar
{
    [self applyRightCameraNavigationButtonWithTarget:self action:@selector(cameraAction:)];
}

- (void)setupRefreshControl
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(performFetchWithNetworkOnlyCachePolicy) forControlEvents:UIControlEventValueChanged];
    
    [self setRefreshControl:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    JNLog();
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    [self performFetchWithCachePolicy:kPFCachePolicyCacheThenNetwork];
}

#pragma mark - Actions

- (void)cameraAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statusHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STStatusHistory *statusHistory = self.statusHistory[indexPath.row];
    
    STStatusHistoryTableViewCell *cell = (STStatusHistoryTableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    @weakify(cell);
//    [STStatusHistory object:status fetchSenderNameCompleted:^(NSString *senderName) {
//        
//        runOnMainQueue(^{
//            
//            cell_weak_.senderName = senderName;
//        });
//    }];
    
    cell.senderName = nil;
    
    PFFile *imageFile = statusHistory[@"image"];
    if (imageFile) {
        
        cell.photoImageURL = [NSURL URLWithString:imageFile.url];
    }
    
    [cell fetchStatusCommentsWithStatusHistory:statusHistory];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.didSelectStatus) {
//        
//        STStatus *status = [self.statuses objectAtIndex:indexPath.row];
//        self.didSelectStatus(status);
//    }
}

@end
