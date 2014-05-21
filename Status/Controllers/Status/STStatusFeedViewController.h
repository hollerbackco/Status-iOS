//
//  STStatusFeedViewController.h
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNViewController.h"

@interface STStatusFeedViewController : JNViewController

@property (nonatomic, strong) UIImage *placeholderImage;

- (void)performCreateStatusWithImage:(UIImage*)image;

@end
