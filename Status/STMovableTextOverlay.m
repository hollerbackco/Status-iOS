//
//  STMovableTextOverlay.m
//  Status
//
//  Created by Nick Jensen on 6/3/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STMovableTextOverlay.h"
#import "NSString+AttributedText.h"

@implementation STMovableTextOverlay

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {

        textField = [[UITextView alloc] init];
        [textField setBackgroundColor:[UIColor clearColor]];
        [textField setTextColor:[UIColor whiteColor]];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textField setReturnKeyType:UIReturnKeyDone];
        [textField setScrollEnabled:NO];
        [textField setClipsToBounds:NO];
        [textField setDelegate:self];

        [[textField layer] setShadowColor:[[UIColor blackColor] CGColor]];
        [[textField layer] setShadowOffset:CGSizeZero];
        [[textField layer] setShadowOpacity:0.7f];
        [[textField layer] setShadowRadius:10.0f];
        
        [self addSubview:textField];
        
        UITapGestureRecognizer *dismissTap;
        dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self addGestureRecognizer:dismissTap];
        
        UIPanGestureRecognizer *panGesture;
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardHandler:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardHandler:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];        
    }
    return self;
}

- (void)centerText {
    
    CGRect bounds = [self bounds];
    CGRect textRect = [textField frame];
    textRect.origin.x = floor(0.5 * (bounds.size.width - textRect.size.width));
    textRect.origin.y = floor(0.5 * (bounds.size.height - textRect.size.height));
    [textField setFrame:textRect];
    hasBeenMovedByUser = NO;
}

- (void)keyboardHandler:(NSNotification *)notification {
    
    BOOL willShow = ([notification name] == UIKeyboardWillShowNotification);
    
    NSDictionary *userInfo;
    userInfo = [notification userInfo];

    UIViewAnimationOptions animationCurve;
    [[userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    animationCurve = animationCurve << 16;
    
    NSTimeInterval animationDuration;
    [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    CGRect keyboardRect;
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardRect];
    keyboardRect = [self convertRect:keyboardRect fromView:nil];
    
    keyboardHeight = (willShow) ? keyboardRect.size.height : 0.0f;
    
    CGRect textRect = [textField frame];
    BOOL shouldMoveText = NO;
    
    if (willShow && CGRectGetMaxY(textRect) > keyboardHeight) {

        lastTextFieldLocationBeforeKeyboard = textRect.origin;
        textRect.origin.y = CGRectGetMinY(keyboardRect) - CGRectGetHeight(textRect);
        shouldMoveText = YES;
    }
    else if (!willShow && !CGPointEqualToPoint(CGPointZero, lastTextFieldLocationBeforeKeyboard)) {

        textRect.origin = lastTextFieldLocationBeforeKeyboard;
        lastTextFieldLocationBeforeKeyboard = CGPointZero;
        shouldMoveText = YES;
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationCurve
                     animations:^{

                         [textField setFrame:textRect];
                     }
                     completion:^(BOOL finished) {
        
                         if (selectTextAfterNextKeyboard) {

                             selectTextAfterNextKeyboard = NO;
                             [textField selectAll:nil];
                         }
                     }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setText:(NSString *)text {
    
    if (![[textField text] isEqualToString:text]) {
        
        NSAttributedString *attrText;
        attrText = [NSString attributedText:text ?: @"" withFont:@"HelveticaNeue-Medium" size:30.0f color:0xFFFFFF lineHeight:35.0f];
        [textField setAttributedText:attrText];
        [self textViewDidChange:textField];
    }
}

- (BOOL)isEditing {
    
    return [textField isFirstResponder];
}

- (NSString *)text {
    
    return [textField text] ?: @"";
}

- (void)beginEditing:(BOOL)selectText {
    
    if (![textField isFirstResponder]) {
        
        selectTextAfterNextKeyboard = selectText;
        
        [textField becomeFirstResponder];
    }
}

- (void)dismiss {
    
    if ([textField isFirstResponder]) {
        
        [textField resignFirstResponder];
        [textField setSelectedTextRange:nil];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
 
    BOOL didReturn = [text isEqualToString:@"\n"];
    
    if (didReturn) {
        
        [self dismiss];
    }
    
    return !didReturn;
}

- (BOOL)isDraggingTextField:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan locationInView:self];
    CGRect textRect = CGRectInset([textField frame], -50.0f, -50.0f);
    return CGRectContainsPoint(textRect, point);
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)pan {
    
    if ([self isDraggingTextField:pan] && ![textField isFirstResponder]) {

        CGRect bounds = [self bounds];
        CGRect textRect = [textField frame];
        CGPoint panLocation = [pan translationInView:self];
        CGFloat newPosX = 0.0f, newPosY = 0.0f;
        
        if ([pan state] == UIGestureRecognizerStateBegan ||
            [pan state] == UIGestureRecognizerStateChanged) {
            
            if ([pan state] == UIGestureRecognizerStateBegan) {
             
                lastTextFieldLocation = textRect.origin;
            }
            
            newPosX = lastTextFieldLocation.x + panLocation.x;
            textRect.origin.x = CLAMP(newPosX, 0.0f, bounds.size.width - textRect.size.width);
            newPosY = lastTextFieldLocation.y + panLocation.y;
            textRect.origin.y = CLAMP(newPosY, 0.0f, bounds.size.height - textRect.size.height);
            
            [textField setFrame:textRect];

            hasBeenMovedByUser = YES;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView {

    CGRect bounds = [self bounds];
    CGRect textRect = [textField frame];
    
    CGSize maxTextSize;
    maxTextSize.width = CGRectGetWidth(bounds) - CGRectGetMinX(textRect);
    maxTextSize.height = CGRectGetHeight(bounds) - CGRectGetMinY(textRect);
    textRect.size = [textField sizeThatFits:maxTextSize];
    
    if (textRect.size.width < STMovableTextOverlayMinWidth) {

        textRect.size.width = STMovableTextOverlayMinWidth;
    }
    
    if (keyboardHeight > 0.0f && CGRectGetMaxY(textRect) > keyboardHeight) {
        
        CGFloat newY = (bounds.size.height - textRect.size.height - keyboardHeight);
        
        if (!CGPointEqualToPoint(CGPointZero, lastTextFieldLocationBeforeKeyboard)) {

            CGFloat diffY = newY - textRect.origin.y;
            lastTextFieldLocationBeforeKeyboard.y += diffY;
        }
        
        textRect.origin.y = newY;
    }
    
    if (!hasBeenMovedByUser) {
        
        textRect.origin.x = floor(0.5 * (bounds.size.width - textRect.size.width));

        if (!CGPointEqualToPoint(CGPointZero, lastTextFieldLocationBeforeKeyboard)) {
            
            lastTextFieldLocationBeforeKeyboard.x = textRect.origin.x;
        }
    }
    
    [textField setFrame:textRect];
}

@end
