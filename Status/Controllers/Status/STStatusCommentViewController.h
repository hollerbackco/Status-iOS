//
//  STStatusCommentViewController.h
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNViewController.h"

#import "STStatus.h"

#define kSTDrawingLineWidth 5.0
#define kSTDrawingLineColor1 [UIColor redColor]
#define kSTDrawingLineColor2 [UIColor blueColor]
#define kSTDrawingLineColor3 [UIColor greenColor]
#define kSTDrawingLineColor4 [UIColor yellowColor]
#define kSTDrawingLineColor5 [UIColor whiteColor]

@interface STStatusCommentViewController : JNViewController

@property (nonatomic, strong) STStatus *status;

@end
