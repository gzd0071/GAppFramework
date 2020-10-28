//
//  GConvenient.m
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/9/4.
//

#import "GConvenient.h"
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/UIGestureRecognizer+RACSignalSupport.h>
#import <ReactiveObjC/UIControl+RACSignalSupport.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>

@implementation GConvenient
- (void)convenient {
    
}
///> 解析 URI 参数 
+ (NSDictionary *)paraDict:(NSString *)para {
    if (!para) return nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *arr = [para componentsSeparatedByString:@"&"];
    [arr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        NSArray *keyValue = [obj componentsSeparatedByString:@"="];
        NSString *key = keyValue.firstObject ? [keyValue.firstObject stringByRemovingPercentEncoding] :@"";
        NSString *value = [keyValue.lastObject?:@"" stringByRemovingPercentEncoding];
        [dict setValue:value forKey:key];
    }];
    return dict;
}
+ (NSString *)urlByAppendingDict:(NSString *)urlS params:(NSDictionary *)params {
    if (![params isKindOfClass:NSDictionary.class] || params.count == 0) return urlS;
    NSURL *url = [NSURL URLWithString:urlS];
    NSString *queryPrefix = url.query ? @"&" : @"?";
    NSString *query = [self queryStringFromDictionary:params];
    return [NSString stringWithFormat:@"%@%@%@", urlS, queryPrefix, query];
}
+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict {
    NSMutableArray *pairs = [NSMutableArray array];
    [dict.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSString *value = dict[key];
        if (![value isKindOfClass:[NSString class]]) return;
        NSString *urlValue = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, urlValue]];
    }];
    return [pairs componentsJoinedByString:@"&"];
}
+ (NSString *)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%.0f", time];
}
+ (UIImageView *)imageView:(UIImage *)img {
    UIImageView *imgV = [UIImageView new];
    imgV.image = img;
    return imgV;
}
+ (UILabel *)label:(NSString *)txt color:(UIColor *)color font:(UIFont *)font {
    UILabel *label = [UILabel new];
    label.text = txt;
    label.font = font;
    label.textColor = color;
    return label;
}
+ (CGFloat)distance:(CGFloat)lat1 lng1:(CGFloat)lng1 lat2:(CGFloat)lat2 lng2:(CGFloat)lng2 {
    CGFloat r1 = lat1*M_PI/180.0;
    CGFloat r2 = lat2*M_PI/180.0;
    CGFloat a = r1 - r2;
    CGFloat b = lng1*M_PI/180.0 - lng2*M_PI/180.0;
    CGFloat s = 2 * sin(sqrt(pow(sin(a/2.0), 2)+cos(r1)*cos(r2)*pow(sin(b/2.0), 2)));
    s = s * 6378.137;
    s = round(s*10000000)/10000;
    return s;
}
@end

@implementation UIView (GConvenient)
#pragma mark - SETTERS
///=============================================================================
/// @name SETTERS
///=============================================================================
#define kUPDATE_FRAME(A)  CGRect frame = self.frame; A(frame); self.frame = frame;
- (void)setX:(CGFloat)x           { kUPDATE_FRAME(^(CGRect frame){ frame.origin.x = x; }); }
- (void)setY:(CGFloat)y           { kUPDATE_FRAME(^(CGRect frame){ frame.origin.y = y; }); }
- (void)setWidth:(CGFloat)width   { kUPDATE_FRAME(^(CGRect frame){ frame.size.width = width; }); }
- (void)setHeight:(CGFloat)height { kUPDATE_FRAME(^(CGRect frame){ frame.size.height = height; }); }
- (void)setSize:(CGSize)size      { kUPDATE_FRAME(^(CGRect frame){ frame.size = size; }); }
- (void)setOrigin:(CGPoint)origin { kUPDATE_FRAME(^(CGRect frame){ frame.origin = origin; }); }
- (void)setTop:(CGFloat)top       { kUPDATE_FRAME(^(CGRect frame){ frame.origin.y = top; }); }
- (void)setLeft:(CGFloat)left     { kUPDATE_FRAME(^(CGRect frame){ frame.origin.x = left; }); }
- (void)setBottom:(CGFloat)bottom { kUPDATE_FRAME(^(CGRect frame){ frame.origin.y = bottom - frame.size.height; }); }
#undef kUPDATE_FRAME
#define kUPDATE_CENTER(A)  CGPoint center = self.center; A(center); self.center = center;
- (void)setCenterY:(CGFloat)centerY { kUPDATE_CENTER(^(CGPoint center){ center.y = centerY; }); }
- (void)setCenterX:(CGFloat)centerX { kUPDATE_CENTER(^(CGPoint center){ center.x = centerX; }); }
#undef kUPDATE_CENTER
- (void)setRight:(CGFloat)right  {
    CGFloat delta = right - (self.frame.origin.x + self.frame.size.width);
    CGRect newframe = self.frame;
    newframe.origin.x += delta ;
    self.frame = newframe;
}
#pragma mark - GETTERS
///=============================================================================
/// @name GETTERS
///=============================================================================
- (CGFloat)x       { return self.frame.origin.x; }
- (CGFloat)y       { return self.frame.origin.y; }
- (CGFloat)centerX { return self.center.x; }
- (CGFloat)centerY { return self.center.y; }
- (CGFloat)height  { return self.frame.size.height; }
- (CGFloat)width   { return self.frame.size.width; }
- (CGSize)size     { return self.frame.size; }
- (CGPoint)origin  { return self.frame.origin; }
- (CGFloat)top     { return self.frame.origin.y; }
- (CGFloat)left    { return self.frame.origin.x; }
- (CGFloat)bottom  { return self.frame.origin.y + self.frame.size.height; }
- (CGFloat)right   { return self.frame.origin.x + self.frame.size.width; }

- (UITapGestureRecognizer *)addTapGesture:(AActionBlock)action {
    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
    [tap.rac_gestureSignal subscribeNext:^(__kindof UIGestureRecognizer *x) {
        if (action) action(x);
    }];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
    return tap;
}
@end

@implementation UIControl (GConvenient)
- (void)addEvents:(UIControlEvents)event action:(AActionBlock)action {
    [[self rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (action) action(x);
    }];
}
@end
