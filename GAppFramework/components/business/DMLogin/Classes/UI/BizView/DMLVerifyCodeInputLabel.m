//
//  DMLVerifyCodeInputLabel.m
//  DMLVerifyCodeInputLabel
//
//  Created by tangjin on 2018/11/21.
//  Copyright © 2018年 tangjin. All rights reserved.
//

#import "DMLVerifyCodeInputLabel.h"
#import "UIView+LoginUIViewPosition.h"
#define kFlickerAnimation @"kFlickerAnimation"

//设置边框宽度，值越大，边框越粗
#define ADAPTER_RATE_WIDTH 1
//设置是否有边框，等于 1 时 是下划线  大于1 的时候随着值越大，边框越大，
#define ADAPTER_RATE_HIDTH 1
@implementation DMLVerifyCodeInputLabel

//重写setText方法，当text改变时手动调用drawRect方法，将text的内容按指定的格式绘制到label上
- (void)setText:(NSString *)text {
    [super setText:text];
    if (text.length == self.numberOfVertificationCode)
    {
        [self viewWithTag:999].hidden = YES;
    }
    // 手动调用drawRect方法
    [self setNeedsDisplay];
}

// 按照指定的格式绘制验证码/密码
- (void)drawRect:(CGRect)rect1 {
    //计算每位验证码/密码的所在区域的宽和高
    CGRect rect =CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height);
    float width = rect.size.width / (float)self.numberOfVertificationCode;
    float height = rect.size.height;
    // 将每位验证码/密码绘制到指定区域
    
    //绘制底部横线
    for (int k=0; k<self.numberOfVertificationCode; k++) {
        [self drawBottomLineWithRect:rect andIndex:k];
        [self drawSenterLineWithRect:rect andIndex:k];
    }
    
    for (int i =0; i <self.text.length; i++) {
        // 计算每位验证码/密码的绘制区域
        CGRect tempRect =CGRectMake(i * width,0, width, height);
        if (_secureTextEntry) {//密码，显示圆点
            UIImage *dotImage = [UIImage imageNamed:@"dot"];
            // 计算圆点的绘制区域
            CGPoint securityDotDrawStartPoint =CGPointMake(width * i + (width - dotImage.size.width) /2.0, (tempRect.size.height - dotImage.size.height) / 2.0);
            // 绘制圆点
            [dotImage drawAtPoint:securityDotDrawStartPoint];
        } else {//验证码，显示数字
            // 遍历验证码/密码的每个字符
            NSString *charecterString = [NSString stringWithFormat:@"%c", [self.text characterAtIndex:i]];
            // 设置验证码/密码的现实属性
            NSMutableDictionary *attributes = [[NSMutableDictionary alloc]init];
            attributes[NSFontAttributeName] =self.font;
            
#ifdef __IPHONE_13_0
            //iOS13 适配
            if (@available(ios 13, *)) {
            attributes[NSForegroundColorAttributeName] = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1/1.0];
            } else {
                return UIColor.blackColor;
            }}];
            }
#endif
            // 计算每位验证码/密码的绘制起点（为了使验证码/密码位于tempRect的中部，不应该从tempRect的重点开始绘制）
            // 计算每位验证码/密码的在指定样式下的size
            CGSize characterSize = [charecterString sizeWithAttributes:attributes];
            CGPoint vertificationCodeDrawStartPoint =CGPointMake(width * i + (width - characterSize.width) /2.0, (tempRect.size.height - characterSize.height) /2.0);
            // 绘制验证码/密码
            [charecterString drawAtPoint:vertificationCodeDrawStartPoint withAttributes:attributes];
        }
    }
 
}

//绘制背景框
- (void)drawBottomLineWithRect:(CGRect)rect1 andIndex:(int)k{
    CGRect rect =CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height);
    float width = rect.size.width / (float)self.numberOfVertificationCode;
    float height = rect.size.height;
    //1.获取上下文
    CGContextRef context =UIGraphicsGetCurrentContext();
    //2.设置当前上下问路径
    CGFloat lineHidth =0.25 * ADAPTER_RATE_WIDTH;
    CGContextSetLineWidth(context, lineHidth);
    CGColorRef color = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;//单个数字方框 背景色

#ifdef __IPHONE_13_0
    //iOS13 适配
    if (@available(ios 13, *)) {
        color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithRed:38/255.0 green:38/255.0 blue:40/255.0 alpha:1/1.0];
            } else {
                return [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
            }
        }].CGColor;
    }
#endif
    CGContextSetFillColorWithColor(context,color);//填充颜色

    
    CGRect rectangle =CGRectMake(k*width+width/10,0,width-width/5,height);
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:rectangle cornerRadius:3].CGPath;
    CGContextAddPath(context, clippath);
    CGContextFillPath(context);

}
//绘制中间的输入的线条
- (void)drawSenterLineWithRect:(CGRect)rect1 andIndex:(int)k{
    if ( k==self.text.length ) {
        CGRect rect =CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height);
        float width = rect.size.width / (float)self.numberOfVertificationCode;
        float height = rect.size.height;
        
        UIView *lineView = [self viewWithTag:999];
        if (!lineView)
        {
            lineView = [[UIView alloc] init];
            lineView.tag = 999;
            [self addSubview:lineView];
        }
        lineView.hidden = NO;
        lineView.backgroundColor = [UIColor colorWithRed:102/255.0 green:153/255.0 blue:238/255.0 alpha:1/1.0];//✔️ 暗黑模式不变色
        lineView.DL_y = 14.f;
        lineView.DL_x = width * k + (width -2.0) /2.0;
        lineView.DL_width = 2.f;
        lineView.DL_height = height - 28.f;
        lineView.layer.cornerRadius = 1.f;
        [lineView.layer addAnimation:[self xx_alphaAnimation] forKey:kFlickerAnimation];

    }
}

- (CABasicAnimation *)xx_alphaAnimation{
    CABasicAnimation *alpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpha.fromValue = @(1.0);
    alpha.toValue = @(0.0);
    alpha.duration = 1.0;
    alpha.repeatCount = CGFLOAT_MAX;
    alpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return alpha;
}

@end
