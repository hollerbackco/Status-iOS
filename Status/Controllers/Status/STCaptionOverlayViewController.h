//
//  STCaptionOverlayViewController.h
//  Status
//
//  Created by Joe Nguyen on 22/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNViewController.h"

#define kSTCaptionTextViewHorizontalPadding 78.0
#define kSTCaptionTextViewBottomSpacingConstraint 162.0
#define kSTCaptionTextViewBottomSpacingConstraintOffset 94.0
#define kSTCaptionTextViewBottomSpacingConstraintOffset3_5 138.0
#define kSTCaptionTextViewMaxTextSizeHeight 164.0

@interface STCaptionOverlayViewController : JNViewController

@property (nonatomic, copy) void(^didBeingEditing)();
@property (nonatomic, copy) void(^didEndEditing)();
@property (nonatomic, copy) void(^didEnterCaptionBlock)(NSString *caption);

#pragma mark - Captions

+ (NSDictionary*)attributesForCaptionText;

+ (NSDictionary*)attributesForCaptionTextWithSize:(CGFloat)fontSize;

+ (NSDictionary*)attributesForPlaceholderCaptionText;

- (NSString*)getCaption;

- (void)resetCaption;

#pragma mark - Actions

- (IBAction)captionAction:(id)sender;

@end
