//
//  UIImage+JNHelper.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 26/05/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (JNHelper)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;

- (UIImage *)tintedImageWithColor:(UIColor *)tintColor;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (UIImage *)imageWithImage:(UIImage*)image
            translateOffset:(CGPoint)translateOffset;

@end





UIImage *rotatedImage(UIImage *image, CGFloat rotation);

@interface UIImage (Rotation)
- (UIImage *) rotateBy: (CGFloat) theta;
+ (UIImage *) image: (UIImage *) image rotatedBy: (CGFloat) theta;

@property (nonatomic, readonly) BOOL isLandscape;
@property (nonatomic, readonly) BOOL isPortrait;
@end


