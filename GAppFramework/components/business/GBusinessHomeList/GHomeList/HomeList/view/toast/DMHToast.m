//
//  DMHToast.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/20.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHToast.h"
#import <GBaseLib/GConvenient.h>

@implementation DMHToast

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (void)toast:(NSString *)msg view:(UIView *)view y:(CGFloat)y {
    UIView *toast = [[self alloc] initWithFrame:CGRectMake(0, y, 0, 0) model:msg action:nil];
    [view addSubview:toast];
    [UIView animateWithDuration:0.2 animations:^{
        toast.alpha = 1;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.2 animations:^{
            toast.alpha = 0;
        } completion:^(BOOL finished) {
            [toast removeFromSuperview];
        }];
    });
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(NSString *)model action:(AActionBlock)action {
    CGFloat w = model.length * 14 + 48;
    CGRect rect = CGRectMake((SCREEN_WIDTH-w)/2, frame.origin.y, w, 34);
    if (self = [super initWithFrame:rect]) {
        self.alpha = 0;
        
        self.layer.shadowColor = [HEX(@"000000") colorWithAlphaComponent:0.2].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 1;
        
        [self addGradientLayer];
        [self addMessage:model];
    }
    return self;
}

- (void)addGradientLayer {
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    layer.colors = @[(__bridge id)HEX(@"FFE500", @"FFBB00").CGColor,(__bridge id)HEX(@"FFCC00").CGColor];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(1, 0);
    layer.cornerRadius = 17;
    layer.masksToBounds = YES;
    [self.layer addSublayer:layer];
}

- (void)addShadowLayer {
    CALayer *subLayer = [CALayer layer];
    subLayer.frame= self.bounds;
    subLayer.cornerRadius = 15;
    subLayer.masksToBounds = NO;
    subLayer.shadowColor = [UIColor blackColor].CGColor;
    subLayer.shadowOffset = CGSizeMake(0,2);
    subLayer.shadowOpacity = 0.2;
    subLayer.shadowRadius = 10;
    [self.layer addSublayer:subLayer];
}

- (void)addMessage:(NSString *)msg {
    UILabel *label = [UILabel new];
    label.frame = self.bounds;
    label.textColor = HEX(@"404040");
    label.font = FONT(14);
    label.text = msg;
    label.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:label];
}


@end
