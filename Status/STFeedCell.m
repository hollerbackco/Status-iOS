//
//  STFeedCell.m
//  Status
//
//  Created by Nick Jensen on 6/4/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIView+JNHelper.h"
#import "UIColor+JNHelper.h"
#import "UIFont+JNHelper.h"

#import "STFeedCell.h"

NSString * STFeedCellIdent = @"STFeedCellIdent";
CGSize const STFeedCellSize = { 284.0f, 160.0f };
CGSize const STFeedCell35Size = { 240.0f, 160.0f };
CGFloat const STFeedCellNameLabelHeight = 20.0;

@implementation STFeedCell

@synthesize imageView, imageURL, nameLabel, senderName;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin = CGPointZero;
        imageView = [[UIImageView alloc] initWithFrame:frame];
        [imageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        [self addSubview:imageView];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, STFeedCellNameLabelHeight)];
        footerView.center = CGPointMake(CGRectGetMidX(frame), frame.size.height - STFeedCellNameLabelHeight/2);
        footerView.backgroundColor = JNClearColor;
        [footerView applyTopHalfGradientBackgroundWithTopColor:JNClearColor bottomColor:JNBlackColor];
        footerView.clipsToBounds = YES;
        [self addSubview:footerView];
        
        nameLabel = [[UILabel alloc] initWithFrame:footerView.bounds];
        nameLabel.font = [UIFont primaryFontWithSize:14.0];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = JNWhiteColor;
        [footerView addSubview:nameLabel];
    }
    return self;
}

- (void)prepareForReuse
{
//    
}

- (void)setImageURL:(NSString *)newURL {
    
    if (![imageURL isEqualToString:newURL]) {
        
        imageURL = newURL;
        
        if (!imageURL) {
            
            [imageView setImage:nil];
        }
        else {
            
            NSURL *URL = [NSURL URLWithString:imageURL];
            NSAssert(URL != nil, @"invalid URL: %@", imageURL);
            __block UIImageView *weakImageView = imageView;
            [imageView setImageWithURL:URL placeholderImage:nil options:SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
                if (!error) {
                    
                    [weakImageView setImage:image];
                    
                    if (cacheType != SDImageCacheTypeMemory) {
                        
                        CATransition *transition = [CATransition animation];
                        [transition setDuration:0.3f];
                        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
                        [transition setType:kCATransition];
                        [transition setRemovedOnCompletion:YES];
                        [[weakImageView layer] addAnimation:transition forKey:nil];
                    }
                }
                else {
                    
                    [weakImageView setImage:nil];
                }
            }];
        }
    }
}

- (void)setSenderName:(NSString *)newSenderName
{
    if (![senderName isEqualToString:newSenderName]) {
        
        senderName = newSenderName;
        
        nameLabel.text = newSenderName;
    }
}


@end
