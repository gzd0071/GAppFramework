//
//  DMDAppInfoCell.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDAppInfoCell.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GBaseLib/GConvenient.h>

@interface DMDAppInfoCell ()
///> 
@property (nonatomic, strong) UILabel *title;
///> 
@property (nonatomic, strong) UITextField *status;
///> 
@property (nonatomic, strong) UIView *botline;
///>
@property (nonatomic, strong) AActionBlock block;
///> 
@property (nonatomic, assign) BOOL isLast;
///>  
@property (nonatomic, strong) UIImageView *arrow;
@end

@implementation DMDAppInfoCell

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.status];
        [self.contentView addSubview:self.botline];
        [self.contentView addSubview:self.arrow];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [_status mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
        make.width.equalTo(@250);
    }];
    [_botline mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.equalTo(@(self.isLast ? 0 : 0.5));
        make.right.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView.mas_left).offset(16);
    }];
    [_arrow mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(11, 11));
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
    NSDictionary *model = tuple.first;
    _isLast = [tuple.second boolValue];
    _title.text = model[@"name"];
    _status.text = [model[@"value"] isKindOfClass:NSString.class] ? model[@"value"] : [model[@"value"] stringValue];
    self.arrow.hidden = model[@"value"];
    if (model[@"color"]) _status.textColor = model[@"color"];
    if (model[@"block"]) {
        self.block = model[@"block"];
        [[self.status rac_textSignal] subscribeNext:^(NSString *x) {
            self.block(x);
        }];
        self.status.enabled = YES;
    }
    [self updateLayout];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = HEX(@"4c5b61", @"afafb0");
        _title.font = [UIFont systemFontOfSize:15];
    }
    return _title;
}

- (UITextField *)status {
    if (!_status) {
        _status = [UITextField new];
        _status.textAlignment = NSTextAlignmentRight;
        _status.font = [UIFont systemFontOfSize:14];
        _status.enabled = NO;
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

- (UIImageView *)arrow {
    if (!_arrow) {
        _arrow = [UIImageView new];
        _arrow.image = [UIImage imageNamed:@"doraemon_expand_no@3x"];
        _arrow.hidden = YES;
    }
    return _arrow;
}

@end
