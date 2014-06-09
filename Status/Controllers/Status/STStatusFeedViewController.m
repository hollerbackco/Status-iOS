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
#import "JNIcon.h"

#import "STStatusFeedViewController.h"
#import "STStatusFeedTableViewController.h"
#import "STFeedGridViewController.h"
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

@property (nonatomic, strong) STFeedGridViewController *gridViewController;

@property (nonatomic, strong) NSArray *statuses;

- (IBAction)cameraAction:(id)sender;

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
    
    [self.gridViewController performFetchWithCachePolicy:kPFCachePolicyCacheThenNetwork];
}

#pragma mark - Views

static NSString *CellIdentifier = @"STStatusTableViewCell";

- (void)viewDidLoad
{
    JNLog();
    self.title = @"Status";
    
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationItem.hidesBackButton = YES;
    
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
    
    [self.cameraButton applyDarkerShadowLayer];
    
    FAKIonIcons *cameraIcon = [FAKIonIcons cameraIconWithSize:32.0];
    [cameraIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.cameraButton setAttributedTitle:cameraIcon.attributedString forState:UIControlStateNormal];
    
    [self hideSavingBarViewAnimated:NO];
    
    [self setupTableViewController];
    
    [self addTableViewControllerToContentView];
    
    [self.gridViewController performFetchWithCachePolicy:kPFCachePolicyCacheThenNetwork];
}

- (void)setupTableViewController
{
    JNLog();
    if (!self.gridViewController) {
        self.gridViewController = [[STFeedGridViewController alloc] init];
        [self addChildViewController:self.gridViewController];
    }
    
// TODO: This isn't needed on the grid, remove. -nick
//
//  @weakify(self);
//  self.tableViewController.didSelectStatus = ^(STStatus *status) {
//      [self_weak_ didSelectStatus:status];
//  };
//
// TODO: The share item still needs to be added to the grid and hooked up. -nick
//
//  self.tableViewController.didTapShowShareActivityBlock = ^() {
//      [self_weak_ showShareActivityView:nil];
//  };
}

- (void)addTableViewControllerToContentView
{
    self.gridViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.gridViewController.view];
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
    
    [self.gridViewController.collectionView scrollRectToVisible:CGRectMake(0.0, 0.0, 1.0, 1.0) animated:NO];
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

- (void)showShareActivityView:(id)sender
{
    JNLog();
    NSString *string = @"Try out Status!";
    NSURL *URL = [NSURL URLWithString:@"http://thestatusapp.com"];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[string, URL]
                                      applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeAirDrop,UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypePostToWeibo];
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{
                     }];
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
    
    // set session var
    [[STSession sharedInstance] setValue:@(YES) forKey:kSTSessionStoreHasCreatedStatus];
}

- (void)didCreateStatus:(STStatus*)status
{
    JNLog();
    [self finishedCreateStatus];
    
    [self.gridViewController performFetchWithCachePolicy:kPFCachePolicyNetworkOnly];
}

- (void)finishedCreateStatus
{
    [UIView animateWithBlock:^{
        self.spinnerView.alpha = 0.0;
    }];
    
    [self hideSavingBarViewAnimated:YES];
}

@end
