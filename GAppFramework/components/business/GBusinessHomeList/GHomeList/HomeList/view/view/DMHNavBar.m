//
//  DMHNavBar.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/14.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMHNavBar.h"
#import "DMHFilterModel.h"
#import <GBaseLib/GConvenient.h>
#import <GUILib/GButton.h>
#import <GLocation/GLocation.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>

#define kHOME_NAV_HEIGHT 44
#define kButtonTextImageSpacing 4.f


@interface DMHNavBar()
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) NSArray<DMHHot *> *model;
///> 
@property (nonatomic, assign) BOOL isFull;
///> 
@property (nonatomic, strong) DMHHot *curHot;

///> 视图: 遮挡 
@property (nonatomic, strong) UIView *maskView;
///> 视图: 动画 
@property (nonatomic, strong) UIView *aniView;

///> 视图: 搜索 
@property (nonatomic, strong) UIView *searchView;
///> 按钮: 定位 
@property (nonatomic, strong) GButton *locBtn;
///> 按钮: 签到 
@property (nonatomic, strong) UIButton *signBtn;
///> 视图: 搜索图片 
@property (nonatomic, strong) UIImageView *searchImg;
///> 视图: 热词标签 
@property (nonatomic, strong) UILabel *searchLabel;
///> 视图: 底线 
@property (nonatomic, strong) UIView *line;

@end

@implementation DMHNavBar

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
    if ([tuple.first isEqualToString:@"scroll"]) {
        [self scroll:[tuple.second floatValue]];
    } else if ([tuple.first isEqualToString:@"searchAnimate"]) {
        [self searchAnimate:[tuple.second floatValue]];
    }
}

- (void)scroll:(CGFloat)y {
    // aniView视图
    CGRect anif = self.aniView.frame;
    CGRect sf = self.frame;
    anif.origin.y = STATUSBAR_HEIGHT+y;
    sf.size.height = STATUSBAR_HEIGHT+kHOME_NAV_HEIGHT+y;
    self.aniView.frame = anif;
    self.frame = sf;
}

- (void)searchAnimate:(BOOL)isEx {
    if (_isFull == isEx) return;
    _isFull = isEx;
    [self updateLayout];
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(DMHFilterModel *)model action:(AActionBlock)action {
    CGRect rect = CGRectMake(0, frame.origin.y, SCREEN_WIDTH, STATUSBAR_HEIGHT + kHOME_NAV_HEIGHT);
    if (self = [super initWithFrame:rect]) {
        self.actionBlock = action;
        self.model = model.hots;
        self.isFull = model.isFull;
        self.backgroundColor = HEX(@"ffffff", @"1c1c1E");
        [self addViews];
        [self changeHot];
    }
    return self;
}

- (void)addViews {
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUSBAR_HEIGHT)];
    self.maskView.backgroundColor = HEX(@"ffffff", @"1c1c1E");
    self.aniView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT, SCREEN_WIDTH, kHOME_NAV_HEIGHT)];
    self.searchImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_icon_dark_c"]];
    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, kHOME_NAV_HEIGHT-1, SCREEN_WIDTH, 0.5)];
    self.line.backgroundColor = HEX(@"e5e5e5", @"303033");
    
    [self addSubview:self.aniView];
    [self.aniView addSubview:self.searchView];
    [self.searchView addSubview:self.searchImg];
    [self.searchView addSubview:self.searchLabel];
    [self.aniView addSubview:self.line];
    [self addSubview:self.maskView];

    if (!self.isFull) return;
    
    [self.aniView insertSubview:self.locBtn belowSubview:self.searchView];
    [self.aniView insertSubview:self.signBtn belowSubview:self.searchView];
    @weakify(self);
    [RACObserve([GLocation location], smodel.done) subscribeNext:^(NSString *x) {
        @strongify(self);
        NSString *city = [GLocation location].smodel.city;
        BOOL need = self.locBtn.currentTitle.length != city.length;
        BOOL update = ![self.locBtn.currentTitle isEqualToString:city];
        [self.locBtn setTitle:city forState:UIControlStateNormal];
        [self.locBtn layoutSubviews];
        if (need) [self updateLayout];
        if (update && self.actionBlock) self.actionBlock(RACTuplePack(@"refresh"));
    }];
}

#pragma mark - Layout
///=============================================================================
/// @name Layout
///=============================================================================

- (void)updateLayout {
    @weakify(self);
    [_searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.aniView.mas_centerY);
        if (self.isFull) {
            make.left.equalTo(self.locBtn.mas_right).offset(4);
            make.right.equalTo(self.signBtn.mas_left).offset(-4);
        } else {
            make.left.equalTo(self.aniView.mas_left).offset(16);
            make.right.equalTo(self.aniView.mas_right).offset(-16);
        }
        make.height.equalTo(@(30));
    }];
    [_locBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        CGFloat w = MIN(8, self.locBtn.currentTitle.length) * 16 + 24 + 8 + kButtonTextImageSpacing;
        make.centerY.equalTo(self.aniView.mas_centerY);
        make.left.equalTo(self.aniView.mas_left).offset(4);
        make.height.equalTo(self.aniView.mas_height);
        make.width.equalTo(@(w));
    }];
    [_searchImg mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.searchView.mas_centerY);
        make.left.equalTo(self.searchView.mas_left).offset(8);
        make.height.equalTo(@14);
        make.width.equalTo(@14);
    }];
    [_searchLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.searchImg.mas_right).offset(5);
        make.right.equalTo(self.searchView.mas_right).offset(-12);
        make.centerY.equalTo(self.searchView.mas_centerY);
    }];
    [_signBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        CGFloat w = MIN(8, self.signBtn.currentTitle.length) * 16 + 24;
        make.centerY.equalTo(self.aniView.mas_centerY);
        make.right.equalTo(self.aniView.mas_right).offset(-4);
        make.height.equalTo(self.aniView.mas_height);
        make.width.equalTo(@(w));
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

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [UIView new];
        _searchView.clipsToBounds = YES;
        _searchView.layer.cornerRadius = 2.0f;
        _searchView.backgroundColor = HEX(@"F2F2F2", @"262628");
        @weakify(self);
        [_searchView addTapGesture:^{
            @strongify(self);
            CGRect frame = self.searchView.frame;
            frame.origin.y = 0;
            NSString *params = FORMAT(@"?searchBarFrame=%@", [NSStringFromCGRect(frame) URLEncode]);
            if (self.curHot) {
                NSString *str = [@{@"isHot": @(self.curHot.isHot), @"title":self.curHot.word, @"id":self.curHot.id} modelToJSONString];
                params = FORMAT(@"%@&hotModel=%@", params, [str URLEncode]);
            }
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"search", params));
        }];
    }
    return _searchView;
}

- (UIButton *)signBtn {
    if (!_signBtn) {
        _signBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signBtn setTitle:@"签到" forState:UIControlStateNormal];
        [_signBtn setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateNormal];
        _signBtn.titleLabel.font = FONT(16);
        @weakify(self);
        [_signBtn addEvents:UIControlEventTouchUpInside action:^{
            @strongify(self);
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"sign"));
        }];
    }
    return _signBtn;
}

- (GButton *)locBtn {
    if (!_locBtn) {
        _locBtn = [GButton buttonWithType:UIButtonTypeCustom];
        _locBtn.type = GButtonTypeHorizontalTextImage;
        _locBtn.spacing = 4.0f;
        _locBtn.imgSize = CGSizeMake(9, 9);
        [_locBtn setImage:IMAGE(@"down_arrow_black", @"btn_unfold_dark") forState:UIControlStateNormal];
        [_locBtn setTitle:@"" forState:UIControlStateNormal];
        [_locBtn setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateNormal];
        _locBtn.titleLabel.font = FONT(16);
        @weakify(self);
        [_locBtn addEvents:UIControlEventTouchUpInside action:^{
            @strongify(self);
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"location"));
        }];
    }
    return _locBtn;
}

- (UILabel *)searchLabel {
    if (!_searchLabel) {
        _searchLabel = [UILabel new];
        _searchLabel.textColor = HEX(@"808080", @"AFAFB0");
        _searchLabel.font = FONT(12);
        _searchLabel.text = @"搜索职位";
    }
    return _searchLabel;
}

- (void)changeHot {
    if (self.model.count == 0) return;
    NSInteger rand = arc4random() % self.model.count;
    _searchLabel.text = self.model[rand].word;
    _curHot = self.model[rand];
}

@end
