//
//  STFeedViewController.m
//  Status
//
//  Created by Nick Jensen on 6/4/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STFeedViewController.h"
#import "STFeedCell.h"
#import "STStatus.h"
#import "JNAlertView.h"
#import "STStatusCommentViewController.h"

@implementation STFeedViewController

@synthesize collectionView, refreshControl, statuses;

- (void)loadView {
    
    [super loadView];
    
    CGRect bounds = [[self view] bounds];
    
    UICollectionViewFlowLayout *layout;
    layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:0.0f];
    [layout setMinimumInteritemSpacing:0.0f];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setItemSize:STFeedCellSize];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.collectionView registerClass:[STFeedCell class] forCellWithReuseIdentifier:STFeedCellIdent];
    [self.collectionView setAlwaysBounceVertical:YES];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.view addSubview:self.collectionView];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(handlePullToRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self loadDataFromServer];
}

- (void)handlePullToRefresh:(UIRefreshControl *)refreshControl {
    
    [self loadDataFromServer];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView_ {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView_ numberOfItemsInSection:(NSInteger)section {
    
    return [statuses count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView_ cellForItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    STFeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:STFeedCellIdent forIndexPath:indexPath];
    STStatus *status = [statuses objectAtIndex:[indexPath item]];
    PFFile *imageFile = [status objectForKey:@"image"];
    [cell setImageURL:[imageFile url]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    STStatus *status = [statuses objectAtIndex:[indexPath item]];
    STStatusCommentViewController *statusCommentViewController = [[STStatusCommentViewController alloc] initWithNib];
    statusCommentViewController.status = status;
    [self presentViewController:statusCommentViewController animated:YES completion:nil];
}

#pragma mark - Data Loading

- (void)loadDataFromServer {
    
    if (!isRefreshing) {
        
        isRefreshing = YES;

        PFQuery *query = [PFQuery queryWithClassName:@"Status"];
        [query setCachePolicy:kPFCachePolicyNetworkElseCache];
        
        [self fetchFriendIdsCompleted:^(NSArray *friendIds, NSError *error) {
            
            PFUser *currentUser = [PFUser currentUser];
            NSString *currentUserFBId = currentUser[@"fbId"];

            if ([NSArray isNotEmptyArray:friendIds]) {
                
                NSMutableArray *allFriendIds = [friendIds mutableCopy];
                [allFriendIds insertObject:currentUserFBId atIndex:0];
                [query whereKey:@"userFBId" containedIn:allFriendIds];
                
            } else {
                
                [query whereKey:@"userFBId" equalTo:currentUserFBId];
            }
            
            [query includeKey:@"user"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    
                    if ([NSArray isNotEmptyArray:objects]) {
                        
                        self.statuses = [self sortedStatuses:objects];
                
                        [self.collectionView reloadData];
                        
                        runOnAsyncDefaultQueue(^{
                            
                            [self predownloadStatusData];
                        });
                    }
                }
                else {
                    
                    [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem getting statuses. Please try again."];
                }
                
                if ([refreshControl isRefreshing]) {
                    
                    [refreshControl endRefreshing];
                }
                
                isRefreshing = NO;
            }];
        }];
    }
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

- (NSArray*)sortedStatuses:(NSArray*)arr
{
    return [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        STStatus *status1 = (STStatus*) obj1;
        STStatus *status2 = (STStatus*) obj2;
        NSDate *sentAt1 = status1[@"sentAt"];
        NSDate *sentAt2 = status2[@"sentAt"];
        NSDate *updatedAt1 = status1.updatedAt;
        NSDate *updatedAt2 = status2.updatedAt;
        return [sentAt2 compare:sentAt1];
        
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

#pragma mark - Rotation

- (BOOL)shouldAutorotate {
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskLandscape;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
