//
//  STFeedViewController.m
//  Status
//
//  Created by Nick Jensen on 6/4/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STFeedViewController.h"

@implementation STFeedViewController

@synthesize collectionView;

- (void)loadView {
    
    [super loadView];
    
    CGRect bounds = [[self view] bounds];
    
    UICollectionViewFlowLayout *layout;
    layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setItemSize:CGSizeMake(0.5 * bounds.size.width, 0.5 * bounds.size.height)];
}

@end
