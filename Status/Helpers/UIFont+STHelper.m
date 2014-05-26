//
//  UIFont+STHelper.m
//  Status
//
//  Created by Joe Nguyen on 25/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIFont+STHelper.h"

@implementation UIFont (STHelper)

+ (UIFont*)captionFont
{
    return [UIFont captionFontWithSize:kSTCaptionFontSize];
}

+ (UIFont*)captionFontWithSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:kSTCaptionFontName size:fontSize];
}

@end
