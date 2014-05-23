//
//  STStatusTableViewCell.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "UIColor+JNHelper.h"
#import "UIView+JNHelper.h"

#import "STStatusTableViewCell.h"

@interface STStatusTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;

@end

@implementation STStatusTableViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = JNBlackColor;
    
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.layer.masksToBounds = YES;
    
    [self.footerView applyGradientBackgroundWithTopColor:[JNBlackColor colorWithAlphaComponent:0.6] bottomColor:JNClearColor];
    
    self.senderNameLabel.textColor = JNWhiteColor;
    self.senderNameLabel.text = nil;
    
    self.spinnerView.alpha = 0.0;
}

- (void)prepareForReuse
{
    self.photoImageView.image = nil;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.senderNameLabel.text = nil;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Properties

- (void)setSenderName:(NSString *)senderName
{
    self.senderNameLabel.text = senderName;
}

- (void)setPhotoImage:(UIImage *)photoImage
{
    self.photoImageView.image = photoImage;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.layer.masksToBounds = YES;
}

- (void)setPhotoImageURL:(NSURL *)photoImageURL
{
    if (![[SDWebImageManager sharedManager] diskImageExistsForURL:photoImageURL]) {
        [UIView animateWithBlock:^{
            self.spinnerView.alpha = 1.0;
        }];
        [self.spinnerView startAnimating];
    }
    
    [self.photoImageView setImageWithURL:photoImageURL placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        ;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [UIView animateWithBlock:^{
            self.spinnerView.alpha = 0.0;
        }];
        [self.spinnerView stopAnimating];
    }];
}

@end
