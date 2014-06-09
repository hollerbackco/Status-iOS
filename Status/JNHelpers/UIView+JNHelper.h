//
//  UIView+JNHelper.h
//  HollerbackApp
//
//  Created by Joe Nguyen on 15/03/13.
//  Copyright (c) 2013 Hollerback. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kJNDefaultAnimationDuration 0.3
#define kJNPortraitKeyboardHeight 216.0
#define kJNLandscapeKeyboardHeight 162.0

extern CGFloat const kHBViewAnimationFastDuration;

typedef void(^HBViewComplete)(BOOL finished);

@interface UIView (JNHelper)

+ (void)hideAndRemoveView:(UIView*)view;

+ (void)animateWithBlock:(void (^)(void))animations;

+ (void)animateWithBlock:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/*
 helper for animating views with constraints
 e.g. 

 */
+ (void)animateLayoutConstraintsWithContainerView:(UIView*)containerView
                                        childView:(UIView*)childView
                                         duration:(NSTimeInterval)duration
                                       animations:(void (^)(void))animations;

+ (void)animateLayoutConstraintsWithContainerView:(UIView*)containerView
                                        childView:(UIView*)childView
                                         duration:(NSTimeInterval)duration
                                       animations:(void (^)(void))animations
                                       completion:(void (^)(BOOL finished))completion;

+ (void)transformViewFlipHorizontally:(UIView*)view;

+ (void)transformViewRotate180:(UIView*)view;

- (void)fadeInAnimated:(BOOL)animated;
- (void)fadeInAnimated:(BOOL)animated complete:(HBViewComplete)complete;
- (void)fadeOutAnimated:(BOOL)animated;
- (void)fadeOutAnimated:(BOOL)animated complete:(HBViewComplete)complete;
- (void)toggleAnimated:(BOOL)animated complete:(HBViewComplete)complete;

- (void)setCircleLayerMask;
- (void)applyDarkShadowLayer;
- (void)applyDarkerShadowLayer;
- (void)applyDarkBottomShadowLayer;
- (void)applyGradientBackgroundWithTopColor:(UIColor*)topColor bottomColor:(UIColor*)bottomColor;
- (void)applyBottomHalfGradientBackgroundWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;
- (void)applyTopHalfGradientBackgroundWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

- (void)removeAllSublayers;

#pragma mark - Rounded Corner

- (void)applyRoundedCornerWithRadius:(CGFloat)radius;
- (void)removeRoundedCorner;

@end

// Helpers for CALayer
@interface CALayer (JNHelper)

+ (CALayer*)circleLayerWithSize:(CGSize)circleSize
                    strokeColor:(UIColor*)strokeColor
                      fillColor:(UIColor*)fillColor
                      lineWidth:(CGFloat)lineWidth;

+ (CALayer*)circleLayerWithSize:(CGSize)circleSize
                       position:(CGPoint)position
                    strokeColor:(UIColor*)strokeColor
                      fillColor:(UIColor*)fillColor
                      lineWidth:(CGFloat)lineWidth;

@end




#pragma mark - JNViewWithTouchableSubviews

@interface JNViewWithTouchableSubviews : UIView

@end






#pragma mark - CALayer (RoundedCorners)

@interface CALayer (RoundedCorners)

+ (void)maskRoundCorners:(UIRectCorner)corners radius:(CGFloat)radius view:(UIView*)view;
+ (id)maskLayerWithCorners:(UIRectCorner)corners radii:(CGSize)radii frame:(CGRect)frame;

@end







#pragma mark - UITextField (JNHelper)

@interface UITextField (JNHelper)

- (void)applyDefaultPadding;

- (void)applyPadding:(CGFloat)width;

- (void)addToolBarItem:(NSString*)title target:(id)target action:(SEL)action;

- (void)addToolbarWithDoneTarget:(id)doneTarget doneAction:(SEL)doneAction
                      prevTarget:(id)prevTarget prevAction:(SEL)prevAction
                      nextTarget:(id)nextTarget nextAction:(SEL)nextAction;

- (void)removeToolBarItems;

@end







#pragma mark - UIBarButtonItem (JNHelper)

@interface UIBarButtonItem (JNHelper)

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action font:(UIFont*)font textColor:(UIColor*)textColor;

@end










#pragma mark - Blur View

@interface JNBlurView : UIView

// Use the following property to set the tintColor. Set it to nil to reset.
@property (nonatomic, strong) UIColor *blurTintColor;

@end




