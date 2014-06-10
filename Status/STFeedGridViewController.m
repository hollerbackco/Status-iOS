//
//  STFeedGridViewController.m
//  Status
//
//  Created by Nick Jensen on 6/4/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <RACEXTScope.h>

#import "UIColor+STHelper.h"

#import "JNIcon.h"
#import "JNAppManager.h"

#import "STFeedGridViewController.h"
#import "STFeedCell.h"
#import "STStatus.h"
#import "JNAlertView.h"
#import "STStatusCommentViewController.h"

@implementation STFeedGridViewController

@synthesize collectionView, refreshControl, shouldDisplayExtraBottomCell;

static NSString *ExtraBottomCellIdentifier = @"ExtraBottomCellIdentifier";

- (void)loadView {
    
    [super loadView];
    
    CGRect bounds = [[self view] bounds];
    
    UICollectionViewFlowLayout *layout;
    layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:0.0f];
    [layout setMinimumInteritemSpacing:0.0f];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    if ([JNAppManager is3_5InchScreenSize]) {
        [layout setItemSize:STFeedCell35Size];
    } else {
        [layout setItemSize:STFeedCellSize];
    }
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:bounds collectionViewLayout:layout];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ExtraBottomCellIdentifier];
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

- (void)handlePullToRefresh:(UIRefreshControl *)refreshControl {
    
    [self performFetchWithCachePolicy:kPFCachePolicyNetworkElseCache];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView_ {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView_ numberOfItemsInSection:(NSInteger)section {
    
    NSUInteger count = self.statuses.count;
    if (self.shouldDisplayExtraBottomCell) {
        count++;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView_ cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.shouldDisplayExtraBottomCell && indexPath.row > self.statuses.count - 1) {
        
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ExtraBottomCellIdentifier forIndexPath:indexPath];
        
        cell.contentView.backgroundColor = STGreenButtonBackgroundColor;

        CGSize cellSize = CGSizeZero;
        if ([JNAppManager is3_5InchScreenSize]) {
            cellSize = STFeedCell35Size;
        } else {
            cellSize = STFeedCellSize;
        }
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:(CGRect) {CGPointZero, cellSize}];
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *finalMessage = [[NSMutableAttributedString alloc] init];
        
        // line 1
        NSAttributedString *inviteFriendsMessageLine1 =
        [[NSAttributedString alloc]
         initWithString:@"more friends = more statuses"
         attributes:@{NSFontAttributeName: [UIFont primaryFontWithSize:19.0],
                      NSForegroundColorAttributeName: JNWhiteColor}];
        [finalMessage appendAttributedString:inviteFriendsMessageLine1];
        
        // spacing
        [finalMessage appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:@"\n\n"
          attributes:@{NSFontAttributeName: [UIFont primaryFontWithSize:10.0],
                       NSForegroundColorAttributeName: JNWhiteColor}]];
        
        // icon
        FAKIonIcons *invitePeopleIcon = [FAKIonIcons personAddIconWithSize:50.0];
        [invitePeopleIcon addAttributes:@{NSForegroundColorAttributeName: JNWhiteColor}];
        [finalMessage appendAttributedString:invitePeopleIcon.attributedString];
        
        // spacing
        [finalMessage appendAttributedString:
         [[NSAttributedString alloc]
          initWithString:@"\n\n"
          attributes:@{NSFontAttributeName: [UIFont primaryFontWithSize:10.0],
                       NSForegroundColorAttributeName: JNWhiteColor}]];
        
        // line 2
        NSAttributedString *inviteFriendsMessageLine2 =
        [[NSAttributedString alloc]
         initWithString:@"invite friends"
         attributes:@{NSFontAttributeName: [UIFont primaryFontWithSize:28.0],
                      NSForegroundColorAttributeName: JNWhiteColor}];
        [finalMessage appendAttributedString:inviteFriendsMessageLine2];
        
        textLabel.attributedText = finalMessage;
        
        [cell.contentView addSubview:textLabel];
        
        return cell;
    }
    
    STFeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:STFeedCellIdent forIndexPath:indexPath];
    STStatus *status = [self.statuses objectAtIndex:[indexPath item]];
    PFFile *imageFile = [status objectForKey:@"image"];
    [cell setImageURL:[imageFile url]];
    
    // sender name
    @weakify(cell);
    [STStatus object:status fetchSenderNameCompleted:^(NSString *senderName) {
        
        runOnMainQueue(^{
            
            cell_weak_.senderName = senderName;
        });
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{   
    if (self.shouldDisplayExtraBottomCell && indexPath.row > self.statuses.count - 1) {
        
        if (self.didTapShowShareActivityBlock) {
            self.didTapShowShareActivityBlock();
        }
    } else {
        
        STStatus *status = [self.statuses objectAtIndex:[indexPath item]];
        STStatusCommentViewController *statusCommentViewController = [[STStatusCommentViewController alloc] initWithNib];
        statusCommentViewController.status = status;
        [self presentViewController:statusCommentViewController animated:YES completion:nil];
    }
}

#pragma mark - Data Loading

- (void)performFetchWithCachePolicy:(PFCachePolicy)cachePolicy {
    
    if (!isRefreshing) {
        
        isRefreshing = YES;

        PFQuery *query = [PFQuery queryWithClassName:@"Status"];
        [query setCachePolicy:cachePolicy];
        
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
            
            if ((cachePolicy == kPFCachePolicyCacheThenNetwork ||
                 cachePolicy == kPFCachePolicyCacheElseNetwork ||
                 cachePolicy == kPFCachePolicyCacheOnly) && !query.hasCachedResult) {
                
                query.cachePolicy = kPFCachePolicyNetworkOnly;
            }
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (!error) {
                    
                    if ([NSArray isNotEmptyArray:objects]) {
                        
                        self.statuses = [self sortedStatuses:objects];
                
                        [self.collectionView reloadData];
                        
                        runOnAsyncDefaultQueue(^{
                            
                            [self predownloadStatusData];
                        });
                    }
                    
                    self.shouldDisplayExtraBottomCell = YES;
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
