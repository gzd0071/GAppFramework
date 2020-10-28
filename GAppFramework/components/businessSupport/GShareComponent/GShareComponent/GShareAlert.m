//
//  GShareAlert.m
//  GShareComponent
//
//  Created by iOS_Developer_G on 2019/11/30.
//

#import "GShareAlert.h"
#import <GUILib/GButton.h>
#import <GUILib/GShow.h>
#import <GTask/GTask.h>
#import <GBaseLib/GConvenient.h>

#define kDMSAlertPerCount 4
#define kDMSAlertBtnWidth 76
#define kDMSAlertBtnHeight 101
#define kDMSAlertCancelHeight 44

@interface GShareAlert ()
///> 组件: 动画执行器
@property (nonatomic, strong) GShow *show;
///> 任务: 生命周期管理者
@property (nonatomic, strong) GTaskSource *tcs;
///> 数据: 场景
@property (nonatomic, strong) NSArray *list;
@end

@implementation GShareAlert

/// 分享弹框
/// @param scene 分享的场景
+ (GTask *)alert:(GShareScene)scene {
    GShareAlert *alert = [[GShareAlert alloc] initWithFrame:CGRectZero scene:scene];
    alert.show = [GShow show:alert];
    return alert.tcs.task;
}

- (instancetype)initWithFrame:(CGRect)frame scene:(GShareScene)scene {
    NSArray *list = [self getList:scene];
    frame = CGRectMake(0, 0, SCREEN_WIDTH, ((list.count-1)/kDMSAlertPerCount+1)*kDMSAlertBtnHeight + 12 + kDMSAlertCancelHeight);
    if (self = [super initWithFrame:frame]) {
        _tcs = [GTaskSource source];
        _list = list;
        self.backgroundColor = HEX(@"f7f7f7", @"1c1c1e");
        [self addViews];
    }
    return self;
}

#pragma mark - Views
///=============================================================================
/// @name Views
///=============================================================================

- (void)addViews {
    [self addSubview:self.btns];
    [self addSubview:self.cancel];
}

- (UIView *)btns {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, self.width, self.height-10-kDMSAlertCancelHeight);
    view.backgroundColor = HEX(@"ffffff", @"262628");
    
    NSInteger count = MIN(self.list.count, kDMSAlertPerCount);
    CGFloat w = kDMSAlertBtnWidth;
    CGFloat space = (self.width - w * count) / (count + 1);
    [self.list enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        GButton *btn = [GButton buttonWithType:UIButtonTypeCustom];
        btn.type = GButtonTypeVerticalImageText;
        btn.spacing = 8;
        btn.titleLabel.font = FONT(14);
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:HEX(@"404040", @"dddddd") forState:UIControlStateNormal];
        [btn setTitle:[self title:obj.integerValue] forState:UIControlStateNormal];
        [btn setImage:[self img:obj.integerValue] forState:UIControlStateNormal];
        CGFloat x = idx%kDMSAlertPerCount * (space+w) + space;
        CGFloat y = (idx / kDMSAlertPerCount) * 74;
        btn.frame = CGRectMake(x, y, w, kDMSAlertBtnHeight);
        [view addSubview:btn];
        [btn addEvents:UIControlEventTouchUpInside action:^{
            [self.show dismiss:YES];
            [self.tcs setResult:obj];
        }];
    }];
    return view;
}

- (UIView *)cancel {
    UILabel *label = [UILabel new];
    label.font = FONT(16);
    label.textColor = HEX(@"404040", @"dddddd");
    label.text = @"取消";
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(0, self.height-kDMSAlertCancelHeight, SCREEN_WIDTH, kDMSAlertCancelHeight);
    label.backgroundColor = HEX(@"ffffff", @"262628");
    [label addTapGesture:^{
        [self.show dismiss:YES];
    }];
    return label;
}

#pragma mark - Functions
///=============================================================================
/// @name Functions
///=============================================================================

- (NSString *)title:(GShareScene)scene {
    switch (scene) {
        case GShareSceneWXSession:  return @"微信";
        case GShareSceneWXTimeline: return @"朋友圈";
        case GShareSceneQQ:         return @"QQ";
        case GShareSceneQQZone:     return @"QQ空间";
        default: return @"未知";
    }
}

- (UIImage *)img:(GShareScene)scene {
    switch (scene) {
        case GShareSceneWXSession:  return IMAGE(@"share_wx");
        case GShareSceneWXTimeline: return IMAGE(@"share_wxtimeline");
        case GShareSceneQQ:         return IMAGE(@"share_qq");
        case GShareSceneQQZone:     return IMAGE(@"share_qqzone");
        default: return nil;
    }
}

- (NSArray *)getList:(GShareScene)scene {
    NSMutableArray *arr = @[].mutableCopy;
    if (scene & GShareSceneWXSession) {
        [arr addObject:@(GShareSceneWXSession)];
    }
    if (scene & GShareSceneWXTimeline) {
        [arr addObject:@(GShareSceneWXTimeline)];
    }
    if (scene & GShareSceneQQ) {
        [arr addObject:@(GShareSceneQQ)];
    }
    if (scene & GShareSceneQQZone) {
        [arr addObject:@(GShareSceneQQZone)];
    }
    return arr.copy;
}

@end
