//
//  DMHRefreshCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/25.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHRefreshCell.h"
#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>
#import <Masonry/Masonry.h>

@interface DMHRefreshCell()
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHPanelModel *model;

///> 视图: 标题 
@property (nonatomic, strong) UILabel *title;
///> 视图: 图片 
@property (nonatomic, strong) UIImageView *img;
///>  
@property (nonatomic, strong) UIView *contain;
///>  
@property (nonatomic, strong) UIView *shadow;
@end

@implementation DMHRefreshCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHPanelModel *model = x.first;
    _model = model;
    _actionBlock = action;
    _title.text = model.title;
}

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"f7f7f7", @"000000");
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.title = [self createLabel];
    self.img = [[UIImageView alloc] initWithImage:IMAGE(@"home_refresh")];
    self.contain = [UIView new];
    self.contain.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    self.contain.layer.cornerRadius = 18;
    self.contain.clipsToBounds = YES;
    [self.contain addSubview:self.title];
    [self.contain addSubview:self.img];
    [self.contentView addSubview:self.shadow];

    [self.contentView addSubview:self.contain];
}

- (UIView *)shadow {
    if (!_shadow) {
        _shadow = [[UIView alloc] init];
        _shadow.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        _shadow.layer.cornerRadius = 18;
        _shadow.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadow.frame = CGRectMake(SCREEN_WIDTH/2-89, 16, 178, 36);
        _shadow.layer.shadowOffset = CGSizeMake(0,1);
        _shadow.layer.shadowOpacity = 0.05;
        _shadow.layer.shadowRadius = 5;
    }
    return _shadow;
}

#pragma mark - Layout
///=============================================================================
/// @name Layout
///=============================================================================
- (void)updateConstraints {
    [super updateConstraints];
    @weakify(self);
    [_contain mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.height.equalTo(@36);
    }];
    [_title mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contain.mas_centerY);
        make.right.equalTo(self.contain.mas_right).offset(-16);
    }];
    [_img mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contain.mas_centerY);
        make.left.equalTo(self.contain.mas_left).offset(16);
        make.right.equalTo(self.title.mas_left).offset(-6);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (UILabel *)createLabel {
    UILabel *label = [UILabel new];
    label.font = FONT(14);
    label.textColor = HEX(@"404040", @"dddddd");
    return label;
}

@end
