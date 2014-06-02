//
//  STSlideTransitionAnimator.h
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kSTSlideDirectionLeftToRight,
    kSTSlideDirectionRightToLeft
} kSTSlideDirection;

@interface STSlideTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL presenting;
@property (nonatomic) kSTSlideDirection slideDirection;

@end
