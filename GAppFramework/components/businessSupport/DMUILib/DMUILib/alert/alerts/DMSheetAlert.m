//
//  DMSheetAlert.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/26.
//

#import "DMSheetAlert.h"
#import <GBaseLib/GConvenient.h>
#import <GUILib/GShow.h>

#define kDMSheetHeight 49
#define kDMSheetPad    8

@interface DMSheetAlert ()<GShowActionDelegate>
///> 数据: 视图 
@property (nonatomic, strong) NSMutableArray<UIView *> *arr;
///> 视图: 取消 
@property (nonatomic, strong) UIView *cancel;
///> 数据: 取消 
@property (nonatomic, strong) DMAlertAction *cancelAction;
///> 视图: iPhoneX白色遮挡 
@property (nonatomic, strong) UIView *white;
///> 
@property (nonatomic, strong) GShow *show;
@end

@implementation DMSheetAlert

#pragma mark - DMAlertHandlerDelegate
///=============================================================================
/// @name DMAlertHandlerDelegate
///=============================================================================

+ (instancetype)show:(DMAlert *)alert vc:(UIViewController *)vc {
    DMSheetAlert *sheet = [DMSheetAlert new];
    [alert.actions enumerateObjectsUsingBlock:^(DMAlertAction *obj, NSUInteger idx, BOOL *stop) {
        [sheet addAction:obj];
    }];
    sheet.show = [GShow show:sheet];
    return sheet;
}

- (void)dismiss:(BOOL)animate complete:(void (^)(void))block {
    [self.show dismiss:NO completion:^(BOOL finished) {
        if (block) block();
    }];
}

#pragma mark - GShowActionDelegate
///=============================================================================
/// @name GShowActionDelegate
///=============================================================================

- (void)backTapAction {
    [self.show dismiss:YES completion:^(BOOL finished) {
        if (self.cancelAction.block) self.cancelAction.block(self.cancelAction);
    }];
}

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, INDICATOR_HEIGHT);
    if (self = [super initWithFrame:rect]) {
        self.backgroundColor = HEX(@"f7f7f7", @"000000");
        self.white = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, INDICATOR_HEIGHT)];
        self.white.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        [self addSubview:self.white];
        _arr = @[].mutableCopy;
    }
    return self;
}

- (void)addAction:(DMAlertAction *)action {
    if (action.sStyle == DMAlertActionStyleCancel && self.cancel) return;
    if (action.sStyle == DMAlertActionStyleCancel && !self.cancel) {
        self.cancel = [self cancelView:action];
        self.cancelAction = action;
        [self addSubview:self.cancel];
    } else {
        UIView *view = [self defaultView:action];
        view.top = self.arr.count * (kDMSheetHeight+1);
        [self addSubview:view];
        [self.arr addObject:view];
    }
    self.height = self.arr.count * (kDMSheetHeight+1) - 1 + (self.cancel ? (kDMSheetHeight + kDMSheetPad):0) + INDICATOR_HEIGHT;
    if (self.cancel) self.cancel.top = self.arr.count * (kDMSheetHeight+1)-1 + kDMSheetPad;
    self.white.top = self.height - INDICATOR_HEIGHT;
}

- (UIView *)defaultView:(DMAlertAction *)action {
    UILabel *view = [UILabel new];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, kDMSheetHeight);
    view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    id attrt = [action.sTitle isKindOfClass:NSAttributedString.class] ? action.sTitle : [self defaultAttr:action.sTitle];
    view.attributedText = attrt;
    view.textAlignment = NSTextAlignmentCenter;
    @weakify(self);
    [view addTapGesture:^{
        @strongify(self);
        [self.show dismiss:YES];
        if (action.block) action.block(action);
    }];
    
    return view;
}

- (NSAttributedString *)defaultAttr:(NSString *)title {
    id attr = @{NSFontAttributeName:FONT(16), NSForegroundColorAttributeName: HEX(@"404040", @"dddddd")};
    return [[NSAttributedString alloc] initWithString:title attributes:attr];
}

- (UIView *)cancelView:(DMAlertAction *)action {
    UILabel *view = [UILabel new];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, kDMSheetHeight);
    view.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    id attrt = [action.sTitle isKindOfClass:NSAttributedString.class] ? action.sTitle : [self cancelAttr:action.sTitle];
    view.attributedText = attrt;
    view.textAlignment = NSTextAlignmentCenter;
    @weakify(self);
    [view addTapGesture:^{
        @strongify(self);
        [self.show dismiss:YES completion:^(BOOL finished) {
            if (action.block) action.block(action);
        }];
    }];
    return view;
}

- (NSAttributedString *)cancelAttr:(NSString *)title {
    id attr = @{NSFontAttributeName:FONT(16), NSForegroundColorAttributeName: HEX(@"404040", @"dddddd")};
    return [[NSAttributedString alloc] initWithString:title attributes:attr];
}

@end
