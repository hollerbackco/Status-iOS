//
//  STStatusHistoryTableViewCell.h
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STStatusHistory.h"

@interface STStatusHistoryTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, copy) NSURL *photoImageURL;
@property (nonatomic, copy) NSString *senderName;
@property (nonatomic, strong) NSArray *statusComments;

#pragma mark - Fetch Status Comments

- (void)fetchStatusCommentsWithStatusHistory:(STStatusHistory*)statusHistory;

@end
