//
//  STStatusCommentViewController.m
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIImageView+WebCache.h>

#import "JNIcon.h"

#import "STStatusCommentViewController.h"

@interface STStatusCommentViewController ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *changeColorButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIView *drawingView;

- (IBAction)cancelAction:(id)sender;
- (IBAction)changeColorAction:(id)sender;

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
    
    self.changeColorButton.titleLabel.font = [UIFont primaryFont];
    [self.changeColorButton setTitleColor:JNWhiteColor forState:UIControlStateNormal];
    
    self.contentView.backgroundColor = JNBlackColor;
    
    self.statusImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.statusImageView.layer.masksToBounds = YES;
    [self setupStatusImageViewWithStatus:self.status];
    
    self.drawingView.backgroundColor = JNClearColor;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Actions

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeColorAction:(id)sender
{
}

@end
