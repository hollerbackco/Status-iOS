//
//  STStatusFeedViewController.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STStatusFeedViewController.h"
#import "STStatusTableViewCell.h"
#import "STStatus.h"

@interface STStatusFeedViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, strong) NSNumber *didLoadFriendIds;
@property (nonatomic, strong) NSArray *friendIds;

@end

@implementation STStatusFeedViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"Status";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        
        self.didLoadFriendIds = @(NO);
    }
    return self;
}

#pragma mark - Views

static NSString *CellIdentifier = @"STStatusTableViewCell";

- (void)viewDidLoad
{
    self.title = @"Status";
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - PFQueryTableViewController

- (void)fetchFriendIdsCompleted:(void(^)(NSArray *friendIds))completed
{
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            if (completed) {
                completed(friendIds);
            }
        }
    }];
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
   
    if (!self.didLoadFriendIds.boolValue) {
        [self fetchFriendIdsCompleted:^(NSArray *friendIds) {
            
    //        // Construct a PFUser query that will find friends whose facebook ids
    //        // are contained in the current user's friend list.
    //        PFQuery *friendQuery = [PFUser query];
    //        [friendQuery whereKey:@"fbId" containedIn:friendIds];
    //        
    //        // findObjects will return a list of PFUsers that are friends
    //        // with the current user
    //        NSArray *friendUsers = [friendQuery findObjects];
    //        JNLogObject(friendUsers);
            
            self.friendIds = friendIds;
            
            self.didLoadFriendIds = @(YES);
            
            [self loadObjects];
        }];
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    if ([NSArray isNotEmptyArray:self.friendIds]) {
        
        NSMutableArray *allFriendIds = [self.friendIds mutableCopy];
        
        NSString *currentUserFBId = [PFUser currentUser][@"fbId"];
        JNLogObject(currentUserFBId);
        
        [allFriendIds insertObject:currentUserFBId atIndex:0];
        
        [query whereKey:@"userFBId" containedIn:allFriendIds];
        
        [query orderByDescending:@"updatedAt"];
        
        return query;
        
    } else {
        
        return nil;
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    STStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFFile *imageFile = object[@"image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *image = [UIImage imageWithData:data];
        cell.photoImage = image;
    } progressBlock:^(int percentDone) {
        ;
    }];
    
    PFUser *user = object[@"user"];
    if ([user isDataAvailable]) {
        
        cell.senderName = user[@"fbName"];
        
    } else {
        
        [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            cell.senderName = object[@"fbName"];
            
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
