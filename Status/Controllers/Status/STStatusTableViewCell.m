//
//  STStatusTableViewCell.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "UIColor+JNHelper.h"
#import "UIView+JNHelper.h"

#import "STStatusTableViewCell.h"

@interface STStatusTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;

@end

@implementation STStatusTableViewCell

- (void)awakeFromNib
{
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.layer.masksToBounds = YES;
    
    [self.footerView applyGradientBackgroundWithTopColor:JNClearColor bottomColor:[JNBlackColor colorWithAlphaComponent:0.5]];
    
    self.senderNameLabel.textColor = JNWhiteColor;
    self.senderNameLabel.text = nil;
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

@end
