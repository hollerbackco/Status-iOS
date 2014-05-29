//
//  STRightToLeftTransitionAnimator.m
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STRightToLeftTransitionAnimator.h"

@implementation STRightToLeftTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
//    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    [[transitionContext containerView] addSubview:toViewController.view];
//    toViewController.view.alpha = 0;
//    
//    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
//        fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1);
//        toViewController.view.alpha = 1;
//    } completion:^(BOOL finished) {
//        fromViewController.view.transform = CGAffineTransformIdentity;
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//        
//    }];
    
    
    // Grab the from and to view controllers from the context
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
//    // Set our ending frame. We'll modify this later if we have to
//    CGRect endFrame = CGRectMake(80, 280, 160, 100);
    
    if (self.presenting) {
        
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        fromViewController.view.frame = CGRectMake(0.0, 0.0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
        toViewController.view.frame = CGRectMake(-toViewController.view.bounds.size.width, 0.0, toViewController.view.bounds.size.width, toViewController.view.bounds.size.height);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.frame = CGRectMake(fromViewController.view.bounds.size.width, 0.0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
            toViewController.view.frame = CGRectMake(0.0, 0.0, toViewController.view.bounds.size.width, toViewController.view.bounds.size.height);
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        
        toViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        fromViewController.view.frame = CGRectMake(0.0, 0.0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
        toViewController.view.frame = CGRectMake(fromViewController.view.bounds.size.width, 0.0, toViewController.view.bounds.size.width, toViewController.view.bounds.size.height);
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.frame = CGRectMake(-fromViewController.view.bounds.size.width, 0.0, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
            toViewController.view.frame = CGRectMake(0.0, 0.0, toViewController.view.bounds.size.width, toViewController.view.bounds.size.height);
            
        } completion:^(BOOL finished) {
            
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
