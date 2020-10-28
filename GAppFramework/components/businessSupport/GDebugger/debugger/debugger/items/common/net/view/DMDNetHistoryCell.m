//
//  DMDNetHistoryCell.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/30.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDNetHistoryCell.h"
#import "URLInjectorRequestPacket.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GBaseLib/GConvenient.h>

@interface DMDNetHistoryCell ()
///> 
@property (nonatomic, strong) UILabel *title;
///> 
@property (nonatomic, strong) UILabel *status;
///> 
@property (nonatomic, strong) UILabel *method;
///>  
@property (nonatomic, strong) UILabel *time;
///>  
@property (nonatomic, strong) UIView *timeLine;
///> 
@property (nonatomic, strong) UIView *line;
///>  
@property (nonatomic, strong) UIImageView *arrow;
///> 
@property (nonatomic, strong) UIView *botline;

@end

@implementation DMDNetHistoryCell

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.time];
        [self.contentView addSubview:self.timeLine];
        [self.contentView addSubview:self.status];
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.status];
        [self.contentView addSubview:self.method];
        [self.contentView addSubview:self.line];
        [self.contentView addSubview:self.botline];
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
    [_time mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.top.equalTo(self.contentView.mas_top).offset(12);
    }];
    [_timeLine mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.time.mas_right).offset(6);
        make.width.equalTo(@0.5);
        make.height.equalTo(@15);
        make.centerY.equalTo(self.time.mas_centerY);
    }];
    [_title mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView.mas_left).offset(16);
        make.top.equalTo(self.status.mas_bottom).offset(6);
        make.right.equalTo(self.arrow.mas_right).offset(-16);
    }];
    [_status mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLine.mas_right).offset(0);
        make.top.equalTo(self.contentView.mas_top).offset(12);
        make.width.equalTo(@40);
    }];
    [_method mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.line.mas_right).offset(0);
        make.centerY.equalTo(self.status.mas_centerY);
        make.width.equalTo(@50);
    }];
    [_line mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.status.mas_right);
        make.width.equalTo(@0.5);
        make.height.equalTo(@15);
        make.centerY.equalTo(self.status.mas_centerY);
    }];
    [_botline mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@0.5);
        make.right.bottom.left.equalTo(self.contentView);
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

- (void)viewModel:(URLInjectorRequestPacket *)model action:(AActionBlock)action {
    _title.text = model.url.path;
    NSInteger code = model.statusCode.intValue;
    _status.text = model.statusCode;
    if (code >= 200 && code < 300) {
        _status.textColor = RGB(46, 204, 113);
    } else if (code >= 300 && code < 400) {
        _status.textColor = RGB(241, 196, 15);
    } else {
        _status.textColor = RGB(231, 76, 60);
    }
    _method.text = [model.requestMethod uppercaseString];
    
    NSString *method = _method.text;
    if ([method isEqualToString:@"GET"]) {
        _method.textColor = RGB(0, 206, 201);
    } else if ([method isEqualToString:@"POST"]) {
        _method.textColor = RGB(253, 203, 110);
    } else if ([method isEqualToString:@"DELETE"]) {
        _method.textColor = RGB(225, 112, 85);
    } else if ([method isEqualToString:@"PUT"]) {
        _method.textColor = RGB(9, 132, 227);
    } else {
        _method.textColor = [UIColor lightGrayColor];
    }
    _time.text = [self timeFormat:model.startDate];
    [_time sizeToFit];
//    [self.contentView.yoga applyLayoutPreservingOrigin:NO];
}

- (NSString *)timeFormat:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = HEX(@"999999", @"989899");
        _title.font = [UIFont systemFontOfSize:15];
    }
    return _title;
}

- (UILabel *)time {
    if (!_time) {
        _time = [UILabel new];
        _time.textColor = HEX(@"4c5b61", @"dddddd");
        _time.font = [UIFont systemFontOfSize:15];
    }
    return _time;
}

- (UILabel *)status {
    if (!_status) {
        _status = [UILabel new];
        _status.font = [UIFont systemFontOfSize:14];
        _status.textAlignment = NSTextAlignmentCenter;
    }
    return _status;
}

- (UILabel *)method {
    if (!_method) {
        _method = [UILabel new];
        _method.font = [UIFont systemFontOfSize:14];
        _method.textAlignment = NSTextAlignmentCenter;
    }
    return _method;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = HEX(@"999999", @"989899");
    }
    return _line;
}

- (UIView *)timeLine {
    if (!_timeLine) {
        _timeLine = [UIView new];
        _timeLine.backgroundColor = HEX(@"999999", @"989899");
    }
    return _timeLine;
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
    }
    return _arrow;
}

@end
