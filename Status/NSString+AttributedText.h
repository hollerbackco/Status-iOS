//
//  NSString+AttributedText.h
//
//  Created by nrj on 8/1/13.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface NSString (Attributed)

+ (NSAttributedString *)attributedText:(NSString *)text
                              withFont:(NSString *)fontName
                                  size:(CGFloat)fontSize
                                 color:(NSUInteger)color
                            lineHeight:(CGFloat)lineHeight;

+ (NSAttributedString *)attributedText:(NSString *)text
                              withFont:(NSString *)fontName
                                  size:(CGFloat)fontSize
                                 color:(NSUInteger)color
                            lineHeight:(CGFloat)lineHeight
                         textAlignment:(NSTextAlignment)alignment
                         lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
