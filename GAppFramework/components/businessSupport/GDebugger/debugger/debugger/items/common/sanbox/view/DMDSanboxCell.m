//
//  DMDSanboxCell.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/5/6.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDSanboxCell.h"
#import "DMDSanboxModel.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GBaseLib/GConvenient.h>

@interface DMDSanboxCell ()
///> 
@property (nonatomic, strong) UILabel *title;
///> 
@property (nonatomic, strong) UILabel *status;
///> 
@property (nonatomic, strong) UIView *botline;
///> 
@property (nonatomic, strong) UIImageView *img;
///> 
@property (nonatomic, strong) UIImageView *arrow;
///> 
@property (nonatomic, assign) BOOL isLast;
@end

@implementation DMDSanboxCell

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.status];
        [self.contentView addSubview:self.botline];
        [self.contentView addSubview:self.img];
        [self.contentView addSubview:self.arrow];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
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
        make.left.equalTo(self.img.mas_right).offset(16);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.arrow.mas_left).offset(-16);
    }];
    [_status mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.arrow.mas_left).offset(-16);
    }];
    [_img mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.size.mas_equalTo(self.img.image.size);
    }];
    [_arrow mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(11, 11));
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
    DMDSanboxModel *model = tuple.first;
    _isLast = [tuple.second boolValue];
    _title.text = model.name;
    _img.image = [UIImage imageNamed:(model.isFile ? @"doraemon_file_2@2x" : @"doraemon_dir@2x")];
    _arrow.hidden = model.isFile;
    [self updateLayout];
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

- (UIImageView *)img {
    if (!_img) {
        _img = [UIImageView new];
    }
    return _img;
}

- (UIImageView *)arrow {
    if (!_arrow) {
        _arrow = [UIImageView new];
        _arrow.image = [UIImage imageNamed:@"doraemon_expand_no@3x"];
    }
    return _arrow;
}

@end
