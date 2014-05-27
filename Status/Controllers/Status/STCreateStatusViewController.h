//
//  STCreateStatusViewController.h
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNViewController.h"

@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface STCreateStatusViewController : JNViewController <UIImagePickerControllerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) AVCamCaptureManager *captureManager;
@property (nonatomic, strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) IBOutlet UIButton *cameraToggleButton;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (nonatomic, strong) IBOutlet UIButton *stillButton;
@property (nonatomic, strong) IBOutlet UILabel *focusModeLabel;
@property (weak, nonatomic) IBOutlet UIButton *captionButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleFlashButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

@property (nonatomic) BOOL shouldLoadCamera;

#pragma mark - Camera

- (void)setupCamera;

#pragma mark - Actions

- (IBAction)captureStillImage:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (IBAction)captionAction:(id)sender;
- (IBAction)toggleFlashAction:(id)sender;
- (IBAction)historyAction:(id)sender;

#pragma mark - Captured Image

- (void)didCaptureImage:(UIImage*)capturedImage;

@end
