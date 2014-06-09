//
//  STStatusFeedViewController.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <RACEXTScope.h>

#import "UIViewController+JNHelper.h"
#import "UIViewController+STShareActivity.h"

#import "JNAlertView.h"
#import "JNIcon.h"

#import "STStatusFeedViewController.h"
#import "STStatusFeedTableViewController.h"
#import "STStatusCommentViewController.h"

#import "STStatusTableViewCell.h"
#import "STStatus.h"
#import "STAppDelegate.h"

@interface STStatusFeedViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *savingBarView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (weak, nonatomic) IBOutlet UILabel *savingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *savingBarViewTopConstraint;
@property (weak, nonatomic) IBOutlet JNViewWithTouchableSubviews *footerView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (nonatomic, strong) STStatusFeedTableViewController *tableViewController;

@property (nonatomic, strong) NSArray *statuses;

- (IBAction)cameraAction:(id)sender;

@end

@implementation STStatusFeedViewController

- (void)initialize
{
    ;
}

#pragma mark - 

- (void)resetView
{
    if (self.tableViewController && self.tableViewController.tableView) {
        
        [self.tableViewController.tableView scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:NO];
    }
}

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
    
    [super viewDidLoad];
    
    [self.headerView applyBottomHalfGradientBackgroundWithTopColor:JNBlackColor bottomColor:JNClearColor];
    self.headerView.layer.masksToBounds = YES;
    self.headerLabel.backgroundColor = JNClearColor;
    self.headerLabel.textColor = JNWhiteColor;
    [self.headerLabel applyDarkShadowLayer];
    
    self.savingBarView.backgroundColor = JNGrayBackgroundColor;
    self.savingLabel.textColor = JNBlackTextColor;
    self.spinnerView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.progressView.progress = 0.0;

    self.footerView.backgroundColor = JNClearColor;
    
    [self.cameraButton setTitle:nil forState:UIControlStateNormal];
    [self.cameraButton setImage:[UIImage imageNamed:@"camera-left-nav-button.png"] forState:UIControlStateNormal];
    
    [self hideSavingBarViewAnimated:NO];
    
    [self setupTableViewController];
    
    [self addTableViewControllerToContentView];
    
    [self.tableViewController performFetchWithCachePolicy:kPFCachePolicyCacheThenNetwork];
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

- (void)showSavingBarViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? kJNDefaultAnimationDuration : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.savingBarView duration:duration animations:^{
        self.savingBarViewTopConstraint.constant = 0.0;
    }];

    self.spinnerView.alpha = 0.0;
}

- (void)hideSavingBarViewAnimated:(BOOL)animated
{
    CGFloat duration = animated ? kJNDefaultAnimationDuration : 0.0;
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.savingBarView duration:duration animations:^{
        self.savingBarViewTopConstraint.constant = -self.savingBarView.frame.size.height;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    JNLog();
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    if ([self shouldDisplayFeedOverlay]) {
        
        [self showFeedOverlay];
        
        [self.view bringSubviewToFront:self.footerView];

        self.tableViewController.tableView.userInteractionEnabled = NO;
    } else {
        
        [self hideFeedOverlay];
        
        self.tableViewController.tableView.userInteractionEnabled = YES;
    }
}

- (BOOL)shouldDisplayFeedOverlay
{
    NSNumber *hasCreatedStatus = [[STSession sharedInstance] getValueForKey:kSTSessionStoreHasCreatedStatus];
    JNLogPrimitive(hasCreatedStatus.boolValue);
    return !hasCreatedStatus.boolValue;
}

static NSUInteger kSTFeedOverlayView = 8172318;

- (void)showFeedOverlay
{
    JNLog();
    JNBlurView *overlayView = [[JNBlurView alloc] initWithFrame:self.view.bounds];
    overlayView.tag = kSTFeedOverlayView;
    
    UILabel *overlayLabel = [[UILabel alloc] initWithFrame:overlayView.bounds];
    overlayLabel.textAlignment = NSTextAlignmentCenter;
    overlayLabel.font = [UIFont primaryFontWithSize:24.0];
    overlayLabel.text =
    @"Set your status to see the statuses of your friends.\n\n"
    "Each status you post replaces your last.\n\n"
    "Your Facebook friends who have the app\n"
    "will be shown in this feed.";
    overlayLabel.numberOfLines = 0;
    overlayLabel.textColor = JNBlackColor;
    [overlayView addSubview:overlayLabel];
    
    [self.view addSubview:overlayView];
}

- (void)hideFeedOverlay
{
    UIView *overlayView = [self.view viewWithTag:kSTFeedOverlayView];
    if (overlayView) {
        [overlayView removeFromSuperview];
    }
}

#pragma mark - Actions

- (void)cameraAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    statusCommentViewController.view.frame = self.view.bounds;
    [self presentViewController:statusCommentViewController animated:YES completion:nil];
}

#pragma mark - Create Status

- (void)performCreateStatusWithImage:(UIImage*)image
{
    JNLog();
    
    [self showSavingBarViewAnimated:YES];
    
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
    
    [self hideSavingBarViewAnimated:YES];
}

@end
