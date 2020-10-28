//
//  DMDAppInfoHeader.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDAppInfoHeader.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GBaseLib/GConvenient.h>

@interface DMDAppInfoHeader ()
///> 
@property (nonatomic, strong) UILabel *title;
@end

@implementation DMDAppInfoHeader

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.title];
        self.contentView.backgroundColor = HEX(@"D9E9FE", @"262628");
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
        make.left.equalTo(self.mas_left).offset(16);
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

#pragma mark - Update Model
///=============================================================================
/// @name Update Model
///=============================================================================

- (void)viewModel:(NSDictionary *)model action:(AActionBlock)action {
    _title.text = model[@"title"];
    if (model[@"color"]) self.contentView.backgroundColor = model[@"color"];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = HEX(@"324456", @"dddddd");
        _title.font = [UIFont boldSystemFontOfSize:16];
    }
    return _title;
}

@end
