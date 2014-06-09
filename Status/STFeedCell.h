//
//  STFeedCell.h
//  Status
//
//  Created by Nick Jensen on 6/4/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

extern NSString * STFeedCellIdent;
extern const CGSize STFeedCellSize;

@interface STFeedCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) NSString *senderName;

@end
