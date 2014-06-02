//
//  STStatusCommentViewController.m
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <DLCPHuePicker.h>
#import <ACEDrawingView.h>

#import "UIColor+STHelper.h"

#import "JNIcon.h"

#import "STStatusCommentViewController.h"

@interface STStatusCommentViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet DLCPHuePicker *huePicker;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet ACEDrawingView *drawingView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) UIColor *drawingLineColor;
@property (nonatomic, strong) UIActivityIndicatorView *sendSpinnerView;
@property (nonatomic, copy) NSString *sendToButtonText;

- (IBAction)cancelAction:(id)sender;
- (IBAction)undoAction:(id)sender;
- (IBAction)sendAction:(id)sender;

@end

@implementation STStatusCommentViewController

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = JNBlackColor;
    
    self.headerView.backgroundColor = JNClearColor;
    
    [self.cancelButton setTitle:nil forState:UIControlStateNormal];
    FAKIonIcons *icon = [FAKIonIcons closeIconWithSize:28.0];
    [icon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.cancelButton setAttributedTitle:icon.attributedString forState:UIControlStateNormal];
    
    [self.undoButton setTitle:nil forState:UIControlStateNormal];
    FAKIonIcons *undoIcon = [FAKIonIcons refreshbeforeionRefreshingIconWithSize:28.0];
    [undoIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.undoButton setAttributedTitle:undoIcon.attributedString forState:UIControlStateNormal];
    
    self.undoButton.alpha = 0.0;
    
    self.drawingLineColor = kSTDefaultDrawingLineColor;
    
    self.huePicker.backgroundColor = JNClearColor;
    self.huePicker.color = kSTDefaultDrawingLineColor;
    
    self.contentView.backgroundColor = JNBlackColor;
    
    self.statusImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.statusImageView.layer.masksToBounds = YES;
    [self setupStatusImageViewWithStatus:self.status];
    
    self.drawingView.backgroundColor = JNClearColor;
    [self setupDrawingView];
    
    [self.huePicker addTarget:self action:@selector(huePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.footerView.backgroundColor = JNClearColor;
    
    self.sendButton.titleLabel.font = [UIFont primaryFontWithSize:20.0];
    self.sendButton.backgroundColor = STGreenButtonBackgroundColor;
    [self.sendButton setTitleColor:JNWhiteColor forState:UIControlStateNormal];
    [STStatus object:self.status fetchSenderNameCompleted:^(NSString *senderName) {
        
        self.sendToButtonText = [NSString stringWithFormat:@"Send privately to %@", senderName];
        [self.sendButton setTitle:self.sendToButtonText forState:UIControlStateNormal];
    }];
}

- (void)setupStatusImageViewWithStatus:(STStatus*)status
{
    NSURL *photoImageURL;
    
    PFFile *imageFile = status[@"image"];
    if (imageFile) {
        
        photoImageURL = [NSURL URLWithString:imageFile.url];
    }
    
    [self.statusImageView
     setImageWithURL:photoImageURL
     placeholderImage:nil
     options:SDWebImageRetryFailed
     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
         ;
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
         ;
     }];
}

- (void)setupDrawingView
{
    self.drawingView.backgroundColor = JNClearColor;
    self.drawingView.lineWidth = kSTDrawingLineWidth;
    self.drawingView.lineColor = kSTDefaultDrawingLineColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    JNLog();
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)undoAction:(id)sender
{
}

- (void)huePickerValueChanged:(id)sender
{
    DLCPHuePicker *huePicker = (DLCPHuePicker*) sender;
    
    CGFloat hue, saturation, brightness, alpha;
    [self.drawingLineColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    self.drawingLineColor = [UIColor colorWithHue:huePicker.hue saturation:saturation brightness:brightness alpha:alpha];
    
    self.drawingView.lineColor = self.drawingLineColor;
}

- (IBAction)sendAction:(id)sender
{
    JNLog();
    [self performCreateStatusCommentWithImage:self.drawingView.image];
}

#pragma mark - Create Status Comment

- (void)performCreateStatusCommentWithImage:(UIImage*)image
{
    JNLog();
    [self.sendButton setTitle:nil forState:UIControlStateNormal];
    
    if (!self.sendSpinnerView) {
        self.sendSpinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.sendSpinnerView.center = self.sendButton.center;
        [self.footerView addSubview:self.sendSpinnerView];
    }
    
    [self.sendSpinnerView startAnimating];
    [UIView animateWithBlock:^{
        self.sendSpinnerView.alpha = 1.0;
    }];
    
    [self createStatusCommentWithImage:image];
}

- (void)createStatusCommentWithImage:(UIImage*)image
{
    JNLog();
    NSData *imageData = UIImagePNGRepresentation(image);
    PFFile *imageFile = [PFFile fileWithName:@"img.png" data:imageData];
    
    // upload file
    [imageFile
     saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         
         if (error) {
             
             [JNLogger logExceptionWithName:THIS_METHOD reason:@"image upload" error:error];
             [self showError];
             [self finishedCreateStatusCommentWithError];
             
         } else {
             
             PFQuery *statusHistoryQuery = [PFQuery queryWithClassName:@"StatusHistory"];
             [statusHistoryQuery whereKey:@"statusId" equalTo:self.status.objectId];
             [statusHistoryQuery orderByDescending:@"createdAt"];
             [statusHistoryQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                 
                 if (error) {
                     
                     [JNLogger logExceptionWithName:THIS_METHOD reason:@"status history get" error:error];
                     [self showError];
                     [self finishedCreateStatusCommentWithError];
                     
                 } else {
                     
                     // create a new status object
                     STStatusComment *statusComment = [STStatusComment new];
                     statusComment[@"image"] = imageFile;
                     statusComment[@"userFBId"] = [[PFUser currentUser] objectForKey:@"fbId"];
                     statusComment[@"user"] = [PFUser currentUser];
                     statusComment[@"senderName"] = [PFUser currentUser][@"fbName"];
                     statusComment[@"sentAt"] = [NSDate date];
                     statusComment[@"parent"] = object;
                     
                     [statusComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         
                         if (error) {
                             
                             [JNLogger logExceptionWithName:THIS_METHOD reason:@"status comment save" error:error];
                             [self showError];
                             [self finishedCreateStatusCommentWithError];
                             
                         } else {
                             
                             //                 JNLog(@"status comment successfully saved");
                             [self didCreateStatusComment:statusComment];
                         }
                     }];
                 }
             }];
         }
         
     }
     progressBlock:^(int percentDone) {
         ;
     }];
}

- (void)didCreateStatusComment:(STStatusComment*)statusComment
{
    JNLog();
    [self finishedCreateStatusComment];
    
    [self.sendButton setTitle:@"Sent!" forState:UIControlStateNormal];
    
    [self performBlock:^{
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } afterDelay:0.7];
}

- (void)finishedCreateStatusComment
{
    [UIView animateWithBlock:^{
        self.sendSpinnerView.alpha = 0.0;
    }];
}

- (void)finishedCreateStatusCommentWithError
{
    [self finishedCreateStatusComment];
    
    runOnMainQueue(^{
        [self.sendButton setTitle:self.sendToButtonText forState:UIControlStateNormal];
    });
}

- (void)showError
{
    runOnMainQueue(^{
        [JNAlertView showWithTitle:@"Oopsy" body:@"There was a problem saving your reply. Please try again."];
    });
}

@end
