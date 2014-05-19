//
//  STCreateStatusViewController.h
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNViewController.h"

@class AVCamCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface STCreateStatusViewController : JNViewController <UIImagePickerControllerDelegate>

@property (nonatomic, strong) AVCamCaptureManager *captureManager;
@property (nonatomic, strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) IBOutlet UIButton *cameraToggleButton;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *stillButton;
@property (nonatomic, strong) IBOutlet UILabel *focusModeLabel;

#pragma mark Toolbar Actions
//- (IBAction)toggleRecording:(id)sender;
- (IBAction)captureStillImage:(id)sender;
- (IBAction)toggleCamera:(id)sender;

@end
