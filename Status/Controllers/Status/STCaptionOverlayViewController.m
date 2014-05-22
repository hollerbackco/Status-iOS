//
//  STCaptionOverlayViewController.m
//  Status
//
//  Created by Joe Nguyen on 22/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "JNIcon.h"

#import "STCaptionOverlayViewController.h"

@interface STCaptionOverlayViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *captionTextFieldBottomSpacingConstraint;

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
    return self.captionTextField.text;
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = JNClearColor;
    
    self.captionTextField.delegate = self;
    self.captionTextField.backgroundColor = JNClearColor;
    self.captionTextField.text = nil;
//    self.captionTextField.font = [UIFont primaryFontWithSize:30.0];
//    self.captionTextField.textColor = JNWhiteColor;
//    self.captionTextField.layer.shadowColor = JNBlackColor.CGColor;
//    self.captionTextField.layer.shadowOffset = CGSizeMake(-1.0, 1.0);
//    self.captionTextField.layer.shadowOpacity = 1.0;
//    self.captionTextField.layer.shadowRadius = 1.0;
    self.captionTextField.defaultTextAttributes = [self.class attributesForCaptionText];
    self.captionTextField.attributedPlaceholder = [[NSAttributedString alloc]
                                                   initWithString:@"SAY SOMETHING"
                                                   attributes:[self.class attributesForPlaceholderCaptionText]];
    self.captionTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.captionTextField.minimumFontSize = 10.0;
    self.captionTextField.adjustsFontSizeToFitWidth = YES;
    self.captionTextField.alpha = 0.0;
}

#pragma mark - Actions

- (IBAction)captionAction:(id)sender
{
    BOOL captionTextFieldWasHidden = self.captionTextField.alpha == 0.0;
    
    [UIView animateWithBlock:^{
        
        if (captionTextFieldWasHidden) {
            self.captionTextField.alpha = 1.0;
        } else {
            self.captionTextField.alpha = 0.0;
        }
    }];
    
    if (captionTextFieldWasHidden) {
        
        [self.captionTextField becomeFirstResponder];
        
        [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.captionTextField duration:UINavigationControllerHideShowBarDuration animations:^{
            self.captionTextFieldBottomSpacingConstraint.constant = kSTCaptionTextFieldBottomSpacingConstraint;
        } completion:^(BOOL finished) {
            ;
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *caption = textField.text;
    
    if ([NSString isNotEmptyString:caption]) {
        
        [UIView animateLayoutConstraintsWithContainerView:self.view childView:self.captionTextField duration:UINavigationControllerHideShowBarDuration animations:^{
            self.captionTextFieldBottomSpacingConstraint.constant = kSTCaptionTextFieldBottomSpacingConstraint - kSTCaptionTextFieldBottomSpacingConstraintOffset;
        } completion:^(BOOL finished) {
            ;
        }];
        
        if (self.didEnterCaptionBlock) {
            self.didEnterCaptionBlock(caption);
        }
    }
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
