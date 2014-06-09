//
//  STFeedCell.m
//  Status
//
//  Created by Nick Jensen on 6/4/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STFeedCell.h"

NSString * STFeedCellIdent = @"STFeedCellIdent";
CGSize const STFeedCellSize = { 284.0f, 160.0f };

@implementation STFeedCell

@synthesize imageView, imageURL;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin = CGPointZero;
        imageView = [[UIImageView alloc] initWithFrame:frame];
        [imageView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [imageView setClipsToBounds:YES];
        [self addSubview:imageView];
    }
    return self;
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


@end
