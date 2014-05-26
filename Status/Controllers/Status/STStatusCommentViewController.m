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
    
    self.footerView.backgroundColor = JNBlackColor;
    
    self.sendButton.titleLabel.font = [UIFont primaryFontWithSize:20.0];
    self.sendButton.backgroundColor = STGreenButtonBackgroundColor;
    [self.sendButton setTitleColor:JNWhiteColor forState:UIControlStateNormal];
    [STStatus object:self.status fetchSenderNameCompleted:^(NSString *senderName) {
        
        NSString *sendButtonTitle = [NSString stringWithFormat:@"Send privately to %@", senderName];
        [self.sendButton setTitle:sendButtonTitle forState:UIControlStateNormal];
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
}

@end
