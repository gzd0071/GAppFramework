//
//  DMCustomAlert.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/26.
//

#import "DMCustomAlert.h"
#import <GBaseLib/GConvenient.h>
#import <GUILib/GShow.h>
#import <YYKit/UIImage+YYAdd.h>
#import "DMAlertActions.h"

///> 按钮高度
#define kCBHeight 45.0f
#define kCAPad    15.f
#define kCAMax    266.0f

@interface DMCustomAlert ()<GShowActionDelegate>
///> 数据: 视图 
@property (nonatomic, strong) NSMutableArray<UIView *> *arr;
///> 视图: 图片 
@property (nonatomic, strong) UIImageView *header;
///> 视图: 标题 
@property (nonatomic, strong) UILabel *title;
///> 视图: 文案 
@property (nonatomic, strong) UILabel *message;
///> 视图: 取消 
@property (nonatomic, strong) UIView *cancel;
///> 视图: 取消Action 
@property (nonatomic, strong) DMAlertAction *cancelAction;
///> 
@property (nonatomic, strong) GShow *show;
@end

@implementation DMCustomAlert

#pragma mark - DMAlertHandlerDelegate
///=============================================================================
/// @name DMAlertHandlerDelegate
///=============================================================================

+ (instancetype)show:(DMAlert *)alert vc:(UIViewController *)vc {
    DMCustomAlert *al = [DMCustomAlert new];
    [al handler:alert];
    al.show = [GShow show:al type:GShowAnimateTypeCenter sview:vc.view];
    return al;
}

- (void)dismiss:(BOOL)animate complete:(void (^)(void))block {
    [self.show dismiss:animate completion:^(BOOL finished) {
        if (block) block();
    }];
}

#pragma mark - GShowActionDelegate
///=============================================================================
/// @name GShowActionDelegate
///=============================================================================

- (void)backTapAction {
    if (!self.cancelAction.block) {
        [self.show dismiss:YES completion:nil];
    }
}

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect rect = CGRectMake(0, 0, kCAWidth, 0);
    if (self = [super initWithFrame:rect]) {
        self.backgroundColor    = HEX(@"ffffff");
        self.layer.cornerRadius = 20.0f;
        self.clipsToBounds = YES;
        _arr = @[].mutableCopy;
    }
    return self;
}

- (void)handler:(DMAlert *)alert {
    NSMutableArray *hActions   = @[].mutableCopy;
    NSMutableArray *bActions   = @[].mutableCopy;
    NSMutableArray *btnActions = @[].mutableCopy;
    [alert.actions enumerateObjectsUsingBlock:^(DMAlertAction *obj, NSUInteger idx, BOOL *stop) {
        if (!obj.sCustom) [btnActions addObject:obj];
        else if (obj.sPosition == DMAlertActionPositionHeader) [hActions addObject:obj];
        else if ([obj.sTitle length] || obj.sCustom) [bActions addObject:obj];
    }];
    [self addActions:hActions];
    [self addTitle:alert];
    [self addMessage:alert];
    [self addActions:bActions];
    [self addBActions:btnActions];
}

- (void)addActions:(NSArray<DMAlertAction *> *)actions {
    [actions enumerateObjectsUsingBlock:^(DMAlertAction *obj, NSUInteger idx, BOOL *stop) {
        [self addSubview:obj.sCustom];
        CGFloat y = obj.sCustom.y;
        obj.sCustom.top = self.height+y;
        self.height += (obj.sCustom.height+y);
    }];
}

- (void)addTitle:(DMAlert *)alert {
    if (!alert.sTitle) return;

    self.title = [UILabel new];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.numberOfLines = 0;
    [self addSubview:self.title];
    CGFloat pad = 24;
    self.title.attributedText = [self titleAttr:alert.sTitle];
    CGSize size =  [self.title sizeThatFits:CGSizeMake(kCAWidth - 2 * kCAPad, kCAMax)];
    self.title.frame = CGRectMake(kCAPad, self.height+pad, kCAWidth - 2 * kCAPad, MIN(size.height+0.5, kCAMax));
    self.height += self.title.height+24;
}

- (NSAttributedString *)titleAttr:(id)title {
    if ([title isKindOfClass:NSAttributedString.class]) {
        return title;
    }
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    id attr = @{NSFontAttributeName:FONT_BOLD(18), NSForegroundColorAttributeName:HEX(@"404040", @"dddddd"), NSParagraphStyleAttributeName:style};
    return [[NSAttributedString alloc] initWithString:title attributes:attr];
}

- (void)addMessage:(DMAlert *)alert {
    if (!alert.sMessage) {
        // 修正样式
        if (self.title) self.height += 24;
        return;
    }
    self.message = [UILabel new];
    self.message.textAlignment = NSTextAlignmentCenter;
    self.message.numberOfLines = 0;
    [self addSubview:self.message];
    CGFloat pad = self.title ? 12 : 24;
    self.message.attributedText = [self messageAttr:alert.sMessage];
    CGSize size =  [self.message sizeThatFits:CGSizeMake(kCAWidth - 2 * kCAPad, kCAMax)];
    self.message.frame = CGRectMake(kCAPad, self.height+pad, kCAWidth - 2 * kCAPad, MIN(size.height+0.5, kCAMax));
    self.height += self.message.height + pad + 24;
}

- (NSAttributedString *)messageAttr:(id)title {
    if ([title isKindOfClass:NSAttributedString.class]) {
        return title;
    }
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 5;
    style.alignment = NSTextAlignmentCenter;
    id attr = @{NSFontAttributeName:FONT(14), NSForegroundColorAttributeName:HEX(@"404040"), NSParagraphStyleAttributeName:style };
    return [[NSAttributedString alloc] initWithString:title attributes:attr];
}

- (void)addBActions:(NSArray<DMAlertAction *> *)actions {
    CGFloat w = actions.count == 2 ? (kCAWidth/2) : kCAWidth;
    @weakify(self);
    [actions enumerateObjectsUsingBlock:^(DMAlertAction *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        if (!obj.sTitle) return;
        if (obj.sStyle == DMAlertActionStyleCancel && self.cancelAction) {
            return;
        }
        if (obj.sStyle == DMAlertActionStyleCancel) self.cancelAction = obj;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        id title = [self btnTitle:obj];
        [btn setAttributedTitle:title forState:UIControlStateNormal];
        if (actions.count == 2) {
            btn.frame = CGRectMake(idx * w, self.height, w, kCBHeight);
        } else {
            btn.frame = CGRectMake(0, self.height+self.arr.count*kCBHeight, w, kCBHeight);
        }
        UIColor *color  = obj.sStyle == DMAlertActionStyleCancel ? HEX(@"ffffff") : HEX(@"F5C839");
        UIColor *scolor = obj.sStyle == DMAlertActionStyleCancel ? HEX(@"ffffff") : HEX(@"F2B735");
        [btn setBackgroundImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:scolor] forState:UIControlStateHighlighted];
        [self addSubview:btn];
        [self.arr addObject:btn];
        @weakify(self);
        [btn addEvents:UIControlEventTouchUpInside action:^{
            @strongify(self);
            [self.show dismiss:YES completion:^(BOOL finished) {
                if (obj.block) obj.block(obj);
            }];
        }];
    }];
    self.height += ((self.arr.count == 2||self.arr.count == 1) ? kCBHeight : kCBHeight * self.arr.count);
}

- (NSAttributedString *)btnTitle:(DMAlertAction *)action {
    if ([action.sTitle isKindOfClass:NSAttributedString.class]) {
        return action.sTitle;
    }
    UIColor *color;
    if (action.sTitleColor) {
        color = action.sTitleColor;
    } else if (action.sStyle == DMAlertActionStyleCancel) {
        color = HEX(@"505050");
    } else {
        color = HEX(@"404040");
    }
    id attr = @{NSFontAttributeName:FONT(16), NSForegroundColorAttributeName:color };
    return [[NSAttributedString alloc] initWithString:action.sTitle attributes:attr];
}

@end
