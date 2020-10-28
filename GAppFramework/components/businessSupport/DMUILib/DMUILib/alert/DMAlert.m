//
//  DMAlert.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/18.
//

#import "DMAlert.h"
#import "DMAlertHandlerDelegate.h"

@interface DMAlertAction()
@end
@implementation DMAlertAction
#pragma mark - Life
///=============================================================================
/// @name Life
///=============================================================================
+ (instancetype)action {
    return [[self alloc] init];
}
+ (instancetype)action:(id<DMAlertActionViewDelegate>)delegate {
    DMAlertAction *alert = [[self alloc] init];
    alert.sdelegate = delegate;
    return alert;
}
#pragma mark - DOT SYNTAX
///=============================================================================
/// @name 点语法
///=============================================================================
- (DMAlertAction *(^)(id title))title {
    return ^id(id title) { self.sTitle = title; return self; };
}
- (DMAlertAction *(^)(DMAlertActionStyle style))style {
    return ^id(DMAlertActionStyle style) { self.sStyle = style; return self; };
}
- (DMAlertAction *(^)(UIColor *color))titleColor {
    return ^id(UIColor *color) { self.sTitleColor = color; return self; };
}
- (DMAlertAction *(^)(DMAlertActionPosition position))position {
    return ^id(DMAlertActionPosition position) { self.sPosition = position; return self; };
}
- (DMAlertAction *(^)(UIView *view))custom {
    return ^id(UIView *view) {
        self.sCustom = view;
        return self;
    };
}
- (DMAlertAction *(^)(id<DMAlertActionViewDelegate> delegate))delegate {
    return ^id(id<DMAlertActionViewDelegate> delegate) {
        self.sdelegate = delegate;
        return self;
    };
}
- (DMAlertAction *(^)(void (^)(DMAlertAction *action)))handler {
    return ^id(void (^block)(DMAlertAction *action)) {
        self.block = block;
        return self;
    };
}
@end

@interface DMAlert()
///> Alert
@property (nonatomic, strong) id<DMAlertHandlerDelegate> alertV;
@end

@implementation DMAlert

#pragma mark - Life
///=============================================================================
/// @name Life
///=============================================================================
+ (instancetype)alert {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.sStyle  = DMAlertStyleAlert;
        self.actions = @[].mutableCopy;
    }
    return self;
}

- (void(^)(id<DMAlertHandlerDelegate>alert, UIViewController *vc))alert {
    return ^void(id<DMAlertHandlerDelegate> alert, UIViewController *vc) {
        [(id<DMAlertHandlerDelegate>)alert show:self vc:vc];
    };
}

- (void(^)(UIViewController *vc))show {
    return ^void(UIViewController *vc) {
        NSString *clsname = @"";
        if (self.sType == DMAlertTypeDoumi || self.sType == DMAlertTypeDoumiB) {
            clsname = @"DMCustomAlert";
        } else if (self.sType == DMAlertTypeSystem) {
            clsname = @"DMSystemAlert";
        } else if (self.sType == DMAlertTypeSheet) {
            clsname = @"DMSheetAlert";
        }
        Class cls = NSClassFromString(clsname);
        if (!cls) return;
        self.alertV = [(id<DMAlertHandlerDelegate>)cls show:self vc:vc];
    };
}

- (void)dismiss:(BOOL)animate complete:(void (^)(DMAlert *alert))block {
    if ([self.alertV respondsToSelector:@selector(dismiss:complete:)]) {
        [self.alertV dismiss:animate complete:^{
            if (block) block(self);
        }];
    }
}

#pragma mark - DOT SYNTAX
///=============================================================================
/// @name 点语法
///=============================================================================
- (DMAlert *(^)(id title))title {
    return ^id(id title) { self.sTitle = title; return self; };
}
- (DMAlert *(^)(id message))message {
    return ^id(id message) { self.sMessage = message; return self; };
}
- (DMAlert *(^)(DMAlertType type))type {
    return ^id(DMAlertType type) { self.sType = type; return self; };
}
- (DMAlert *(^)(DMAlertStyle style))style {
    return ^id(DMAlertStyle style) { self.sStyle = style; return self; };
}
- (DMAlert *(^)(DMAlertAction *action))addAction {
    return ^id(DMAlertAction *action) { [self.actions addObject:action]; return self; };
}
- (DMAlert *(^)(id action))addActions {
    return ^id(id action) {
        if ([action isKindOfClass:[NSArray class]]) {
            [self.actions addObjectsFromArray:action];
        } else {
            [self.actions addObject:action];
        }
        return self;
    };
}
@end
