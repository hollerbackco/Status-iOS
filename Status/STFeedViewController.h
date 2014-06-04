//
//  STFeedViewController.h
//  Status
//
//  Created by Nick Jensen on 6/4/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageManager.h>

@interface STFeedViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate> {
    
    BOOL isRefreshing;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *statuses;

@end
