//
//  STStatusFeedViewController.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIViewController+JNHelper.h"

#import "JNAlertView.h"

#import "STStatusFeedViewController.h"
#import "STStatusTableViewCell.h"
#import "STStatus.h"
#import "STAppDelegate.h"

@interface STStatusFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *savingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;

@property (nonatomic, copy) NSString *parseClassName;
@property (nonatomic, strong) NSArray *statuses;

@end

@implementation STStatusFeedViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // This table displays items in the Todo class
//        self.parseClassName = @"Status";
//        self.pullToRefreshEnabled = YES;
//        self.paginationEnabled = YES;
//        self.objectsPerPage = 25;
//        
//        self.didLoadFriendIds = @(NO);
//    }
//    return self;
//}

- (void)initialize
{
    self.parseClassName = @"Status";
}

#pragma mark - Fetch

- (void)performFetch
{
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
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
            
            JNLogObject(objects);
            self.statuses = objects;
            
            [self.tableView reloadData];
        }];
    }];
}

#pragma mark - Views

static NSString *CellIdentifier = @"STStatusTableViewCell";

- (void)viewDidLoad
{
    self.title = @"Status";
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    [super viewDidLoad];

    [self setupNavigationBar];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [UIView animateWithBlock:^{
        self.tableHeaderView.frame = CGRectSetHeight(self.tableHeaderView.frame, 0.0);
    }];
    
    [self performFetch];
    
    self.progressView.progress = 0.0;
    
    [self hideTableHeaderViewAnimated:NO];
}

- (void)setupNavigationBar
{
    [self applyCameraNavigationButtonWithTarget:self action:@selector(cameraAction:)];
    
    [self applyNavigationBarRightButtonWithText:@"feedback"
                                         target:self
                                         action:@selector(feedbackAction:)
                                     edgeInsets:UIEdgeInsetsMake(1.0, -10.0, 0.0, -28.0)];
}

- (void)showTableHeaderViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? UINavigationControllerHideShowBarDuration : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.tableHeaderView duration:duration animations:^{
        self.headerViewTopConstraint.constant = 0.0;
    }];

    self.spinnerView.alpha = 0.0;
}

- (void)hideTableHeaderViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? UINavigationControllerHideShowBarDuration : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.tableHeaderView duration:duration animations:^{
        self.headerViewTopConstraint.constant = -self.tableHeaderView.frame.size.height;
    }];
}

#pragma mark - Actions

- (void)cameraAction:(id)sender
{
    [((STAppDelegate*) [UIApplication sharedApplication].delegate) showCreateStatusAsRootViewController:YES];
}

- (void)feedbackAction:(id)sender
{
    // mailto: string
    NSString *username = [PFUser currentUser][@"fbName"];
    if (![NSString isNotEmptyString:username]) {
        username = @"<no username>";
    }
    NSString *mailtoString = [NSString stringWithFormat:@"mailto:hello+status@hollerback.co?subject=Status%%20app%%20feedback"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoString]];
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
    
    if (self.placeholderImage &&
        [user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        
        cell.photoImage = self.placeholderImage;
        
    } else {
        
        PFFile *imageFile = status[@"image"];
        if (imageFile) {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage *image = [UIImage imageWithData:data];
                cell.photoImage = image;
            } progressBlock:^(int percentDone) {
                ;
            }];
        }
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

#pragma mark - Create Status

- (void)performCreateStatusWithImage:(UIImage*)image
{
    [self showTableHeaderViewAnimated:YES];
    
    self.savingLabel.text = @"Saving...";
    
    [self createStatusWithImage:image];
}

- (void)createStatusWithImage:(UIImage*)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.99f);
    PFFile *imageFile = [PFFile fileWithName:@"img" data:imageData];
    
    // update file
    [imageFile
     saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         
         [UIView animateWithBlock:^{
             self.progressView.alpha = 0.0;
             self.spinnerView.alpha = 1.0;
             self.savingLabel.text = @"Finishing up...";
         }];
         
         [self.spinnerView startAnimating];
         
         // check if status exists
         PFQuery *getStatusQuery = [PFQuery queryWithClassName:@"Status"];
         [getStatusQuery whereKey:@"user" equalTo:[PFUser currentUser]];
         [getStatusQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
             
             if (number == 0) {
                 
                 // create a new status object
                 STStatus *status = [STStatus new];
                 status[@"image"] = imageFile;
                 status[@"userFBId"] = [[PFUser currentUser] objectForKey:@"fbId"];
                 status[@"user"] = [PFUser currentUser];
                 
                 [status saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     
                     if (error) {
                         
                         JNLogObject(error);
                         [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem saving your status. Please try again."];
                         
                         [self finishedCreateStatus];
                         
                     } else {
                         
                         JNLog(@"status successfully saved");
                         [self didCreateStatus:status];
                     }
                 }];
                 
             } else {
                 
                 [getStatusQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                     
                     if (error) {
                         
                         JNLogObject(error);
                         [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem saving your status. Please try again."];
                         
                         [self finishedCreateStatus];
                         
                     } else {
                         
                         JNLogObject(object);
                         if (object) {
                             
                             // update the status object
                             STStatus *status = (STStatus*) object;
                             status[@"image"] = imageFile;
                             [status saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                 
                                 if (error) {
                                     
                                     JNLogObject(error);
                                     [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem saving your status. Please try again."];
                                     
                                     [self finishedCreateStatus];
                                     
                                 } else {
                                     
                                     JNLog(@"status successfully updated");
                                     [self didCreateStatus:status];
                                 }
                             }];
                             
                         } else {
                             
                             [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem saving your status. Please try again."];
                             
                             [self finishedCreateStatus];
                         }
                     }
                 }];
             }
         }];
     }
     progressBlock:^(int percentDone) {
         
         runOnMainQueue(^{
             [self.progressView setProgress:((float) percentDone * 0.01) animated:YES];
         });
         
     }];
}

- (void)didCreateStatus:(STStatus*)status
{
    // save to status history
    PFObject *statusHistory = [PFObject objectWithClassName:@"StatusHistory"];
    statusHistory[@"image"] = status[@"image"];
    statusHistory[@"userFBId"] = status[@"userFBId"];
    statusHistory[@"user"] = status[@"user"];
    [statusHistory saveEventually:^(BOOL succeeded, NSError *error) {
        
        if (error) {
            
            JNLogObject(error);
            
        } else {
            
            JNLog(@"status history successfully saved");
        }
    }];
    
    [self finishedCreateStatus];
    
    [self performFetch];
}

- (void)finishedCreateStatus
{
    [UIView animateWithBlock:^{
        self.spinnerView.alpha = 0.0;
    }];
    
    [self hideTableHeaderViewAnimated:YES];
}

@end
