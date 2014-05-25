//
//  STCaptionOverlayViewController.h
//  Status
//
//  Created by Joe Nguyen on 22/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNViewController.h"

#define kSTCaptionTextViewBottomSpacingConstraint 224.0
#define kSTCaptionTextViewBottomSpacingConstraintOffset 94.0
#define kSTCaptionTextViewMaxTextSizeHeight 198.0
#define kSTAttributesForCaptionTextFontSize 30.0

@interface STCaptionOverlayViewController : JNViewController

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
