//
//  STStatusHistoryTableViewCell.m
//  Status
//
//  Created by Joe Nguyen on 26/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <RACEXTScope.h>

#import "UIImageView+WebCache.h"
#import "UIColor+JNHelper.h"
#import "UIView+JNHelper.h"

#import "JNIcon.h"

#import "STStatusHistoryTableViewCell.h"
#import "STStatusComment.h"

@interface STStatusHistoryTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *commentImageView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;
@property (weak, nonatomic) IBOutlet UIButton *prevCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *nextCommentButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *nextCommentSpinnerView;

@property (nonatomic, copy) NSString *originalStatusCommentSenderName;
@property (nonatomic) NSInteger statusCommentsCurrentIndex;

@end

@implementation STStatusHistoryTableViewCell

- (void)awakeFromNib
{
    self.contentView.backgroundColor = JNBlackColor;
    
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.photoImageView.layer.masksToBounds = YES;
    
    self.commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.commentImageView.backgroundColor = JNClearColor;
    
    [self.footerView applyGradientBackgroundWithTopColor:[JNBlackColor colorWithAlphaComponent:0.6] bottomColor:JNClearColor];
    
    self.senderNameLabel.textColor = JNWhiteColor;
    self.senderNameLabel.text = nil;
    
    self.spinnerView.alpha = 0.0;
    
    FAKIonIcons *prevIcon = [FAKIonIcons ios7ArrowBackIconWithSize:40.0];
    [prevIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
    [self.prevCommentButton setAttributedTitle:prevIcon.attributedString forState:UIControlStateNormal];
    self.prevCommentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 14.0, 0.0);
//    [self.prevCommentButton.layer insertSublayer:[CALayer circleLayerWithSize:CGSizeMake(36.0, 36.0) strokeColor:nil fillColor:JNWhiteColor lineWidth:0.0] atIndex:0];
    [self.prevCommentButton.layer insertSublayer:[CALayer circleLayerWithSize:CGSizeMake(36.0, 36.0) position:CGPointMake(27.0, 18.0) strokeColor:nil fillColor:JNWhiteColor lineWidth:0.0] atIndex:0];
    [self.prevCommentButton applyDarkerShadowLayer];
    self.prevCommentButton.alpha = 0.0;
    [self.prevCommentButton addTarget:self action:@selector(prevAction:) forControlEvents:UIControlEventTouchUpInside];
    
    FAKIonIcons *nextIcon = [FAKIonIcons ios7ArrowForwardIconWithSize:40.0];
    [nextIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor]];
    [self.nextCommentButton setAttributedTitle:nextIcon.attributedString forState:UIControlStateNormal];
    self.nextCommentButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 14.0, 10.0);
    [self.nextCommentButton.layer insertSublayer:[CALayer circleLayerWithSize:CGSizeMake(36.0, 36.0) strokeColor:nil fillColor:JNWhiteColor lineWidth:0.0] atIndex:0];
    [self.nextCommentButton applyDarkerShadowLayer];
    self.nextCommentButton.alpha = 0.0;
    [self.nextCommentButton addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextCommentSpinnerView.alpha = 0.0;
    
    self.statusCommentsCurrentIndex = -1;
}

- (void)prepareForReuse
{
    self.photoImageView.image = nil;
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.commentImageView.image = nil;
    self.commentImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.senderNameLabel.text = nil;
    
    self.prevCommentButton.alpha = 0.0;
    
    self.nextCommentButton.alpha = 0.0;
    
    self.nextCommentSpinnerView.alpha = 0.0;
    
    self.statusCommentsCurrentIndex = -1;
    
    self.statusComments = nil;
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
    
    [self.photoImageView
     setImageWithURL:photoImageURL
     placeholderImage:nil
     options:SDWebImageRetryFailed
     progress:^(NSInteger receivedSize, NSInteger expectedSize) {
         ;
     }
     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
         [UIView animateWithBlock:^{
             self.spinnerView.alpha = 0.0;
         }];
         [self.spinnerView stopAnimating];
     }];
}

#pragma mark - Fetch Status Comments

- (void)fetchStatusCommentsWithStatusHistory:(STStatusHistory*)statusHistory
{
    [self.nextCommentSpinnerView startAnimating];
    [UIView animateWithBlock:^{
        self.nextCommentSpinnerView.alpha = 1.0;
    }];
    
    // fetch status comments
    PFQuery *query = [PFQuery queryWithClassName:@"StatusComment"];
    
    // cache
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    if (!query.hasCachedResult) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // where
    [query whereKey:@"parent" equalTo:statusHistory];
    
    // order
    [query orderByAscending:@"sentAt"];
    
    // find
    @weakify(self);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        runOnMainQueue(^{
            JNLogPrimitive(objects.count);
            if (error) {
                
                [JNLogger logExceptionWithName:THIS_METHOD reason:@"status comments get" error:error];
                
            } else {
                
                self_weak_.statusComments = objects;
                
                if (self_weak_.statusComments.count > 0) {
                    
                    [UIView animateWithBlock:^{
                        self_weak_.nextCommentButton.alpha = 1.0;
                    }];
                }
            }
            
            [self_weak_.nextCommentSpinnerView stopAnimating];
            [UIView animateWithBlock:^{
                self_weak_.nextCommentSpinnerView.alpha = 0.0;
            }];
        });
    }];
}

#pragma mark - Actions

- (void)prevAction:(id)sender
{
    if ([NSArray isEmptyArray:self.statusComments]) {
        return;
    }
    
    self.statusCommentsCurrentIndex--;
    
    if (self.statusCommentsCurrentIndex < 0) {
        
        [UIView animateWithBlock:^{
            self.commentImageView.alpha = 0.0;
            self.senderNameLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            
            self.commentImageView.image = nil;
            self.senderName = self.originalStatusCommentSenderName;
            
            [UIView animateWithBlock:^{
                
                self.senderNameLabel.alpha = 1.0;
                self.prevCommentButton.alpha = 0.0;
            }];
        }];
        
    } else {
        
        STStatusComment *statusComment = self.statusComments[self.statusCommentsCurrentIndex];
        PFFile *commentImageFile = statusComment[@"image"];
        NSURL *commentImageURL = [NSURL URLWithString:commentImageFile.url];
        
        @weakify(self);
        [self.commentImageView
         setImageWithURL:commentImageURL
         placeholderImage:nil
         options:SDWebImageRetryFailed
         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
         }
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
             
             self_weak_.commentImageView.image = image;
             self_weak_.commentImageView.alpha = 0.0;
             
             self_weak_.senderName = [NSString stringWithFormat:@"By %@", statusComment[@"senderName"]];
             self_weak_.senderNameLabel.alpha = 0.0;
             
             [UIView animateWithBlock:^{
                 self_weak_.commentImageView.alpha = 1.0;
                 self_weak_.senderNameLabel.alpha = 1.0;
             }];
         }];
    }

    if (self.statusCommentsCurrentIndex < 0) {
        
        [UIView animateWithBlock:^{
            self.prevCommentButton.alpha = 0.0;
        }];
        
//        self.statusCommentsCurrentIndex = 0;
    }
    
    [UIView animateWithBlock:^{
        self.nextCommentButton.alpha = 1.0;
    }];
    
}

- (void)nextAction:(id)sender
{
    if ([NSArray isEmptyArray:self.statusComments]) {
        return;
    }
    
    self.statusCommentsCurrentIndex++;
    
    if (self.statusCommentsCurrentIndex <= self.statusComments.count - 1) {
    
        STStatusComment *statusComment = self.statusComments[self.statusCommentsCurrentIndex];
        PFFile *commentImageFile = statusComment[@"image"];
        NSURL *commentImageURL = [NSURL URLWithString:commentImageFile.url];
        
        @weakify(self);
        [self.commentImageView
         setImageWithURL:commentImageURL
         placeholderImage:nil
         options:SDWebImageRetryFailed
         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
         }
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
             
             self_weak_.commentImageView.image = image;
             self_weak_.commentImageView.alpha = 0.0;
             
             if (!self_weak_.originalStatusCommentSenderName) {
                 self_weak_.originalStatusCommentSenderName = self_weak_.senderNameLabel.text;
             }
             self_weak_.senderName = [NSString stringWithFormat:@"By %@", statusComment[@"senderName"]];
             self_weak_.senderNameLabel.alpha = 0.0;
             
             [UIView animateWithBlock:^{
                 self_weak_.commentImageView.alpha = 1.0;
                 self_weak_.senderNameLabel.alpha = 1.0;
             }];
         }];
    }
    
    if (self.statusCommentsCurrentIndex >= self.statusComments.count - 1) {
        
        [UIView animateWithBlock:^{
            self.nextCommentButton.alpha = 0.0;
        }];
        
//        self.statusCommentsCurrentIndex = self.statusComments.count - 1;
    }
    
    [UIView animateWithBlock:^{
        self.prevCommentButton.alpha = 1.0;
    }];
}

@end
