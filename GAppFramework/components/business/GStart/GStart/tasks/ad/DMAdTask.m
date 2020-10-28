//
//  DMAdTask.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/11.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMAdTask.h"
#import <SDWebImage/SDWebImageManager.h>
#import <GPermission/GPermission.h>
#import <YYKit/NSObject+YYModel.h>
#import <GBaseLib/GConvenient.h>
#import <GTask/GTask+Fwd.h>
#import <GLocation/GLocation.h>
#import <GHttpRequest/HttpRequest.h>

@interface DMAdModel : NSObject
///> 广告: 类型(0:斗米自营)
@property (nonatomic, assign) NSInteger type;
///> 广告: 倒计时
@property (nonatomic, assign) NSInteger duration;
///> 广告: 名称
@property (nonatomic, copy) NSString *name;
///> 广告: 图片链接
@property (nonatomic, copy) NSString *image;
///> 广告: URD
@property (nonatomic, copy) NSString *url;
///> 广告: 超时时间
@property (nonatomic, assign) CGFloat end;
///> 是否在有效期内
@property (nonatomic, assign) BOOL isValid;
@end

@implementation DMAdModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"duration" : @"duration_time",
             @"end"   : @"end_at"
             };
}
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL isSuc = [super modelSetWithDictionary:dic];
    self.isValid = ([[NSDate date] timeIntervalSince1970] * 1000 - self.end) > 0;
    return isSuc;
}
@end

@interface OpenScreenViewTask : UIView
///> 
@property (nonatomic, strong) UIImageView *imageView;
///> 
@property (nonatomic, strong) UIButton *btn;
///>  
@property (nonatomic, strong) GTaskSource *tcs;
@end

@implementation OpenScreenViewTask

+ (instancetype)show {
    OpenScreenViewTask *task = [[OpenScreenViewTask alloc] init];
    [[UIApplication sharedApplication].keyWindow addSubview:task];
    return task;
}

#pragma mark - Init
///=============================================================================
/// @name Init
///=============================================================================

- (instancetype)initWithFrame:(CGRect)frame {
    CGRect f = {0, 0, SCREEN_WIDTH, SCREEN_HEIGHT + 1};
    if (self = [super initWithFrame:f]) {
        [self addView];
    }
    return self;
}

- (void)addView {
    [self addSubview:self.imageView];
}

#pragma mark - Function
///=============================================================================
/// @name Function
///=============================================================================

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)showOpenScreen:(UIImage *)image {
    self.imageView.image = image;
    [self addBtn];
}

- (void)addBtn {
    @weakify(self);
    [self.imageView addTapGesture:^(id x){
        @strongify(self);
        [self.tcs setResult:@(YES)];
        [self dismiss];
    }];
    [self addSubview:self.btn];
    [self countDown:3];
}

- (void)countDown:(NSInteger)count {
    if (count == 0) {
        [self.tcs setResult:[NSError errorWithDomain:@"" code:9999 userInfo:@{}] type:GTaskResultRejected];
        [self removeFromSuperview];
        return;
    }
    //self.btn.szTitle = Format(@"%lis后跳过", count);
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self countDown:(count-1)];
    });
}

#pragma mark - Get
///=============================================================================
/// @name Get
///=============================================================================

- (GTaskSource *)tcs {
    if (!_tcs) {
        _tcs = [GTaskSource source];
    }
    return _tcs;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _imageView;
}

- (UIButton *)btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        _btn.frame = CGRectMake(SCREEN_WIDTH-70, 22, 55, 22);
        _btn.titleLabel.font = [UIFont systemFontOfSize:13];
        _btn.layer.cornerRadius = 3.0f;
        _btn.layer.borderColor = HEX(@"ffffff", @"1c1c1e").CGColor;
        _btn.layer.borderWidth = .7;
        [_btn setTitle:@"跳过" forState:UIControlStateNormal];
        [_btn setTitleColor:HEX(@"ffffff", @"1c1c1e") forState:UIControlStateNormal];
        @weakify(self);
        [_btn addEvents:UIControlEventTouchUpInside action:^{
            @strongify(self);
            [self.tcs setResult:[NSError errorWithDomain:@"" code:9999 userInfo:@{}] type:GTaskResultRejected];
            [self dismiss];
        }];
    }
    return _btn;
}

@end

////////////////////////////////////////////////////////////////////////////////
/// @@class DMAdTask
////////////////////////////////////////////////////////////////////////////////

@implementation DMAdTask

+ (GTask *)task {
    OpenScreenViewTask *viewTask = [OpenScreenViewTask show];
    [self dataTask].then(^(RACTuple *t) {
        [viewTask showOpenScreen:t.second];
    }).catch(^(NSError *err) {
        [viewTask dismiss];
        [viewTask.tcs setResult:@NO];
    });
    return viewTask.tcs.task;
}

#pragma mark - AD Info Logical
///=============================================================================
/// @name 广告数据逻辑
///=============================================================================

+ (GTask *)dataTask {
    GTask *delay = ATAfter(1).then(^{ return [self error:@"1s内没有完成图片下载"]; });
    @weakify(self);
    return ATRace(@[delay, [self getADInfo]]).then(^id(HttpResult *t) {
        @strongify(self);
        if (t.code == 200) {
            GTaskSource *tcs = [GTaskSource source];
            [self loadImage:[DMAdModel modelWithJSON:t.data] tcs:tcs];
            return tcs.task;
        }
        return [self error:@"网络错误或者任务已超时"];
    });
}

+ (NSError *)error:(NSString *)str {
    return [NSError errorWithDomain:@"" code:999 userInfo:@{@"msg": str}];
}

+ (void)loadImage:(DMAdModel *)model tcs:(GTaskSource *)tcs {
    if (!model || !model.image || model.image.length == 0) {
        [tcs setResult:[self error:@"没有广告链接"]];
    }
    // 添加过期的逻辑
    NSURL *url = [NSURL URLWithString:model.image];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    id key = [manager cacheKeyForURL:url];
    [manager.imageCache queryImageForKey:key options:0 context:nil completion:^(UIImage *image, NSData *data, SDImageCacheType cacheType) {
        if (image) {
            [tcs setResult:RACTuplePack(model, image)];
            return;
        }
        [manager loadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (error) {
                [tcs setResult:[self error:@"没有广告链接"]];
            } else {
                [tcs setResult:RACTuplePack(model, image)];
            }
        }];
    }];
}

///> 从网络获取广告数据 
+ (GTask *)getADInfo {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"cityid"] = [GLocation location].smodel.cityID?:@"";
    params[@"size"]   = [self screenResolution];
    params[@"notificationState"] = [GPermission push] == AuthStatusAuthorized ? @"on":@"off";
    return [HttpRequest request].urlString(@"/api/v2/client/loading")
    .params(params).task;
}

+ (NSNumber *)screenResolution {
    CGFloat scale  = [UIScreen mainScreen].scale;
    NSInteger height = (NSInteger)[UIScreen mainScreen].bounds.size.height;
    switch (height) {
        case 896: { if (scale == 3) return @8; return @7; }
        case 812: return @6;
        case 736: return @5;
        case 667: return @4;
        case 568: return @3;
        case 480: { if (scale == 2) return @2; return @1; }
        case 2224: return @104;
        case 2732: return @103;
        case 2048: return @102;
        case 1024: return @101;
        default: return @100;
    }
}

@end


