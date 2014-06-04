//
//  STMovableTextOverlay.h
//  Status
//
//  Created by Nick Jensen on 6/3/14.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat STMovableTextOverlayMinWidth = 50.0f;

@interface STMovableTextOverlay : UIView <UITextViewDelegate> {
    
    UITextView *textField;
    CGPoint lastTextFieldLocation;
    CGPoint lastTextFieldLocationBeforeKeyboard;
    CGFloat keyboardHeight;
    BOOL selectTextAfterNextKeyboard;
    BOOL hasBeenMovedByUser;
}

- (void)setText:(NSString *)text;
- (NSString *)text;
- (BOOL)isEditing;

- (void)centerText;
- (void)beginEditing:(BOOL)selectText;
- (void)dismiss;

@end