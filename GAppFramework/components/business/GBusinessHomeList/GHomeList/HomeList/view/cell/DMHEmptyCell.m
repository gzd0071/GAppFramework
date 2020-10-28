//
//  DMHEmptyCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/7/3.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHEmptyCell.h"
#import "DMHListModel.h"
#import <GBaseLib/GConvenient.h>
#import <Masonry/Masonry.h>

@interface DMHEmptyCell()
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHPanelModel *model;

///> 视图: 标题 
@property (nonatomic, strong) UILabel *title;
///> 视图: 图片 
@property (nonatomic, strong) UIImageView *img;
@end

@implementation DMHEmptyCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    DMHPanelModel *model = x.first;
    _model = model;
    _actionBlock = action;
}

#pragma mark - Instance
///=============================================================================
/// @name Instance
///=============================================================================

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.title = [self createLabel];
    self.title.text = @"抱歉~暂无符合条件的职位";
    self.img = [[UIImageView alloc] initWithImage:IMAGE(@"notfound_load")];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.img];
}

#pragma mark - Layout
///=============================================================================
/// @name Layout
///=============================================================================
- (void)updateConstraints {
    [super updateConstraints];
    @weakify(self);
    [_title mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.img.mas_centerY).offset(10);
        make.left.equalTo(self.contentView.mas_centerX).offset(-40);
        make.right.equalTo(self.contentView.mas_right).offset(-50);
    }];
    [_img mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.title.mas_left).offset(-12);
        make.size.mas_equalTo(CGSizeMake(80, 80));
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
    label.textColor = HEX(@"808080", @"AFAFB0");
    label.numberOfLines = 0;
    return label;
}

@end
