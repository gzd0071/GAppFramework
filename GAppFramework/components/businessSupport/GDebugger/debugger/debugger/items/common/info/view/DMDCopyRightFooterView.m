//
//  DMDCopyRightFooterView.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDCopyRightFooterView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GBaseLib/GConvenient.h>

#define kDMDCopyRightFooterHeight 60

@interface DMDCopyRightFooterView()
///> 
@property (nonatomic, strong) UILabel *title;
///> 
@property (nonatomic, strong) UIView *leftLine;
///> 
@property (nonatomic, strong) UIView *rightLine;
@end

@implementation DMDCopyRightFooterView

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (instancetype)viewWithModel:(id)model action:(AActionBlock)action {
    DMDCopyRightFooterView *footer = [[self alloc] initWithFrame:CGRectZero model:model action:action];
    [footer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(kDMDCopyRightFooterHeight));
    }];
    return footer;
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:CGRectZero model:nil action:nil];
}

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    if (self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kDMDCopyRightFooterHeight)]) {
        [self addSubview:self.leftLine];
        [self addSubview:self.title];
        [self addSubview:self.rightLine];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Layout
///=============================================================================
/// @name Layout
///=============================================================================

- (void)updateLayout {
    @weakify(self);
    [_title mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    [_leftLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.title.mas_left).offset(-8);
        make.height.equalTo(@1);
        make.width.equalTo(@80);
        make.centerY.equalTo(self.mas_centerY);
    }];
    [_rightLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.title.mas_right).offset(8);
        make.height.equalTo(@1);
        make.width.equalTo(@80);
        make.centerY.equalTo(self.mas_centerY);
    }];
}

- (void)updateConstraints {
    [super updateConstraints];
    [self updateLayout];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}


#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = HEX(@"999999", @"989899");
        _title.font = [UIFont systemFontOfSize:12];
        _title.text = @"Copyright © 2019 iOS_Developer_G";
    }
    return _title;
}

- (UIView *)rightLine {
    if (!_rightLine) {
        _rightLine = [UIView new];
        _rightLine.backgroundColor = HEX(@"E2E6E9", @"303033");
    }
    return _rightLine;
}

- (UIView *)leftLine {
    if (!_leftLine) {
        _leftLine = [UIView new];
        _leftLine.backgroundColor = HEX(@"E2E6E9", @"303033");
    }
    return _leftLine;
}

@end
