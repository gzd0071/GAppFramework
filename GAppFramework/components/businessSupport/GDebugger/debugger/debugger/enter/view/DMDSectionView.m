//
//  DMDSectionView.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDSectionView.h"
#import "DMDEnterModel.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <GBaseLib/GConvenient.h>
#import <GLogger/Logger.h>

@interface DMDSectionView()
///> 
@property (nonatomic, strong) UIView *con;
///> 
@property (nonatomic, strong) UILabel *title;

///> 
@property (nonatomic, strong) DMDEnterModel *model;
///> 
@property (nonatomic, strong) NSMutableArray<UIView *> *viewArray;
///> 
@property (nonatomic, strong) AActionBlock block;
@end

@implementation DMDSectionView

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (instancetype)viewWithModel:(id)model action:(AActionBlock)action {
    return [[self alloc] initWithFrame:CGRectZero model:model action:action];
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    if (self = [super initWithFrame:frame]) {
        self.model = model;
        self.block = action;
        [self addViews];
        self.viewArray = [NSMutableArray array];
    }
    return self;
}

- (void)addViews {
    [self addSubview:self.con];
    [self addSubview:self.title];
    [self.model.plugins enumerateObjectsUsingBlock:^(Class<DebuggerPluginDelegate> obj, NSUInteger idx, BOOL *stop) {
        [self addSubViews:obj idx:idx];
    }];
}

- (void)addSubViews:(Class<DebuggerPluginDelegate>)plugin idx:(NSInteger)idx {
    @weakify(self);
    UIView *view = [UIView new];
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat w = (screenW - 52)/4;
    CGFloat h = 60;
    CGFloat x = idx % 4 * w;
    CGFloat y = idx / 4 * (h + 10) + 10;
    
    UIImageView *icon = [UIImageView new];
    if ([plugin respondsToSelector:@selector(pluginIcon)]) {
        icon.image = [plugin pluginIcon];
    } else {
        LOGE(@"[DEBUGGER] => %@ not responder selector:'pluginIcon'.", NSStringFromClass(plugin));
    }
    [view addSubview:icon];
    [icon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(view.mas_top).offset(5);
        make.height.width.equalTo(@(34));
    }];
    
    UILabel *title = [UILabel new];
    title.textColor = HEX(@"666666", @"afafb0");
    title.font = [UIFont systemFontOfSize:12];
    if ([plugin respondsToSelector:@selector(pluginName)]) {
        title.text = [plugin pluginName];
    } else {
        LOGE(@"[DEBUGGER] => %@ not responder selector:'pluginIcon'.", NSStringFromClass(plugin));
    }
    [view addSubview:title];
    [title mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(icon.mas_bottom).offset(5);
    }];
    
    [self addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.title.mas_bottom).offset(y);
        make.left.equalTo(self.title.mas_left).offset(x);
        make.height.equalTo(@(h));
        make.width.equalTo(@(w));
        if (idx == self.model.plugins.count - 1) {
            make.bottom.equalTo(self.con.mas_bottom).offset(-16);
        }
    }];
    view.tag = 222 + idx;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    NSInteger tag = sender.view.tag - 222;
    if (self.block) self.block(self.model.plugins[tag]);
}

#pragma mark - Layout
///=============================================================================
/// @name Layout
///=============================================================================

- (void)updateLayout {
    @weakify(self);
    [_con mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(5, 10, 5, 10));
    }];
    [_title mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.left.equalTo(self.con).offset(16);
        if (self.model.plugins.count == 0) {
            make.bottom.equalTo(self.con.mas_bottom).offset(-16);
        }
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

- (UIView *)con {
    if (!_con) {
        _con = [UIView new];
        _con.backgroundColor = HEX(@"ffffff", @"262628");
        _con.layer.cornerRadius = 5;
        _con.clipsToBounds = YES;
    }
    return _con;
}

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        _title.textColor = HEX(@"#324456", @"dddddd");
        _title.font = FONT_BOLD(16);
        _title.text = self.model.title;
    }
    return _title;
}

@end
