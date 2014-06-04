//
//  NSString+AttributedText.m
//
//  Created by nrj on 8/1/13.
//

#import "NSString+AttributedText.h"

@implementation NSString (Attributed)

+ (NSAttributedString *)attributedText:(NSString *)text
                              withFont:(NSString *)fontName
                                  size:(CGFloat)fontSize
                                 color:(NSUInteger)color
                            lineHeight:(CGFloat)lineHeight {
    
    return [self attributedText:text
                       withFont:fontName
                           size:fontSize
                          color:color
                     lineHeight:lineHeight
                  textAlignment:NSTextAlignmentLeft
                  lineBreakMode:NSLineBreakByWordWrapping];
}

+ (NSAttributedString *)attributedText:(NSString *)text
                              withFont:(NSString *)fontName
                                  size:(CGFloat)fontSize
                                 color:(NSUInteger)color
                            lineHeight:(CGFloat)lineHeight
                         textAlignment:(NSTextAlignment)alignment
                         lineBreakMode:(NSLineBreakMode)lineBreakMode {

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setAlignment:alignment];
    [paragraphStyle setLineBreakMode:lineBreakMode];
    [paragraphStyle setMaximumLineHeight:lineHeight];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)[UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                           (id)UIColorFromRGB(color), NSForegroundColorAttributeName,
                           [NSNumber numberWithFloat:0.0], NSKernAttributeName,
                           [NSNumber numberWithFloat:0.0], NSBaselineOffsetAttributeName,
                           (id)paragraphStyle, NSParagraphStyleAttributeName,
                           nil];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attrs];
}

@end
