//
//  DMDetailBottomView.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/17.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMDetailBottomView.h"
#import <GBaseLib/GConvenient.h>
#import <ReactiveObjC/RACTuple.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>
#import <YYKit/UIImage+YYAdd.h>
#import "DMDetailModel.h"
#import "DMDActions.h"

#define kDBtnHeight 49

@interface DMDetailBottomView()
///> 
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMDetailModel *model;
///> 按钮: 左 
@property (nonatomic, strong) UIButton *left;
///> 按钮: 右 
@property (nonatomic, strong) UIButton *right;
@end

@implementation DMDetailBottomView

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (id)viewWithModel:(id)model action:(AActionBlock)action {
    return [[self alloc] initWithFrame:CGRectZero model:model action:action];
}

#pragma mark - ViewAction
///=============================================================================
/// @name ViewAction
///=============================================================================

- (void)viewAction:(RACTuple *)tuple {

}

- (void)leftTapAction {
    if (self.actionBlock) self.actionBlock(RACTuplePack(@(DMDActionChat)));
}

- (void)rightTapAction {
    if (!self.actionBlock) return;
    if (self.model.canApplyCode == 1) {
        self.actionBlock(RACTuplePack(@(DMDActionApply)));
    } else if (self.model.canApplyCode == -104) {
        self.actionBlock(RACTuplePack(@(DMDActionCancelApply)));
    }
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    CGFloat h = INDICATOR_HEIGHT + kDBtnHeight;
    CGRect rect = CGRectMake(0, SCREEN_HEIGHT-h, SCREEN_WIDTH, h);
    if (self = [super initWithFrame:rect]) {
        self.actionBlock = action;
        self.model = model;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        [self addViews];
        [self addObserver];
    }
    return self;
}

- (void)addViews {
    self.left  = [self createButton];
    self.right = [self createButton];
    self.right.enabled = NO;
    [self addSubview:self.right];
    [self addSubview:self.left];
    
    [self.left addTarget:self action:@selector(leftTapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.right addTarget:self action:@selector(rightTapAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addObserver {
    @weakify(self);
    [RACObserve(self.model, done) subscribeNext:^(id x) {
        @strongify(self);
        [self updateUI];
    }];
}

- (void)updateUI {
    [self.left setTitle:self.model.chatTxt forState:UIControlStateNormal];
    self.left.frame = CGRectMake(0, 0, self.model.canChat?SCREEN_WIDTH:0, kDBtnHeight);
    if (self.model.canChat) return;
    self.right.frame = CGRectMake(0, 0, self.width, kDBtnHeight);
    [self.right setTitle:[self btnTxt] forState:UIControlStateNormal];
    self.right.enabled = [self btnEnable];
}

- (BOOL)btnEnable {
    if (self.model.isInterview) return self.model.ivCode == 1;
    return self.model.canApplyCode == -104 || self.model.canApplyCode == 1;
}

- (NSString *)btnTxt {
    if (self.model.isInterview) return [self btnTxtFromCode:self.model.ivCode];
    return self.model.canApplyTxt;
}

- (NSString *)btnTxtFromCode:(NSInteger)code {
    if (self.model.ivBtnTxt.length) return self.model.ivBtnTxt;
    switch (code) {
        case 1:  return @"预约面试";
        case 2:  return @"今日报名过多";
        case 3:  return @"只招男生";
        case 4:  return @"只招女生";
        case 5:  return @"只招学生";
        case 6:  return @"只招社会人";
        case 7:  return @"学历不符";
        case 8:  return @"年龄不符";
        case 9:  return @"待面试";
        case 10: return @"已录取";
        case 11: return @"已拒绝";
        case 12: return @"已结束";
        case 13: return @"已报名";
        case 14: return @"已取消";
        default: return @"投简历";
    }
}

- (UIButton *)createButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = FONT(16);
    [btn setTitleColor:HEX(@"404040") forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateDisabled];
    [btn setBackgroundImage:[UIImage imageWithColor:HEX(@"e5e5e5", @"303033")] forState:UIControlStateDisabled];
    [btn setBackgroundImage:[UIImage imageWithColor:HEX(@"ffcc00", @"ffaa00")] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageWithColor:HEX(@"ffcc00", @"ffaa00")] forState:UIControlStateHighlighted];
    return btn;
}

@end
