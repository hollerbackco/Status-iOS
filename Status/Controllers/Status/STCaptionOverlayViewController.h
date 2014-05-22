//
//  STCaptionOverlayViewController.h
//  Status
//
//  Created by Joe Nguyen on 22/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNViewController.h"

#define kSTCaptionTextFieldBottomSpacingConstraint 226.0
#define kSTCaptionTextFieldBottomSpacingConstraintOffset 94.0
#define kSTAttributesForCaptionTextFontSize 30.0

@interface STCaptionOverlayViewController : JNViewController

@property (nonatomic, copy) void(^didEnterCaptionBlock)(NSString *caption);

#pragma mark - Captions

+ (NSDictionary*)attributesForCaptionText;

+ (NSDictionary*)attributesForCaptionTextWithSize:(CGFloat)fontSize;

+ (NSDictionary*)attributesForPlaceholderCaptionText;

- (NSString*)getCaption;

#pragma mark - Actions

- (IBAction)captionAction:(id)sender;

@end
