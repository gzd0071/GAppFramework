//
//  GConvenient.h
//  GBaseLib
//
//  Created by iOS_Developer_G on 2019/9/4.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/RACEXTScope.h>
#import <ReactiveObjC/RACTuple.h>
#import "UIColor+Extend.h"
#import "NSString+Extend.h"
#import "NSDictionary+Extend.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIViewController+DMExtend.h"
#import <GTask/GTaskResult.h>

NS_ASSUME_NONNULL_BEGIN

#if defined(__IPHONE_13_0)
#define A_IOS13_SDK (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
#else
#define A_IOS13_SDK NO
#endif

#define FORMAT(A, ...)   [NSString stringWithFormat:A, __VA_ARGS__]
#define HALFPixal        (1.0/[UIScreen mainScreen].scale)
#define SCREEN_WIDTH     ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT    ([[UIScreen mainScreen] bounds].size.height)
#define ISNARROW         (SCREEN_WIDTH==320)
#define NARROW_RATE      0.85

#define HEX(...) metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__)) \
    (_HEX_1(__VA_ARGS__)) \
    (_HEX(__VA_ARGS__))
/// 图片: 暗黑自动适配宏, 缺点, scale有问题
#define IMAGE(...)  metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__)) \
    (_IMAGE_1(__VA_ARGS__)) \
    (_IMAGE(__VA_ARGS__))
/// 图片: 暗黑适配宏, 无自动适配
#define IMAGE_ND(...)  metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__)) \
    (_IMAGE_1(__VA_ARGS__)) \
    (_IMAGE_ND(__VA_ARGS__))
#define FONT(A)          [UIFont systemFontOfSize:(ISNARROW?(A*NARROW_RATE):A)]
#define FONT_BOLD(A)     [UIFont boldSystemFontOfSize:(ISNARROW?(A*NARROW_RATE):A)]
#define PAD(A)           (ISNARROW?A*NARROW_RATE:A)
#define IPHONE_X         (SCREEN_HEIGHT >= 812.0)
#define INDICATOR_HEIGHT (IPHONE_X?34:0)
#define STATUSBAR_HEIGHT [[UIApplication sharedApplication] statusBarFrame].size.height
#define TABBAR_HEIGHT    49
#define NAVIBAR_HEIGHT   44
#define NAVI_HEIGHT      (NAVIBAR_HEIGHT+STATUSBAR_HEIGHT)

#define URL_ADD_PARAMS(A, B) [GConvenient urlByAppendingDict:A params:B]


#define _HEX_1(A) ({ \
    UIColor *c; \
    if ([A isKindOfClass:NSString.class]) { \
        c = [UIColor hexString:(NSString *)A]; \
    } else { \
        UIColor *(^action)(void) = (id)A; \
        c = action(); \
    } \
    c; \
})
#if A_IOS13_SDK
#define _HEX(static, dynamic) ({ \
    UIColor *c; \
    if (@available(iOS 13.0, *)) { \
        c = [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) { \
            switch (traitCollection.userInterfaceStyle) { \
                case UIUserInterfaceStyleDark: \
                    return _HEX_1(dynamic); \
                default: \
                    return _HEX_1(static); \
            } \
        }]; \
    } else { \
        c = _HEX_1(static); \
    } \
    c; \
})
#else
#define _HEX(static, dynamic) _HEX_1(static)
#endif

#define _IMAGE_1(static) ([(static) isKindOfClass:UIImage.class]?(UIImage *)(static):[[UIImage imageNamed:(NSString *)(static)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal])
#define _IMAGE_ND(static, dynamic) ({ \
    UIImage *c;\
    if (@available(iOS 13.0, *)) { \
        UIImage *light = _IMAGE_1(static); \
        UIImage *dark  = _IMAGE_1(dynamic); \
        if (light.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {\
            c = dark;\
        } else {c = light;} \
    } else { \
        c = _IMAGE_1(static); \
    } \
    c; \
})
#if A_IOS13_SDK
#define _IMAGE(static, dynamic) ({ \
    UIImage *c; \
    if (@available(iOS 13.0, *)) { \
        UIImage *light = _IMAGE_1(static); \
        UIImage *dark  = _IMAGE_1(dynamic); \
        UIImageAsset *imageAsset = UIImageAsset.new; \
        [imageAsset registerImage:dark ?: light  withTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark]]; \
        [imageAsset registerImage:light withTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]]; \
        [imageAsset registerImage:light withTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleUnspecified]]; \
        c = [imageAsset imageWithConfiguration:light.configuration]; \
    } else { \
        c = _IMAGE_1(static); \
    } \
    c; \
})
#else
#define _IMAGE(static, dynamic) _IMAGE_1(static)
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wstrict-prototypes"
typedef void(^AActionBlock)();
typedef id _Nullable (^BActionBlock)();
#pragma clang diagnostic pop
/*!
 * 目的:
 *    1. 提供便利宏
 *    2. 亦适合以后统一做相关优化
 */
@interface GConvenient : NSObject
+ (NSString *)timestamp;
+ (NSDictionary *)paraDict:(NSString *)para;
+ (NSString *)urlByAppendingDict:(NSString *)url params:(NSDictionary *)params;

+ (UIImageView *)imageView:(UIImage *)img;
+ (UILabel *)label:(nullable NSString *)txt color:(UIColor *)color font:(UIFont *)font;
+ (CGFloat)distance:(CGFloat)lat1 lng1:(CGFloat)lng1 lat2:(CGFloat)lat2 lng2:(CGFloat)lng2;
@end

@interface UIView (GConvenient)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize  size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
///> 添加点击手势 
- (UITapGestureRecognizer *)addTapGesture:(AActionBlock)action;
@end

@interface UIControl (GConvenient)
- (void)addEvents:(UIControlEvents)event action:(AActionBlock)action;
@end

NS_ASSUME_NONNULL_END
