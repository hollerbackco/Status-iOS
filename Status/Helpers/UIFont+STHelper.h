//
//  UIFont+STHelper.h
//  Status
//
//  Created by Joe Nguyen on 25/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSTCaptionFontName @"Gotham Rounded"
#define kSTCaptionFontSize 30.0

#import "UIFont+JNHelper.h"

@interface UIFont (STHelper)

+ (UIFont*)captionFont;
+ (UIFont*)captionFontWithSize:(CGFloat)fontSize;

@end
