//
//  DMHConuselorCell.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/7/5.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHConuselorCell.h"
#import "DMHListModel.h"
//#import "DMCounselorEntrance.h"
#import <GBaseLib/GConvenient.h>
#import <Masonry/Masonry.h>

@interface DMHConuselorCell()
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHPanelModel *model;

///> 视图: 标题 
@property (nonatomic, strong) UILabel *title;
///>  
@property (nonatomic, strong) UILabel *desc;
///> 视图: 图片 
@property (nonatomic, strong) UIImageView *img;
@end

@implementation DMHConuselorCell

#pragma mark - DATA
///=============================================================================
/// @name DATA
///=============================================================================

- (void)viewModel:(RACTuple *)x action:(nullable AActionBlock)action {
    self.model = x.first;
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
        self.backgroundColor = HEX(@"f7f7f7", @"000000");
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.title = [self createLabel];
    self.title.font = FONT_BOLD(16);
    self.desc  = [self createLabel];
    self.desc.font = FONT_BOLD(14);
//    self.title.text = [DMCounselorEntrance sharedInstance].counselorbehavior.filter.titleimages;
//    self.desc.text = [DMCounselorEntrance sharedInstance].counselorbehavior.filter.descriptionStr;
    self.img = [[UIImageView alloc] init];
//    [self.img sd_setImageWithURL:[NSURL URLWithString:[DMCounselorEntrance sharedInstance].counselorbehavior.filter.images]];
    [self.img addSubview:self.title];
    [self.img addSubview:self.desc];
    @weakify(self);
    [self.img addTapGesture:^{
//        id url = [NSString stringWithFormat:@"%@?user_id=%@&user_name=%@",URD(DM_JianzhiJobCounselor),[DMCounselorEntrance sharedInstance].counselorInfo.counselorId?:@"",[DMCounselorEntrance sharedInstance].counselorInfo.user_name.URLEncoding];
        @strongify(self);
        if (self.actionBlock) {
            self.actionBlock(RACTuplePack(@"conuselor", @"", self.model));
        }
    }];
    
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
        make.top.equalTo(self.img.mas_top).offset(16);
        make.left.equalTo(self.img.mas_left).offset(110);
        make.right.equalTo(self.img.mas_right).offset(-20);
    }];
    [_desc mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.title.mas_bottom).offset(10);
        make.left.equalTo(self.title.mas_left);
        make.right.equalTo(self.img.mas_right).offset(-20);
    }];
    [_img mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView.mas_right).offset(-16);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-16);
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
    label.numberOfLines = 1;
    label.backgroundColor = [UIColor whiteColor];
    return label;
}

@end
