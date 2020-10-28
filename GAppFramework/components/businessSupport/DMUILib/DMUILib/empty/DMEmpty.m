//
//  DMEmpty.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/18.
//

#import "DMEmpty.h"
#import <YYKit/UIImage+YYAdd.h>

@interface DMEmptyModel : NSObject<DMEmptyDataSource>
///> 类型
@property (nonatomic, assign) DMEmptyType type;
///> 空页: 按钮文案
@property (nonatomic, strong) id btnTxt;
///> 空页: 提示文案
@property (nonatomic, strong) id txt;
///> 空页: 图片
@property (nonatomic, strong) UIImage *image;
@end
@implementation DMEmptyModel
- (UIColor *)emptyBackgroundColor {
    return HEX(@"ffffff", @"1c1c1e");
}
- (id)emptyButtonBackgroundImage:(UIControlState)state {
    return [UIImage imageWithColor:HEX(@"ffcc00")];
}
- (id)emptyTxt {
    if ([_txt isKindOfClass:NSAttributedString.class]) return _txt;
    return [self txtAttr:_txt?:[self txtWithType:self.type]];
}
- (CGFloat)emptyButtonCornerRadius {
    return 4;
}
- (NSAttributedString *)txtAttr:(NSString *)txt {
    id attrs = @{NSForegroundColorAttributeName:HEX(@"646464"),
                 NSFontAttributeName:FONT(14)};
    return [[NSAttributedString alloc] initWithString:txt attributes:attrs];
}
- (id)emptyButtonTxt:(UIControlState)state {
    if ([_btnTxt isKindOfClass:NSAttributedString.class]) return _btnTxt;
    return [self btnTxtAttr:_btnTxt?:[self btnTxtWithType:self.type]];
}
- (NSAttributedString *)btnTxtAttr:(NSString *)txt {
    id attrs = @{NSForegroundColorAttributeName:HEX(@"404040"),
                 NSFontAttributeName:FONT(16)};
    return [[NSAttributedString alloc] initWithString:txt attributes:attrs];
}

- (UIImage *)emptyImage {
    if (self.image) return self.image;
    switch (self.type) {
        case DMEmptyTypeNoData:
        case DMEmptyTypeNoDataWithButton:
            return IMAGE(@"empty_nodata");
        case DMEmptyTypeNoFound:
        case DMEmptyTypeNoFoundWithButton:
            return IMAGE(@"empty_nofound");
        case DMEmptyTypeNetwork:
        case DMEmptyTypeNetworkWithButton:
            return IMAGE(@"empty_nonetwork");
        case DMEmptyTypeServerError:
        case DMEmptyTypeServerErrorWithButton:
            return IMAGE(@"empty_noserver");
        default:
            return nil;
    }
}
- (NSString *)txtWithType:(DMEmptyType)type {
    switch (self.type) {
        case DMEmptyTypeNoData:
        case DMEmptyTypeNoDataWithButton:
            return @"还没有内容噢~~";
        case DMEmptyTypeNoFound:
        case DMEmptyTypeNoFoundWithButton:
            return @"您搜索的职位未找到噢～～";
        case DMEmptyTypeNetwork:
        case DMEmptyTypeNetworkWithButton:
            return @"您还木有连接到网络哦，请检查网络";
        case DMEmptyTypeServerError:
        case DMEmptyTypeServerErrorWithButton:
            return @"服务器开小差，点击重新加载";
        default:
            return nil;
    }
}
- (NSString *)btnTxtWithType:(DMEmptyType)type {
    switch (self.type) {
        case DMEmptyTypeNoData:
        case DMEmptyTypeNetwork:
        case DMEmptyTypeNoFound:
        case DMEmptyTypeServerError:
            return @"";
        case DMEmptyTypeNoDataWithButton:
        case DMEmptyTypeNoFoundWithButton:
        case DMEmptyTypeNetworkWithButton:
            return @"点击重试";
        case DMEmptyTypeServerErrorWithButton:
            return @"重新加载";
        default:
            return @"重新加载";
    }
}
@end

@interface DMEmpty ()
///> 数据: 样式 
@property (nonatomic, strong) id<DMEmptyDataSource> model;
///> 事件: 
@property (nonatomic, strong) AActionBlock action;
///> 任务: 
@property (nonatomic, strong) GTaskSource *tcs;

///> 视图: 图片 
@property (nonatomic, strong) UIImageView *imageView;
///> 视图: 按钮 
@property (nonatomic, strong) UIButton *button;
///> 视图: 文案 
@property (nonatomic, strong) UILabel *text;
@end

@implementation DMEmpty

#pragma mark - Public
///=============================================================================
/// @name Public
///=============================================================================

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

+ (instancetype)emptyWithframe:(CGRect)frame model:(id<DMEmptyDataSource>)model
                        action:(AActionBlock)action {
    return [[self alloc] initWithFrame:frame model:model action:action];
}

+ (instancetype)emptyWithframe:(CGRect)frame type:(DMEmptyType)type action:(AActionBlock)action {
    return [self emptyWithframe:frame msg:nil type:type action:action];
}

+ (instancetype)emptyWithframe:(CGRect)frame msg:(NSString *)msg type:(DMEmptyType)type action:(AActionBlock)action {
    DMEmptyModel *model = [DMEmptyModel new];
    model.type = type;
    model.txt  = msg;
    return [[self alloc] initWithFrame:frame model:model action:action];
}

- (instancetype)initWithFrame:(CGRect)frame model:(id)model action:(AActionBlock)action {
    if (self = [super initWithFrame:frame]) {
        _action = action;
        _model  = model;
        _tcs    = [GTaskSource source];
        [self addViews];
    }
    return self;
}

- (void)addViews {
    self.imageView = [UIImageView new];
    self.text      = [UILabel new];
    self.button    = [UIButton new];
    self.button.clipsToBounds = YES;
    [self addSubview:self.imageView];
    [self addSubview:self.text];
    [self addSubview:self.button];
    
    [self updateData];
    [self updateFrame];
}

- (void)updateData {
    if ([self.model respondsToSelector:@selector(emptyBackgroundColor)]) {
        self.backgroundColor       = [self.model respondsToSelector:@selector(emptyBackgroundColor)] ? self.model.emptyBackgroundColor : HEX(@"ffffff", @"1c1c1e");
    }
    id txt = self.model.emptyTxt;
    if ([txt isKindOfClass:NSString.class]) {
        self.text.text = txt;
    } else {
        self.text.attributedText       = txt;
    }
    self.imageView.image           = self.model.emptyImage;
    self.button.layer.cornerRadius = self.model.emptyButtonCornerRadius;
    if (![self.model respondsToSelector:@selector(emptyButtonTxt:)] || [[self.model emptyButtonTxt:UIControlStateNormal] length] == 0) {
        self.button.hidden = YES;
        return;
    }
    [self.button setAttributedTitle:[self.model emptyButtonTxt:UIControlStateNormal] forState:UIControlStateNormal];
    [self.button setAttributedTitle:[self.model emptyButtonTxt:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [self.button setAttributedTitle:[self.model emptyButtonTxt:UIControlStateSelected] forState:UIControlStateSelected];
    [self.button setBackgroundImage:[self.model emptyButtonBackgroundImage:UIControlStateNormal] forState:UIControlStateNormal];
    [self.button setBackgroundImage:[self.model emptyButtonBackgroundImage:UIControlStateHighlighted] forState:UIControlStateHighlighted];
    [self.button setBackgroundImage:[self.model emptyButtonBackgroundImage:UIControlStateSelected] forState:UIControlStateSelected];
    [self.button addTarget:self action:@selector(tapAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateFrame {
    self.text.numberOfLines = 0;
    self.text.preferredMaxLayoutWidth = self.width - 64;
    [self.text sizeToFit];
    self.imageView.size = CGSizeMake(self.imageView.image.size.width, self.imageView.image.size.height);
    if ([self.model respondsToSelector:@selector(emptyButtonSpace)]) {
        self.button.size = CGSizeMake(self.width-2*[self.model emptyButtonSpace], 44);
    } else {
        self.button.size = CGSizeMake(180, 44);
    }
    CGFloat it = 26;
    CGFloat tb = 26;
    self.imageView.top = 100;//(self.height - self.imageView.height - self.text.height - self.button.height - it - tb)/2;
    self.text.centerX  = self.button.centerX = self.imageView.centerX = self.centerX;
    self.text.top      = self.imageView.bottom + it;
    self.button.top    = self.text.bottom + tb;
}

- (void)tapAction {
    [self removeFromSuperview];
    if (self.action) self.action();
}

@end


@implementation UIView (DMEmpty)

- (DMEmpty *)showEmptySouce:(id<DMEmptyDataSource>)model {
    return [self showEmptySouce:model action:nil];
}

- (DMEmpty *)showEmptySouce:(id<DMEmptyDataSource>)model action:(AActionBlock)action {
    DMEmpty *empty = [DMEmpty emptyWithframe:self.bounds model:model action:action];
    [self addSubview:empty];
    return empty;
}

- (DMEmpty *)showEmpty:(DMEmptyType)type {
    return [self showEmpty:type msg:nil];
}

- (DMEmpty *)showEmpty:(DMEmptyType)type action:(AActionBlock)action {
    return [self showEmpty:type msg:nil action:action];
}

- (DMEmpty *)showEmpty:(DMEmptyType)type msg:(NSString *)msg {
    return [self showEmpty:type msg:msg action:nil];
}

- (DMEmpty *)showEmpty:(DMEmptyType)type msg:(NSString *)msg action:(AActionBlock)action {
    DMEmpty *empty = [DMEmpty emptyWithframe:self.bounds msg:msg type:type action:action];
    [self addSubview:empty];
    return empty;
}

@end
