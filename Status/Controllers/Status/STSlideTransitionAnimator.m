//
//  STSlideTransitionAnimator.m
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIView+JNHelper.h"

#import "STSlideTransitionAnimator.h"

@implementation STSlideTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kJNDefaultAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {
        
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        if (self.slideDirection == kSTSlideDirectionLeftToRight) {
            
            fromViewController.view.frame = CGRectMake(0.0, 0.0,
                                                       fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
            toViewController.view.frame = CGRectMake(0.0, toViewController.view.bounds.size.width,
                                                     toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                
                fromViewController.view.frame = CGRectMake(0.0, -fromViewController.view.bounds.size.width,
                                                           fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
                toViewController.view.frame = CGRectMake(0.0, 0.0,
                                                         toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
                
            } completion:^(BOOL finished) {
                
                [transitionContext completeTransition:YES];
            }];
            
        } else {
            
            fromViewController.view.frame = CGRectMake(0.0, 0.0,
                                                       fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
            toViewController.view.frame = CGRectMake(0.0, -toViewController.view.bounds.size.width,
                                                     toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                
                fromViewController.view.frame = CGRectMake(0.0, fromViewController.view.bounds.size.width,
                                                           fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
                toViewController.view.frame = CGRectMake(0.0, 0.0,
                                                         toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
                
            } completion:^(BOOL finished) {
                
                [transitionContext completeTransition:YES];
            }];
        }
    }
    else {
        
        toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        if (self.slideDirection == kSTSlideDirectionLeftToRight) {
            
            fromViewController.view.frame = CGRectMake(0.0, 0.0,
                                                       fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
            toViewController.view.frame = CGRectMake(0.0, -toViewController.view.bounds.size.width,
                                                     toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                
                fromViewController.view.frame = CGRectMake(0.0, fromViewController.view.bounds.size.width,
                                                           fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
                toViewController.view.frame = CGRectMake(0.0, 0.0,
                                                         toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
                
            } completion:^(BOOL finished) {
                
                [transitionContext completeTransition:YES];
            }];
        } else {
            
            fromViewController.view.frame = CGRectMake(0.0, 0.0,
                                                       fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
            toViewController.view.frame = CGRectMake(0.0, toViewController.view.bounds.size.width,
                                                     toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                
                fromViewController.view.frame = CGRectMake(0.0, -fromViewController.view.bounds.size.width,
                                                           fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width);
                toViewController.view.frame = CGRectMake(0.0, 0.0,
                                                         toViewController.view.bounds.size.height, toViewController.view.bounds.size.width);
                
            } completion:^(BOOL finished) {
                
                [transitionContext completeTransition:YES];
            }];
        }
    }
}

@end
