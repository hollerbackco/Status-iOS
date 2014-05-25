//
//  STCaptionOverlayViewController.m
//  Status
//
//  Created by Joe Nguyen on 22/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNIcon.h"

#import "STCaptionOverlayViewController.h"

@interface STCaptionOverlayViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *captionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionTextViewBottomSpacingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionTextViewHeightConstraint;

- (IBAction)captionAction:(id)sender;

@end

@implementation STCaptionOverlayViewController

#pragma mark - Captions

+ (NSDictionary*)attributesForCaptionText
{
    return [self.class attributesForCaptionTextWithSize:kSTAttributesForCaptionTextFontSize];
}

+ (NSDictionary*)attributesForCaptionTextWithSize:(CGFloat)fontSize
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(-1.0, 1.0);
    shadow.shadowBlurRadius = 3.0;
    shadow.shadowColor = JNBlackColor;
    
    return @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:fontSize],
             NSForegroundColorAttributeName: JNWhiteColor,
             NSShadowAttributeName: shadow,
             NSParagraphStyleAttributeName: paragraphStyle};
}

+ (NSDictionary*)attributesForPlaceholderCaptionText
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(-1.0, 1.0);
    shadow.shadowBlurRadius = 1.0;
    shadow.shadowColor = JNGrayColor;
    
    return @{NSFontAttributeName: [UIFont fontWithName:@"Futura-Medium" size:kSTAttributesForCaptionTextFontSize],
             NSForegroundColorAttributeName: [JNWhiteColor colorWithAlphaComponent:0.5],
             NSShadowAttributeName: shadow,
             NSParagraphStyleAttributeName: paragraphStyle};
}

- (NSString*)getCaption
{
    return self.captionTextView.text;
}

- (void)resetCaption
{
    self.captionTextViewBottomSpacingConstraint.constant = kSTCaptionTextViewBottomSpacingConstraint;
    self.captionTextView.text = nil;
    self.captionTextView.attributedText = nil;
    self.captionTextView.alpha = 0.0;
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = JNClearColor;
    
    self.captionTextView.delegate = self;
    self.captionTextView.backgroundColor = [UIColor redColor];
    self.captionTextView.text = nil;
    self.captionTextView.typingAttributes = [self.class attributesForCaptionText];
    self.captionTextView.returnKeyType = UIReturnKeyDone;
    self.captionTextView.alpha = 0.0;
}

#pragma mark - Actions

- (IBAction)captionAction:(id)sender
{
    BOOL captionTextViewWasHidden = self.captionTextView.alpha == 0.0;
    
    [UIView animateWithBlock:^{
        
        if (captionTextViewWasHidden) {
            self.captionTextView.alpha = 1.0;
        }
    }];
        
    [self.captionTextView becomeFirstResponder];
    
    [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.captionTextView duration:UINavigationControllerHideShowBarDuration animations:^{
        self.captionTextViewBottomSpacingConstraint.constant = kSTCaptionTextViewBottomSpacingConstraint;
    } completion:^(BOOL finished) {
        ;
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *caption = textView.text;
    
    if ([NSString isNullOrEmptyString:caption]) {
        
        [UIView animateWithBlock:^{
            
            self.captionTextView.alpha = 0.0;
        }];
    } else {
        
        
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    
    if (text.length == 1 &&
        resultRange.location != NSNotFound) {
        
        [self didReturnOnTextView:textView];
        return NO;
        
    } else {
        
        if (text.length > 0) {
            
            NSString *fullText = [NSString stringWithFormat:@"%@%@", textView.text, text];
            
            if ([self.class isAtMaximumCaptionTextHeight:fullText textView:textView attributes:[self.class attributesForCaptionText]]) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.class isAtMaximumCaptionTextHeight:textView.text textView:textView attributes:[self.class attributesForCaptionText]]) {
        return;
    }
    
    if (textView.bounds.size.height != textView.contentSize.height) {
        
        [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.captionTextView duration:UINavigationControllerHideShowBarDuration animations:^{
            
            self.captionTextView.frame = CGRectSetHeight(self.captionTextView.frame, textView.contentSize.height);
            self.captionTextViewHeightConstraint.constant = textView.contentSize.height;
        }];
    }
}

+ (BOOL)isAtMaximumCaptionTextHeight:(NSString*)text textView:(UITextView*)textView attributes:(NSDictionary*)attributes
{
    CGRect rect =
    [text
     boundingRectWithSize:CGSizeMake(textView.bounds.size.width, MAXFLOAT)
     options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
     attributes:attributes
     context:nil];
    
    if (ceilf(rect.size.height) > kSTCaptionTextViewMaxTextSizeHeight) {
        
        return YES;
    }
    return NO;
}

- (void)didReturnOnTextView:(UITextView*)textView
{
    NSString *caption = textView.text;

    if ([NSString isNotEmptyString:caption]) {

        [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.captionTextView duration:UINavigationControllerHideShowBarDuration animations:^{
            
            self.captionTextViewBottomSpacingConstraint.constant = kSTCaptionTextViewBottomSpacingConstraint - kSTCaptionTextViewBottomSpacingConstraintOffset;
            
        } completion:^(BOOL finished) {
            ;
        }];

        if (self.didEnterCaptionBlock) {
            
            self.didEnterCaptionBlock(caption);
        }
    }
    
    [textView resignFirstResponder];
}

@end
