//
//  STStatusFeedViewController.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <RACEXTScope.h>

#import "UIViewController+JNHelper.h"

#import "JNAlertView.h"

#import "STStatusFeedViewController.h"
#import "STStatusFeedTableViewController.h"
#import "STStatusCommentViewController.h"

#import "STStatusTableViewCell.h"
#import "STStatus.h"
#import "STAppDelegate.h"

@interface STStatusFeedViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *savingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIButton *footerButton;

@property (nonatomic, strong) STStatusFeedTableViewController *tableViewController;

@property (nonatomic, strong) NSArray *statuses;

@end

@implementation STStatusFeedViewController

- (void)initialize
{
    ;
}

#pragma mark - 

- (void)performFetch
{
    JNLog();
    [self setupTableViewController];
    
    [self.tableViewController performFetchWithCachePolicy:kPFCachePolicyCacheThenNetwork];
}

#pragma mark - Views

static NSString *CellIdentifier = @"STStatusTableViewCell";

- (void)viewDidLoad
{
    JNLog();
    self.title = @"Status";
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    [super viewDidLoad];

    [self setupNavigationBar];
    
    self.tableHeaderView.backgroundColor = JNGrayBackgroundColor;
    self.savingLabel.textColor = JNBlackTextColor;
    self.spinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.progressView.progress = 0.0;
    
    [self hideTableHeaderViewAnimated:NO];
    
    [self setupTableViewController];
    
    [self addTableViewControllerToContentView];
    
    [self.tableViewController performFetchWithCachePolicy:kPFCachePolicyCacheThenNetwork];
}

- (void)setupNavigationBar
{
    [self applyCameraNavigationButtonWithTarget:self action:@selector(cameraAction:)];
    
    [self applyNavigationBarRightButtonWithText:@"feedback"
                                         target:self
                                         action:@selector(feedbackAction:)
                                     edgeInsets:UIEdgeInsetsMake(1.0, -10.0, 0.0, -28.0)];
}

- (void)setupTableViewController
{
    JNLog();
    if (!self.tableViewController) {
        self.tableViewController = [[STStatusFeedTableViewController alloc] initWithNibName:@"STStatusFeedTableViewController" bundle:nil];
        [self addChildViewController:self.tableViewController];
    }
    
    @weakify(self);
    self.tableViewController.didSelectStatus = ^(STStatus *status) {
        
        [self_weak_ didSelectStatus:status];
    };
    
    self.tableViewController.didTapShowShareActivityBlock = ^() {
        
        [self_weak_ showShareActivityView:nil];
    };
}

- (void)addTableViewControllerToContentView
{
    self.tableViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.tableViewController.view];
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

- (void)viewWillAppear:(BOOL)animated
{
    JNLog();
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:NO];
}

#pragma mark - Actions

- (void)cameraAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)feedbackAction:(id)sender
{
    [STLogger sendLogFileOnAppBackground];
    
    // mailto: string
    NSString *username = [PFUser currentUser][@"fbName"];
    if (![NSString isNotEmptyString:username]) {
        username = @"<no username>";
    }
    NSString *mailtoString = [NSString stringWithFormat:@"mailto:hello+status@hollerback.co?subject=Status%%20app%%20feedback"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailtoString]];
}

- (void)didSelectStatus:(STStatus*)status
{
    STStatusCommentViewController *statusCommentViewController = [[STStatusCommentViewController alloc] initWithNib];
    statusCommentViewController.status = status;
    [self.navigationController presentViewController:statusCommentViewController animated:YES completion:nil];
}

- (void)showShareActivityView:(id)sender
{
    JNLog();
    NSString *string = @"Try out Status!";
    NSURL *URL = [NSURL URLWithString:@"http://statusapp.parseapp.com"];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo];

    [self.navigationController presentViewController:activityViewController
                                       animated:YES
                                     completion:^{
                                     }];
}

#pragma mark - Create Status

- (void)performCreateStatusWithImage:(UIImage*)image
{
    JNLog();
    [self showTableHeaderViewAnimated:YES];
    
    self.savingLabel.text = @"Saving...";
    self.progressView.progress = 0.0;
    self.progressView.alpha = 1.0;
    
    [self createStatusWithImage:image];
}

- (void)createStatusWithImage:(UIImage*)image
{
    JNLog();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.99f);
    PFFile *imageFile = [PFFile fileWithName:@"img.jpg" data:imageData];
    
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
                 status[@"senderName"] = [PFUser currentUser][@"fbName"];
                 status[@"sentAt"] = [NSDate date];
                 
                 [status saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     
                     if (error) {
                         
                         JNLogObject(error);
                         [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem saving your status. Please try again."];
                         
                         [self finishedCreateStatus];
                         
                     } else {
                         
//                         JNLog(@"status successfully saved");
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
                         
//                         JNLogObject(object);
                         if (object) {
                             
                             // update the status object
                             STStatus *status = (STStatus*) object;
                             status[@"image"] = imageFile;
                             status[@"senderName"] = [PFUser currentUser][@"fbName"];
                             status[@"sentAt"] = [NSDate date];

                             [status saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                 
                                 if (error) {
                                     
                                     JNLogObject(error);
                                     [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem saving your status. Please try again."];
                                     
                                     [self finishedCreateStatus];
                                     
                                 } else {
                                     
//                                     JNLog(@"status successfully updated");
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
    JNLog();
    [self finishedCreateStatus];
    
    [self.tableViewController performFetchWithCachePolicy:kPFCachePolicyNetworkOnly];
}

- (void)finishedCreateStatus
{
    [UIView animateWithBlock:^{
        self.spinnerView.alpha = 0.0;
    }];
    
    [self hideTableHeaderViewAnimated:YES];
}

@end
