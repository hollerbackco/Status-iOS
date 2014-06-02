//
//  STCreateStatusViewController.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <NSNotificationCenter+RACSupport.h>

#import "AVCamViewController.h"
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import "AVCamUtilities.h"

#import "JNIcon.h"

#import "STCreateStatusViewController.h"
#import "STCaptionOverlayViewController.h"
#import "STStatusFeedViewController.h"
#import "STMyStatusHistoryViewController.h"
#import "STRightToLeftTransitionAnimator.h"
#import "STStatus.h"

#define kSTAddCaptionToImageHeightOffset 20.0
#define kSTAddCaptionToImageCenterYOffset 250.0

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;

@interface STCreateStatusViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) STCaptionOverlayViewController *captionOverlayViewController;
@property (nonatomic, strong) STStatusFeedViewController *statusFeedViewController;
@property (nonatomic, strong) STMyStatusHistoryViewController *myStatusHistoryViewController;

@property (nonatomic, strong) RACDisposable *aNewCommentObserverDisposable;
@end

@interface STCreateStatusViewController (InternalMethods)

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)updateButtonStates;

@end

@interface STCreateStatusViewController (AVCamCaptureManagerDelegate) <AVCamCaptureManagerDelegate>

@end

@implementation STCreateStatusViewController

#pragma mark -

- (void)initialize
{   
    self.myStatusHistoryViewController = [[STMyStatusHistoryViewController alloc] initWithNib];
    [self.myStatusHistoryViewController performFetch];
}

- (void)dealloc
{
    [self removeNewCommentsNotificationObserver];
}

#pragma mark - Reset

- (void)resetCreateStatus
{
    [self.captionOverlayViewController resetCaption];
    
    if ([self.captureManager getDevicePosition] == AVCaptureDevicePositionBack) {
        [self.captureManager toggleCamera];
    }
    
    [self setupToggleFlash];
    
    [self.captureManager toggleFlashOff];
    
    self.toggleFlashButton.alpha = 0.0;
}

#pragma mark - Camera

- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	
	switch (focusMode) {
		case AVCaptureFocusModeLocked:
			focusString = @"locked";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"auto";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"continuous";
			break;
	}
	
	return focusString;
}

- (void)setupCamera
{
    JNLogPrimitive([self captureManager] == nil);
    if ([self captureManager] == nil) {
        
        AVCamCaptureManager *manager = [[AVCamCaptureManager alloc] init];
        [self setCaptureManager:manager];
        
        [[self captureManager] setDelegate:self];
        
        if ([[self captureManager] setupSession]) {
            
            // Create video preview layer and add it to the UI
            AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer =
            [[AVCaptureVideoPreviewLayer alloc]
             initWithSession:[[self captureManager] session]];
            UIView *view = [self videoPreviewView];
            CALayer *viewLayer = [view layer];
            [viewLayer setMasksToBounds:YES];

            CGRect bounds = [view bounds];
            [newCaptureVideoPreviewLayer setFrame:bounds];
            
            newCaptureVideoPreviewLayer.frame = view.bounds;
            
            AVCaptureConnection *captureConnection = [AVCamUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:self.captureManager.stillImageOutput.connections];
            if ([captureConnection isVideoOrientationSupported]) {
                captureConnection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            }
            
            CATransform3D rotate = CATransform3DMakeRotation(M_PI/2, 0, 0, 1);
            CATransform3D scale = CATransform3DMakeScale(1136.0/640.0, 1136.0/640.0, 1136.0/640.0);
            CATransform3D combined = CATransform3DConcat(rotate, scale);
            newCaptureVideoPreviewLayer.transform = combined;
            
            [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
            
            [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
            
            [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
            
            // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[[self captureManager] session] startRunning];
            });
            
            [self updateButtonStates];
            
            //            // Create the focus mode UI overlay
            //			UILabel *newFocusModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, viewLayer.bounds.size.width - 20, 20)];
            //			[newFocusModeLabel setBackgroundColor:[UIColor clearColor]];
            //			[newFocusModeLabel setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.50]];
            //			AVCaptureFocusMode initialFocusMode = [[[[self captureManager] videoInput] device] focusMode];
            //			[newFocusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:initialFocusMode]]];
            //			[view addSubview:newFocusModeLabel];
            //			[self addObserver:self forKeyPath:@"captureManager.videoInput.device.focusMode" options:NSKeyValueObservingOptionNew context:AVCamFocusModeObserverContext];
            //			[self setFocusModeLabel:newFocusModeLabel];
            
            // Add a single tap gesture to focus on the point tapped, then lock focus
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
            [singleTap setDelegate:self];
            [singleTap setNumberOfTapsRequired:1];
            [view addGestureRecognizer:singleTap];
            
            // Add a double tap gesture to reset the focus mode to continuous auto focus
            UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
            [doubleTap setDelegate:self];
            [doubleTap setNumberOfTapsRequired:2];
            [singleTap requireGestureRecognizerToFail:doubleTap];
            [view addGestureRecognizer:doubleTap];
        }
    }
}

- (void)setupToggleFlash
{
    FAKIonIcons *flashOffIcon = [FAKIonIcons ios7BoltOutlineIconWithSize:30.0];
    [flashOffIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.toggleFlashButton setAttributedTitle:flashOffIcon.attributedString forState:UIControlStateNormal];
    [self.toggleFlashButton applyDarkerShadowLayer];

    if (self.captureManager) {
        
        if ([self.captureManager isFlashModeSupported]) {
        } else {
            
            self.toggleFlashButton.alpha = 0.0;
        }
        
    } else {
        
        self.toggleFlashButton.alpha = 0.0;
    }
}

#pragma mark - Views

- (void)viewDidLoad
{
    JNLog();
    if (self.shouldLoadCamera) {
        
        [self setupCamera];
    }
    
    [super viewDidLoad];
    
    self.view.backgroundColor = JNBlackColor;
    
    self.videoPreviewView.backgroundColor = JNBlackColor;
    
    [self.stillButton setTitle:nil forState:UIControlStateNormal];
    [self.captionButton setTitle:nil forState:UIControlStateNormal];
    [self.cameraToggleButton setTitle:nil forState:UIControlStateNormal];
    [self.toggleFlashButton setTitle:nil forState:UIControlStateNormal];
    [self.historyButton setTitle:nil forState:UIControlStateNormal];
    [self.feedButton setTitle:nil forState:UIControlStateNormal];
    
    [self.stillButton setImage:[UIImage imageNamed:@"camera-button.png"] forState:UIControlStateNormal];
    self.stillButton.tintColor = nil;
    
    [self.headerView applyBottomHalfGradientBackgroundWithTopColor:JNBlackColor bottomColor:JNClearColor];
    
    [self.footerView applyTopHalfGradientBackgroundWithTopColor:JNClearColor bottomColor:JNBlackColor];
    
    FAKIonIcons *captionIcon = [FAKIonIcons ios7ComposeOutlineIconWithSize:32.0];
    [captionIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.captionButton setAttributedTitle:captionIcon.attributedString forState:UIControlStateNormal];
    
    FAKIonIcons *homeIcon = [FAKIonIcons homeIconWithSize:32.0];
    [homeIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.feedButton setAttributedTitle:homeIcon.attributedString forState:UIControlStateNormal];
    
    [self setupCaptionOverlay];
    
    [self setupToggleFlash];
    
    [self setupStatusFeed];
    
    [self.statusFeedViewController performFetch];
    
    [self observeNewCommentsNotification];
}

- (void)setupCaptionOverlay
{
    if (!self.captionOverlayViewController) {
        self.captionOverlayViewController = [[STCaptionOverlayViewController alloc] initWithNib];
        [self addChildViewController:self.captionOverlayViewController];
        self.captionOverlayViewController.view.frame = self.view.bounds;
        [self.view addSubview:self.captionOverlayViewController.view];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVCamFocusModeObserverContext) {
        // Update the focus UI overlay string when the focus mode changes
		[self.focusModeLabel setText:[NSString stringWithFormat:@"focus: %@", [self stringForFocusMode:(AVCaptureFocusMode)[[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
	} else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    JNLog();
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self resetCreateStatus];
    
    [self toggleHistoryButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisppear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - History / New Comments button

- (void)toggleHistoryButton
{
    NSNumber *hasNewComments = [[STSession sharedInstance] getValueForKey:kSTSessionStoreHasNewComments];
    JNLogObject(hasNewComments);
    
    NSInteger badgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    JNLogPrimitive(badgeNumber);
    
    if (hasNewComments.boolValue || badgeNumber > 0) {
        
        [self setupNewCommentsButton];
    } else {
        
        [self setupHistoryButton];
    }
}

- (void)setupHistoryButton
{
    FAKIonIcons *historyIcon = [FAKIonIcons ios7ClockOutlineIconWithSize:32.0];
    [historyIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.historyButton setAttributedTitle:historyIcon.attributedString forState:UIControlStateNormal];
    self.historyButton.layer.shadowRadius = 0.0;
}

- (void)setupNewCommentsButton
{
    NSAttributedString *newCommentsString =
    [[NSAttributedString alloc]
     initWithString:@"NEW"
     attributes:@{NSFontAttributeName: [UIFont primaryBoldFontWithSize:16.0]}];
    [self.historyButton setAttributedTitle:newCommentsString forState:UIControlStateNormal];
    [self.historyButton setTitleColor:JNWhiteColor forState:UIControlStateNormal];
    self.historyButton.tintColor = JNWhiteColor;
    self.historyButton.layer.shadowColor = JNColorWithRGB(0,255,255,1).CGColor;
    self.historyButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.historyButton.layer.shadowOpacity = 1.0;
    self.historyButton.layer.shadowRadius = 4.0;
    self.historyButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0);
}

- (void)observeNewCommentsNotification
{
    self.aNewCommentObserverDisposable =
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:kSTSessionStoreHasNewComments object:nil]
     subscribeNext:^(id x) {
         JNLogObject(x);
         [self toggleHistoryButton];
     }];
}

- (void)removeNewCommentsNotificationObserver
{
    if (self.aNewCommentObserverDisposable) {
        [self.aNewCommentObserverDisposable dispose];
    }
}

#pragma mark - Actions

- (IBAction)toggleCamera:(id)sender
{
    JNLog();
    // Toggle between cameras when there is more than one
    [[self captureManager] toggleCamera];
    
    // Do an initial focus
    [[self captureManager] continuousFocusAtPoint:CGPointMake(.5f, .5f)];
    
    if (self.captureManager.devicePosition == AVCaptureDevicePositionBack) {
        
        [UIView animateWithBlock:^{
            self.toggleFlashButton.alpha = 1.0;
        }];
    } else {
        
        [UIView animateWithBlock:^{
            self.toggleFlashButton.alpha = 0.0;
        }];
    }
}

- (IBAction)captureStillImage:(id)sender
{
    JNLog();
    
    // Capture a still image
    [[self stillButton] setEnabled:NO];
    
    [[self captureManager] captureStillImage];
    
    
    // Flash the screen white and fade it out to give UI feedback that a still image was taken
    UIView *flashView = [[UIView alloc] initWithFrame:self.videoPreviewView.frame];
    flashView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:flashView];
    [UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
     ];
}

- (IBAction)captionAction:(id)sender
{
    JNLog();
    if (self.captionOverlayViewController) {
        [self.captionOverlayViewController captionAction:sender];
    }
}

- (IBAction)toggleFlashAction:(id)sender
{
    JNLog();
    
    if (self.captureManager.flashMode == AVCaptureFlashModeOff) {
        
        FAKIonIcons *flashOnIcon = [FAKIonIcons ios7BoltIconWithSize:30.0];
        [flashOnIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
        [self.toggleFlashButton setAttributedTitle:flashOnIcon.attributedString forState:UIControlStateNormal];
    } else {
        
        [self setupToggleFlash];
    }
    
    [self.captureManager toggleFlash];
}

- (IBAction)historyAction:(id)sender
{
    JNLog();
    
    NSNumber *hasNewComments = [[STSession sharedInstance] getValueForKey:kSTSessionStoreHasNewComments];
    if (hasNewComments.boolValue) {
        
        [[STSession sharedInstance] setValue:@(NO) forKeyPath:kSTSessionStoreHasNewComments];
    }
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber) {
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    [self pushToMyStatusHistory];
}

- (IBAction)feedAction:(id)sender
{
    JNLog();
    
    [self pushToStatusFeedWithImage:nil];
}

#pragma mark - Captured Image

- (void)didCaptureImage:(UIImage*)capturedImage
{
    JNLog();
    // push to feed
    [self pushToStatusFeedWithImage:capturedImage];
}

#pragma mark - Push

- (void)pushToStatusFeedWithImage:(UIImage*)image
{
    JNLog();
    [self setupStatusFeed];
    
    [self.navigationController pushViewController:self.statusFeedViewController animated:YES];
    
    if (image) {
        [self.statusFeedViewController performCreateStatusWithImage:image];
    }
}

#pragma mark - Status Feed

- (void)setupStatusFeed
{
    JNLog();
    if (!self.statusFeedViewController) {
        self.statusFeedViewController = [[STStatusFeedViewController alloc] initWithNib];
    }
}

#pragma mark - Status History

- (void)pushToMyStatusHistory
{
    self.myStatusHistoryViewController.transitioningDelegate = self;
    self.myStatusHistoryViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:self.myStatusHistoryViewController animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    STRightToLeftTransitionAnimator *animator = [STRightToLeftTransitionAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    [self toggleHistoryButton];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    STRightToLeftTransitionAnimator *animator = [STRightToLeftTransitionAnimator new];
    return animator;
}

@end


@implementation STCreateStatusViewController (InternalMethods)

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    AVCaptureConnection *captureConnection = [AVCamUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:self.captureManager.stillImageOutput.connections];
    if ([captureConnection isVideoMirrored]) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [[self.captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [[self.captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([[self.captureVideoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[self.captureManager videoInput] device] isFocusPointOfInterestSupported]) {
        CGPoint tapPoint = [gestureRecognizer locationInView:[self videoPreviewView]];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [self.captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if ([[[self.captureManager videoInput] device] isFocusPointOfInterestSupported])
        [self.captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

// Update button states based on the number of available cameras and mics
- (void)updateButtonStates
{
	NSUInteger cameraCount = [[self captureManager] cameraCount];
//	NSUInteger micCount = [[self captureManager] micCount];
    
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (cameraCount < 2) {
            [[self cameraToggleButton] setEnabled:NO];
            
            if (cameraCount < 1) {
                [[self stillButton] setEnabled:NO];
                
//                if (micCount < 1)
//                    [[self recordButton] setEnabled:NO];
//                else
//                    [[self recordButton] setEnabled:YES];
            } else {
                [[self stillButton] setEnabled:YES];
//                [[self recordButton] setEnabled:YES];
            }
        } else {
            [[self cameraToggleButton] setEnabled:YES];
            [[self stillButton] setEnabled:YES];
//            [[self recordButton] setEnabled:YES];
        }
    });
}

@end


@implementation STCreateStatusViewController (AVCamCaptureManagerDelegate)

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
//    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
//        [[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Toggle recording button stop title")];
//        [[self recordButton] setEnabled:YES];
//    });
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
//    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
//        [[self recordButton] setTitle:NSLocalizedString(@"Record", @"Toggle recording button record title")];
//        [[self recordButton] setEnabled:YES];
//    });
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager image:(UIImage *)image
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [[self stillButton] setEnabled:YES];
    });
    
    UIImage *finalImage;
    NSString *caption = [self.captionOverlayViewController getCaption];
    if ([NSString isNotEmptyString:caption]) {
        finalImage = [self addCaptionToImage:image];
    } else {
        finalImage = image;
    }
    
    [self didCaptureImage:finalImage];
}

- (void)captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager
{
    [self updateButtonStates];
}

- (UIImage*)addCaptionToImage:(UIImage*)image
{
    // get caption image
    UIImage *captionImage = [self getCaptionImage];
    
    UIImage *result;
    
    UIGraphicsBeginImageContext(image.size);
    
    // draw image
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    [captionImage drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    
    result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

- (UIImage*)getCaptionImage
{
    UIImage *captionImage;
    
    UIGraphicsBeginImageContextWithOptions(self.captionOverlayViewController.view.bounds.size, NO, 0.0f);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(contextRef, self.captionOverlayViewController.view.bounds);
    
    [self.captionOverlayViewController.view drawViewHierarchyInRect:self.captionOverlayViewController.view.bounds afterScreenUpdates:NO];
    
    captionImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return captionImage;
}

@end
