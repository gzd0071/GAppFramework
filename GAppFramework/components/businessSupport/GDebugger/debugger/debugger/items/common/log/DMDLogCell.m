//
//  DMDLogCell.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/8/12.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMDLogCell.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GLogger/Logger.h>
#import <GBaseLib/GConvenient.h>

@interface DMDLogCell ()
///> 
@property (nonatomic, strong) UILabel *title;
///> 
@property (nonatomic, strong) UILabel *status;
///> 
@property (nonatomic, strong) UIView *botline;
///> 
@property (nonatomic, strong) UISwitch *swt;
///>  
@property (nonatomic, strong) AActionBlock action;
///>  
@property (nonatomic, strong) NSDictionary *model;
///> 
@property (nonatomic, assign) BOOL isLast;
@end

@implementation DMDLogCell

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.swt];
        [self.contentView addSubview:self.botline];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapAction {
    if (self.action) self.action(RACTuplePack(@"Switch"));
}

#pragma mark - Layout
///=============================================================================
/// @name Layout
///=============================================================================

- (void)updateLayout {
    @weakify(self);
    [_title mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [_swt mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
    }];
    [_botline mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.equalTo(@(self.isLast ? 0 : 0.5));
        make.right.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).offset(16);
    }];
}

- (void)updateConstraints {
    [super updateConstraints];
    [self updateLayout];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Update
///=============================================================================
/// @name Update
///=============================================================================

- (void)viewModel:(RACTuple *)tuple action:(AActionBlock)action {
    _isLast = [tuple.second boolValue];
    _title.text = tuple.first[@"title"];
    _model = tuple.first;
    _swt.on = (LogLevel)[_model[@"level"] integerValue] <= [Logger currentLogLevel];
    _action = action;
    [self updateLayout];
}

- (void)viewAction:(id)x {
    [_swt setOn:(LogLevel)[_model[@"level"] integerValue] <= [Logger currentLogLevel] animated:YES];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = HEX(@"4c5b61", @"dddddd");
        _title.font = [UIFont systemFontOfSize:15];
    }
    return _title;
}

- (UILabel *)status {
    if (!_status) {
        _status = [UILabel new];
        _status.font = [UIFont systemFontOfSize:14];
    }
    return _status;
}

- (UIView *)botline {
    if (!_botline) {
        _botline = [UIView new];
        _botline.backgroundColor = HEX(@"e2e6e9", @"303033");
    }
    return _botline;
}

- (UISwitch *)swt {
    if (!_swt) {
        _swt = [UISwitch new];
        _swt.userInteractionEnabled = NO;
//        [_swt addTarget:self action:@selector(switchOn) forControlEvents:UIControlEventValueChanged];
    }
    return _swt;
}

@end
