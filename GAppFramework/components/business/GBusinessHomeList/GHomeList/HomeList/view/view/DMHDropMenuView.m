//
//  DMHDropMenuView.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/13.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMHDropMenuView.h"
#import <GBaseLib/GConvenient.h>
#import <GUILib/GButton.h>
#import <ReactiveObjC/RACSignal.h>
#import <ReactiveObjC/NSObject+RACPropertySubscribing.h>

#define MENU_TOP_HEIGHT 48
#define MENU_BOT_HEIGHT 45
#define MENU_EDIT_WIDTH 70

@interface DMHDropMenuView ()
#pragma mark - inherent
///>  
@property (nonatomic, copy) AActionBlock actionBlock;
///> 
@property (nonatomic, strong) DMHFilterModel *model;

///> 
@property (nonatomic, strong) UIScrollView *topView;
///> 
@property (nonatomic, strong) UIView *botView;
///> 
@property (nonatomic, strong) UIView *ani;
///>  
@property (nonatomic, strong) UIView *edit;

///> 
@property (nonatomic, assign) NSInteger topSelect;
///>
@property (nonatomic, strong) UIImageView  *featImg;
///>
@property (nonatomic, strong) NSMutableArray<UIView *> *tags;
@end

@implementation DMHDropMenuView

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (id)viewWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    return [[self alloc] initWithFrame:frame model:model action:action];
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    CGRect rect = CGRectMake(0, frame.origin.y, SCREEN_WIDTH, MENU_TOP_HEIGHT + MENU_BOT_HEIGHT);
    if (self = [super initWithFrame:rect]) {
        self.actionBlock = action;
        self.model = model;
        self.tags  = @[].mutableCopy;
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.topView = [UIScrollView new];
    self.topView.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    self.topView.showsVerticalScrollIndicator = NO;
    self.topView.showsHorizontalScrollIndicator = NO;
    self.topView.scrollEnabled = YES;
    self.botView = [UIView new];
    self.botView.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    
    self.layer.shadowColor = [HEX(@"000000") colorWithAlphaComponent:0.05].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowOpacity = 1;
    [self addSubview:self.topView];
    if (self.model.isFull) [self addEdit];
    [self addSubview:self.botView];
    self.topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, MENU_TOP_HEIGHT);

    @weakify(self);
    [RACObserve(self.model, filterTabs) subscribeNext:^(NSArray<FilterItem *> *tabs) {
        @strongify(self);
        [self addTopItems:tabs];
        BOOL showEdit = self.model.isFull;
        self.edit.hidden = !showEdit;
        self.topView.contentInset = UIEdgeInsetsMake(0, 6, 0, showEdit?70:0);
        self.topView.contentOffset = CGPointMake(-6, 0);
        self.botView.frame = CGRectMake(0, MENU_TOP_HEIGHT, SCREEN_WIDTH, MENU_BOT_HEIGHT);
    }];
    [RACObserve(self.model, filterMenus) subscribeNext:^(NSArray<FilterItem *> *menus) {
        @strongify(self);
        [self addBotItems:menus];
    }];
}

#pragma mark - Getters
///=============================================================================
/// @name Getters
///=============================================================================

- (void)addTopItems:(NSArray<FilterItem *> *)array  {
    self.topSelect = 0;
    [self.topView setContentOffset:CGPointMake(-6, 0)];
    for (UIView *view in self.topView.subviews) {
        [view removeFromSuperview];
    }
    [self.tags removeAllObjects];
    if (!array || array.count == 0) return;
    
    CGFloat aniH = 4;
    CGFloat left = ([array objectAtIndex:0].name.length * 18 + 20)/2-18;
    UIView *ani = [[UIView alloc] initWithFrame:CGRectMake(left, MENU_TOP_HEIGHT-18, 36, aniH)];
    ani.layer.cornerRadius = aniH/2;
    ani.layer.masksToBounds = YES;
    ani.backgroundColor = HEX(@"FFD630", @"1c1c1e");
    self.ani = ani;
    [self.topView insertSubview:ani belowSubview:self.topView];
    
    __block BOOL hasFeature = NO;
    @weakify(self);
    [array enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        CGRect frame = idx == 0 ? CGRectZero : self.tags[idx-1].frame;
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateNormal];
        [btn setTitleColor:HEX(@"404040", @"dd9504") forState:UIControlStateSelected];
        [btn setTitle:obj.name forState:UIControlStateNormal];
        btn.titleLabel.font = FONT(16);
        [btn sizeToFit];
        CGFloat w = btn.width + 20;
        btn.frame = CGRectMake(frame.origin.x+frame.size.width, 0, w, MENU_TOP_HEIGHT);
        btn.titleLabel.font = (idx == 0) ? FONT_BOLD(18) : FONT(16);
        if (idx == 0) btn.selected = YES;
        if (idx == array.count -1) self.topView.contentSize = CGSizeMake(btn.frame.origin.x+w, MENU_TOP_HEIGHT);
        [btn addEvents:UIControlEventTouchUpInside action:^{
            [self animate:idx];
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"tabTap", obj, @(idx)));
        }];
        [self.topView addSubview:btn];
        if ([obj.key isEqualToString:FMV_FEATURE]) {
            if (!self.featImg.superview) [self.topView addSubview:self.featImg];
            self.featImg.frame = CGRectMake(frame.origin.x+frame.size.width+w - 19, 5, 28, 20);
            hasFeature = YES;
        }
        [self.tags addObject:btn];
    }];
    self.featImg.hidden = !hasFeature;
}

- (void)animate:(NSInteger)cur {
    if (cur >= self.tags.count) return;
    UIButton *pbtn = (UIButton *)self.tags[self.topSelect];
    UIButton *btn = (UIButton *)self.tags[cur];
    pbtn.selected = NO;
    pbtn.titleLabel.font = FONT(16);
    btn.selected = YES;
    btn.titleLabel.font = FONT_BOLD(18);
    NSInteger pad = self.topSelect - cur;
    if (pad < 0) pad = 0 - pad;
    CGFloat time = (MIN(pad, 4)/4.0) * 0.1;
    self.topSelect = cur;
    
    CGFloat w = SCREEN_WIDTH - (self.model.isFull?MENU_EDIT_WIDTH:0);
    CGPoint point = self.topView.contentOffset;
    CGFloat offx = btn.x - point.x;
    CGFloat minSW = MAX(self.topView.contentSize.width, w);
    if (offx + btn.width/2 > w/2) {
        point.x = MIN(minSW-w, btn.x-w/2+btn.width/2);
    } else {
        point.x = MIN(MAX(0, btn.x-w/2+btn.width/2), minSW-w);
    }
    if (cur == 0 || point.x == 0) point.x = -6;
    
    CGRect frame = _ani.frame;
    frame.origin.x = btn.centerX-18;
    @weakify(self);
    [UIView animateWithDuration: time + 0.1 animations:^{
        @strongify(self);
        self.ani.frame = frame;
        self.topView.contentOffset = point;
    }];
}

- (void)viewAction:(RACTuple *)x {
    if ([x.first isEqualToString:@"scrollChange"] && self.topSelect != [x.second integerValue]) {
        [self animate:[x.second integerValue]];
        if (self.botView.frame.origin.x == 0 || self.botView.frame.origin.x == SCREEN_WIDTH) [self botViewAnimate:[x.second integerValue]];
    }  else if ([x.first isEqualToString:@"scroll"]) {
        [self botViewAnimate:[x.second floatValue]];
    }
}

- (void)botViewAnimate:(CGFloat)offset {
    BOOL hasD = NO;
    if (!hasD) return;
    
    CGRect frame = self.botView.frame;
    if (frame.origin.x == 0 && offset > 1) return;
    frame.origin.x = frame.size.width * MAX(0, 1- offset);
    self.botView.frame = frame;
}

- (void)addBotItems:(NSArray<FilterItem *> *)array {
    for (UIView *view in self.botView.subviews) {
        [view removeFromSuperview];
    }
    if (!array || array.count == 0) return;
    
    CGFloat space = 19;
    CGFloat w = (SCREEN_WIDTH - space * (array.count + 1)) / array.count;
    CGFloat h = 28;
    
    @weakify(self);
    [array enumerateObjectsUsingBlock:^(FilterItem *obj, NSUInteger idx, BOOL *stop) {
        BOOL hasChild = obj.filterItems && obj.filterItems.count > 0;
        UIButton *btn = [self botBtn:obj hasChild:hasChild];
        btn.frame = CGRectMake(idx * w + (idx+1) * space, 5, w, h);
        
        [RACObserve(obj, select) subscribeNext:^(id x) {
            btn.selected = ([x boolValue] || obj.sname.length);
            if (hasChild) [btn setImage:IMAGE([x boolValue] ? @"btn_unfold_selected" : @"btn_unfold_normal1") forState:UIControlStateSelected];
            [btn setTitle:obj.sname.length ? obj.sname : obj.name forState:UIControlStateNormal];
            btn.backgroundColor = (btn.selected) ? HEX(@"ffffff", @"1c1c1e") : HEX(@"f7f7f7", @"262628");
            btn.layer.borderWidth = (btn.selected) ? 0.5 : 0;
        }];
        @strongify(self);
        [btn addEvents:UIControlEventTouchUpInside action:^{
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"menuTap", obj));
        }];
        [self.botView addSubview:btn];
    }];
}

- (UIButton *)botBtn:(FilterItem *)item hasChild:(BOOL)has {
    GButton *btn = [GButton buttonWithType:UIButtonTypeCustom];
    if (has) {
        UIImage *nor = IMAGE(@"btn_unfold_normal");
        [btn setImage:nor forState:UIControlStateNormal];
        [btn setImage:IMAGE(@"btn_unfold_selected") forState:UIControlStateSelected];
    }
    btn.backgroundColor =  HEX(@"f7f7f7", @"000000");
    btn.layer.borderWidth =  0;
    UIColor *norC =  HEX(@"404040", @"dddddd");
    [btn setTitleColor:norC forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"FFAA00") forState:UIControlStateSelected];
    [btn setTitle:item.name forState:UIControlStateNormal];
    btn.titleLabel.font = FONT(12);
    btn.layer.cornerRadius = 2;
    btn.clipsToBounds = YES;
    btn.layer.borderColor = HEX(@"FFAA00").CGColor;
    btn.type = GButtonTypeHorizontalTextImage;
    if (has) btn.spacing = 2;
    return btn;
}

- (void)addEdit {
    GButton *btn = [GButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(SCREEN_WIDTH-MENU_EDIT_WIDTH, 0, MENU_EDIT_WIDTH, MENU_TOP_HEIGHT);
    btn.backgroundColor = [HEX(@"ffffff", @"1c1c1e") colorWithAlphaComponent:1];
    btn.titleLabel.font = FONT(12);
    btn.clipsToBounds = NO;
    [btn setTitle:@"编辑" forState:UIControlStateNormal];
    [btn setTitleColor:HEX(@"808080", @"AFAFB0") forState:UIControlStateNormal];
    [btn setImage:IMAGE(@"edit") forState:UIControlStateNormal];
    @weakify(self);
    [btn addEvents:UIControlEventTouchUpInside action:^{
        @strongify(self);
        self.actionBlock(RACTuplePack(@"edit"));
    }];
    btn.layer.shadowColor = [HEX(@"000000") colorWithAlphaComponent:0.2].CGColor;
    btn.layer.shadowOffset = CGSizeMake(2, 0);
    btn.layer.shadowOpacity = 1;
    btn.layer.masksToBounds = NO;
    CGRect frame = CGRectMake(0-0.5, 0, 1, btn.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:frame];
    btn.layer.shadowPath = path.CGPath;
    btn.type = GButtonTypeHorizontalImageText;
    btn.spacing = 4;
    self.edit = btn;
    [self addSubview:btn];
}

- (UIImageView *)featImg {
    if (!_featImg) {
        _featImg = [UIImageView new];
        _featImg.image = IMAGE(@"fast_tag");
    }
    return _featImg;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) return nil;
    return view;
}

@end
