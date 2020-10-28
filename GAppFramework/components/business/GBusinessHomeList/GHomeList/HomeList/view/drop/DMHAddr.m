//
//  DMHAddr.m
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/11/27.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import "DMHAddr.h"
#import <GUILib/GShow.h>
#import "DMHFilterModel.h"
#import "DMHCity.h"
#import <GConst/URDConst.h>
#import <GRouter/GRouter.h>

// MARK: DMHAddr
////////////////////////////////////////////////////////////////////////////////
/// @@class DMHAddr
////////////////////////////////////////////////////////////////////////////////

@interface DMHAddr ()<GShowActionDelegate, GShowAnimateDelegate>
///> 动画
@property (nonatomic, strong) GShow *show;
///> 类型: 商圈 0/住址 1
@property (nonatomic, assign) NSInteger type;
///> 类型: 上次 选中
@property (nonatomic, strong) UILabel *last;
///> 类型: 住址选中
@property (nonatomic, assign) NSInteger ntype;

/// 事件:
@property (nonatomic, copy) AActionBlock actionBlock;
/// 数据
@property (nonatomic, strong) id oriModel;
/// 数据:
@property (nonatomic, strong) FilterItem *model;
/// 视图: 包容功能视图
@property (nonatomic, strong) UIView *con;
/// 视图: 城市选择
@property (nonatomic, strong) DMHCity *city;
/// 视图: 住址
@property (nonatomic, strong) UIView *addr;

/// 移动视图
@property (nonatomic, weak) UIView *sview;
///
@property (nonatomic, strong) UIView *menu;
///
@property (nonatomic, assign) CGRect mframe;
@end

@implementation DMHAddr

#pragma mark - DMHDropDelegate
///=============================================================================
/// @name DMHDropDelegate
///=============================================================================

+ (id)show:(id)model block:(AActionBlock)block view:(UIView *)view {
    DMHAddr *sub = [[self alloc] initWithFrame:CGRectZero model:model action:block];
    sub.sview = view.superview;
    sub.menu = view;
    sub.mframe = view.frame;
    sub.show = [GShow show:sub type:GShowAnimateTypeCustomFrame com:^(BOOL finish){
        view.frame  = CGRectMake(0, 0, view.width, view.height);
        sub.frame   = CGRectMake(0, sub.top-93, sub.width, sub.height+93);
        sub.con.top = 93;
        [sub insertSubview:view atIndex:0];
    }];
    return sub;
}

- (void)returnView {
    self.menu.frame = self.mframe;
    [self.sview addSubview:self.menu];
    self.frame   = CGRectMake(0, self.top+93, self.width, self.height-93);
    self.con.top = 0;
}

- (void)dismiss:(BOOL)animated com:(nullable void (^)(BOOL))comp {
    [self returnView];
    _model.select = !_model.select;
    [self.city dismiss:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.show dismiss:animated completion:comp];
    });
}

- (NSString *)dropType {
    return FMV_CITY;
}

#pragma mark - GShowActionDelegate
///=============================================================================
/// @name GShowActionDelegate
///=============================================================================

- (void)backTapAction {
    [self dismiss:YES com:^(BOOL finish) {
        if (self.actionBlock) self.actionBlock(RACTuplePack(@"cancel"));
    }];
}
- (UIEdgeInsets)backInsets {
    return UIEdgeInsetsMake(STATUSBAR_HEIGHT+93, 0, 0, 0);
}
- (CGRect)showFrameAnimation {
    CGRect frame = self.frame;
    frame.size.height = kMENUHEIGHT;
    return frame;
}
- (CGRect)dismissFrameAnimation {
    CGRect frame = self.frame;
    frame.size.height = 0;
    return frame;
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame model:(RACTuple *)model action:(AActionBlock)action {
    CGRect rect = CGRectMake(0, STATUSBAR_HEIGHT+93, SCREEN_WIDTH, 0);
    if (self = [super initWithFrame:rect]) {
        self.oriModel = model;
        self.clipsToBounds = YES;
        self.model = model.first;
        self.actionBlock = action;
        self.con = [UIView new];
        self.con.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        self.con.frame = CGRectMake(0, 0, SCREEN_WIDTH, kMENUHEIGHT);
        [self addSubview:self.con];
        [self addTypes];
        [self addCitys];
        [self addAddrs];
    }
    return self;
}

- (void)addTypes {
    UIScrollView *scro = [UIScrollView new];
    scro.frame = CGRectMake(0, 0, 100, kMENUHEIGHT);
    scro.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
    [self.con addSubview:scro];
    
    UIView *ani = [UIView new];
    ani.frame = CGRectMake(0, 16, 3, 14);
    ani.backgroundColor = HEX(@"ffaa00", @"ff8800");
    [scro addSubview:ani];
    __block UIView *last;
    [@[@"商圈", @"住址"] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        UIView *view = [UIView new];
        view.frame = CGRectMake(0, idx*46, 100, 46);
        
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(16, 0, 84, 46);
        label.font = FONT(14);
        label.text = obj;
        label.textColor = idx==self.type? HEX(@"ffaa00", @"ff8800") : HEX(@"404040", @"dddddd");
        label.font = idx==self.type ? FONT_BOLD(14) : FONT(14);
        [view addSubview:label];
        if (idx == self.type) self.last = label;
        
        [view addTapGesture:^{
            if (idx == self.type) return;
            self.type = idx;
            ani.top = 46*idx + 16;
            label.textColor = HEX(@"ffaa00", @"ff8800");
            label.font = FONT_BOLD(14);
            self.last.textColor = HEX(@"404040", @"dddddd");
            self.last.font = FONT(14);
            self.last = label;
            self.addr.hidden = self.type == 0;
            self.city.hidden = self.type == 1;
        }];
        last = view;
        [scro insertSubview:view belowSubview:ani];
    }];
    scro.contentSize = CGSizeMake(scro.width, MAX(scro.height+1, last.bottom));
}

/// 添加:商圈
- (void)addCitys {
    self.city = [DMHCity viewWithFrame:CGRectZero model:self.oriModel action:^(id x){
        [self dismiss:YES com:nil];
        if (self.actionBlock) self.actionBlock(x);
    }];
    [self.con addSubview:self.city];
}
/// 添加:住址
- (void)addAddrs {
    [self.con addSubview:self.addr];
    [self.addr addSubview:self.addrDetail];
    [self addNearBy];
}

- (UIView *)addr {
    if (_addr) return _addr;
    _addr = [UIView new];
    _addr.hidden = YES;
    _addr.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    _addr.frame = CGRectMake(100, 0, SCREEN_WIDTH-100, kMENUHEIGHT);
    return _addr;
}
/// 居住地详情
- (UIView *)addrDetail {
    UIView *view = [UIView new];
    view.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
    view.frame = CGRectMake(16, 16, self.addr.width-32, 58);
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 4;
    
    UILabel *title = [UILabel new];
    title.font = FONT_BOLD(14);
    title.textColor = HEX(@"404040", @"dddddd");
    title.text = @"添加居住地址";
    title.frame = CGRectMake(12, 8, view.width-24-19, 22);
    [view addSubview:title];
    
    UILabel *sub = [UILabel new];
    sub.font = FONT(12);
    sub.textColor = HEX(@"808080", @"787899");
    sub.text = @"为您推荐家门口的好工作";
    sub.frame = CGRectMake(12, 30, view.width-24-19, 20);
    [view addSubview:sub];
    
    UIImageView *img = [UIImageView new];
    img.image = IMAGE(@"msg_interview_arrow_right");
    img.frame = CGRectMake(view.width-24, 23, 12, 12);
    [view addSubview:img];
    
    [view addTapGesture:^{
        [GRouter router:URD(URD_RESIDENCE) params:@YES]
        .then(^id(GTaskResult *t) {
            if (t.suc) {
//                title.text = t.data.name;
//                sub.text = t.data.address;
            }
            return nil;
        });
    }];
    return view;
}
/// 距离选择列表
- (void)addNearBy {
    UIScrollView *scro = [UIScrollView new];
    scro.frame = CGRectMake(0, 90, self.addr.width, self.addr.height-90);
    scro.backgroundColor = HEX(@"ffffff", @"1c1c1e");
    [self.addr addSubview:scro];

    __block UIView *last;
    [@[@"附近", @"1km", @"3km", @"5km", @"10km"] enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        UIView *view = [UIView new];
        view.frame = CGRectMake(0, idx*56, scro.width, 56);
        
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(16, 0, view.width-32, 56);
        label.text = obj;
        label.tag  = 222;
        label.textColor = idx==self.ntype? HEX(@"ffaa00", @"ff8800") : HEX(@"404040", @"dddddd");
        label.font = idx==self.ntype ? FONT_BOLD(14) : FONT(14);
        [view addSubview:label];
        
        [view addTapGesture:^{
            self.model.sname = (idx==0)?@"附近":FORMAT(@"附近 %@", obj);
            if (self.actionBlock) self.actionBlock(RACTuplePack(@"nearSelect", obj));
            [self dismiss:YES com:nil];
            
            if (idx == self.ntype) return;
            label.textColor = HEX(@"ffaa00", @"ff8800");
            label.font = FONT_BOLD(14);
            UILabel *last = [scro.subviews[self.ntype] viewWithTag:222];
            last.textColor = HEX(@"404040", @"dddddd");
            last.font = FONT(14);
            self.ntype = idx;
        }];
        last = view;
        [scro addSubview:view];
    }];
    scro.contentSize = CGSizeMake(scro.width, MAX(scro.height+1, last.bottom));
}

@end
