//
//  GTextView.m
//  GUILib
//
//  Created by iOS_Developer_G on 2019/11/23.
//

#import "GTextView.h"

@implementation GTextView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.holderColor = [UIColor grayColor];
        self.font =[UIFont systemFontOfSize:[UIFont systemFontSize]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)textDidChange:(NSNotification *)noti {
    [self setNeedsDisplay];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(CGRect)rect {
    if (self.hasText) return;
    rect.origin.x = 5;
    rect.origin.y = 8;
    rect.size.width -= 2*rect.origin.x;
    if (self.attributeHolder) {
        [self.attributeHolder drawInRect:rect];
    } else {
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSFontAttributeName] = self.font;
        attr[NSForegroundColorAttributeName] = self.holderColor;
        [self.holder drawInRect:rect withAttributes:attr];
    }
}

#pragma mark - Setters
///=============================================================================
/// @name Setters
///=============================================================================

- (void)setHolder:(NSString *)holder {
    _holder = [holder copy];
    [self setNeedsDisplay];
}

- (void)setHolderFont:(UIFont *)holderFont {
    _holderFont = holderFont;
    [self setNeedsDisplay];
}

- (void)setHolderColor:(UIColor *)holderColor {
    _holderColor = holderColor;
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}
@end
