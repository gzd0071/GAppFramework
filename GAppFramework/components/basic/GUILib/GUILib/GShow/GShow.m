//
//  GShow.m
//  GUILib
//
//  Created by iOS_Developer_G on 2019/9/10.
//

#import "GShow.h"
#import <GBaseLib/GConvenient.h>

@interface GShowViewController : UIViewController
///>
@property (nonatomic, strong) AActionBlock action;
@end
@implementation GShowViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dmBarHidden = YES;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_action) _action(@"appear");
}
@end

@interface GShow ()<CAAnimationDelegate>
///>  
@property (nonatomic, strong) UIView *back;
///>  
@property (nonatomic, weak) UIView *view;
///>  
@property (nonatomic, assign) GShowAnimateType type;
///>  
@property (nonatomic, strong) void (^completion)(BOOL finish);
///>
@property (nonatomic, strong) GShowViewController *vc;
@end

@implementation GShow

+ (instancetype)show {
    static GShow *show;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        show = [GShow new];
    });
    return show;
}

- (instancetype)init {
    if (self = [super init]) {
        _back = [UIView new];
        _back.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0];
        @weakify(self);
        [_back addTapGesture:^{
            @strongify(self);
            if ([self.view respondsToSelector:@selector(backTapAction)])
                [(id<GShowActionDelegate>)self.view backTapAction];
            else
                [self dismiss:YES];
        }];
    }
    return self;
}

#pragma mark - Animate
///=============================================================================
/// @name Animate
///=============================================================================

+ (instancetype)show:(UIView *)view {
    return [GShow show:view sview:nil];
}
+ (instancetype)show:(UIView *)view type:(GShowAnimateType)type {
    return [GShow show:view type:type com:nil];
}
+ (instancetype)show:(UIView *)view type:(GShowAnimateType)type sview:(UIView *)sview {
    return [self show:view type:type sview:sview com:nil];
}
+ (instancetype)show:(UIView *)view type:(GShowAnimateType)type com:(void (^)(BOOL finish))completion {
    return [GShow show:view type:type sview:nil com:completion];
}
+ (instancetype)show:(UIView *)view sview:(UIView *)sview {
    return [GShow show:view type:GShowAnimateTypeBottom sview:sview com:nil];
}

+ (instancetype)show:(UIView *)view type:(GShowAnimateType)type sview:(UIView *)sview com:(void (^)(BOOL finish))completion {
    GShow *show = [GShow new];
    show.type = type;
    if (!sview) {
        show.vc = [self creatvcView];
        sview = show.vc.view;
        @weakify(show);
        show.vc.action = ^{
            @strongify(show);
            if ([show.view respondsToSelector:@selector(showAppearAction)]) {
                [(id<GShowActionDelegate>)show.view showAppearAction];
            }
        };
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [show show:view sview:sview com:completion];
    });
    return show;
}

+ (GShowViewController *)creatvcView {
    GShowViewController *vc = [GShowViewController new];
    UINavigationController *nnavi = [[UINavigationController alloc] initWithRootViewController:vc];
    nnavi.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nnavi.navigationBarHidden = YES;
    nnavi.view.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nnavi animated:NO completion:nil];
    return vc;
}

- (void)show:(UIView *)view sview:(UIView *)sview com:(void (^)(BOOL finish))completion {
    UIView *sp = sview?:[UIApplication sharedApplication].keyWindow;
    self.back.frame = sp.bounds;
    if ([view respondsToSelector:@selector(backInsets)]) {
        UIEdgeInsets insets = [(id<GShowActionDelegate>)view backInsets];
        CGRect frame = self.back.frame;
        self.back.frame = CGRectMake(frame.origin.x+insets.left, frame.origin.y+insets.top, frame.size.width-insets.left-insets.right, frame.size.height-insets.top-insets.bottom);
    }
    self.view = view;
    [sp addSubview:self.back];
    [sp addSubview:view];
    view.frame = [self originFrameView:view sframe:sp.frame];
    [self showAnimate:view sview:sp com:completion];
}

- (void)dismiss {
    [self.back removeFromSuperview];
    [self.view removeFromSuperview];
    if (self.vc) [self.vc dismissViewControllerAnimated:NO completion:^{
        if (self.completion) self.completion(YES);
    }];
    else if (self.completion) self.completion(YES);
}

- (void)dismiss:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    self.completion = completion;
    if (!animated) {
        [self dismiss];
        return;
    }
    [self dismissAnimate:completion];
}
- (void)dismiss:(BOOL)animated {
    [self dismiss:animated completion:nil];
}

- (void)showAnimate:(UIView *)view sview:(UIView *)sview com:(void (^)(BOOL finish))completion {
    if (self.type == GShowAnimateTypeCenter) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@(0.01), @(1.2), @(0.9), @(1)];
        animation.keyTimes = @[@(0), @(0.4), @(0.6), @(1)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.duration = 0.45;
        animation.delegate = self;
        [animation setValue:@"show" forKey:@"Scale"];
        [view.layer addAnimation:animation forKey:@"bouce"];
        [UIView animateWithDuration:.45 animations:^{
            self.back.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0.5];
        } completion:^(BOOL finished) {
            if (completion) completion(finished);
        }];
    } else if (self.type == GShowAnimateTypeFade) {
        view.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            if (completion) completion(finished);
        }];
    } else {
        @weakify(self);
        [UIView animateWithDuration:0.2 animations:^{
            @strongify(self);
            view.frame = [self showFrameView:view sframe:sview.frame];
            self.back.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0.5];
        } completion:^(BOOL finished) {
            if (completion) completion(finished);
        }];
    }
}

- (void)dismissAnimate:(void (^)(BOOL finished))completion {
    if (self.type == GShowAnimateTypeCenter) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@(1), @(1.2), @(0.01)];
        animation.keyTimes = @[@(0), @(0.4), @(1)];
        animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        animation.duration = 0.35;
        animation.delegate = self;
        [animation setValue:@"miss" forKey:@"Scale"];
        [self.view.layer addAnimation:animation forKey:@"bounce"];
        self.view.transform = CGAffineTransformMakeScale(0.001, 0.001);
    } else if (self.type == GShowAnimateTypeFade) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismiss];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.frame = [self originFrameView:self.view sframe:self.back.superview.frame];
            self.back.backgroundColor = [HEX(@"000000") colorWithAlphaComponent:0.0];
        } completion:^(BOOL finished) {
            [self dismiss];
        }];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"Scale"] isEqualToString:@"miss"]) {
        if (flag) [self dismiss];
    }
}

- (CGRect)originFrameView:(UIView *)view sframe:(CGRect)sframe {
    CGRect frame = view.frame;
    if (self.type == GShowAnimateTypeBottom) {
        frame.origin.y = sframe.size.height;
    } else if (self.type == GShowAnimateTypeTop) {
        frame.origin.y = -frame.size.height;
    } else if (self.type == GShowAnimateTypeLeft) {
        frame.origin.x = -frame.size.width;
    } else if (self.type == GShowAnimateTypeRight) {
        frame.origin.x = sframe.size.width;
    } else if (self.type == GShowAnimateTypeCenter) {
        frame.origin = CGPointMake((sframe.size.width-frame.size.width)/2, (sframe.size.height-frame.size.height)/2);
    } else if (self.type == GShowAnimateTypeCustomFrame) {
        if ([view respondsToSelector:@selector(dismissFrameAnimation)]) {
            return [(id<GShowAnimateDelegate>)view dismissFrameAnimation];
        }
    }
    return frame;
}

- (CGRect)showFrameView:(UIView *)view sframe:(CGRect)sframe {
    CGRect frame = view.frame;
    if (self.type == GShowAnimateTypeBottom) {
        frame.origin.y = sframe.size.height-frame.size.height;
    } else if (self.type == GShowAnimateTypeTop) {
        frame.origin.y = 0;
    } else if (self.type == GShowAnimateTypeLeft) {
        frame.origin.x = 0;
    } else if (self.type == GShowAnimateTypeRight) {
        frame.origin.x = sframe.size.width-frame.size.width;
    } else if (self.type == GShowAnimateTypeCustomFrame) {
        if ([view respondsToSelector:@selector(showFrameAnimation)]) {
            return [(id<GShowAnimateDelegate>)view showFrameAnimation];
        }
    }
    return frame;
}

@end
