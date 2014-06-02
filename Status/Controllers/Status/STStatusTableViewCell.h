//
//  STStatusTableViewCell.h
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STStatusTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, copy) NSURL *photoImageURL;
@property (nonatomic, copy) NSString *senderName;
@property (nonatomic, copy) void(^didTapComposeOnCell)(STStatusTableViewCell *cell);

@end
