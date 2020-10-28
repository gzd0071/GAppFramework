//
//  DMAClientUI.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/16.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMAClientUI.h"
#import <DMUILib/DMPicker.h>
#import <DMUILib/DMAlertActions.h>
#import <GPermission/GPermission.h>
#import "DMUploadImage.h"
#import <DMUILib/DMPickerModel.h>
#import <GHttpRequest/HttpRequest.h>
#import <YYKit/NSString+YYAdd.h>
#import <DMUILib/GHud.h>

@interface DMACaptModel : NSObject<YYModel>
///>  
@property (nonatomic, copy) NSString *title;
///>  
@property (nonatomic, copy) NSString *mobile;
///>  
@property (nonatomic, copy) NSString *keboard;
///>  
@property (nonatomic, copy) NSString *type;
///>  
@property (nonatomic, strong) NSString *smsType;
@end

@implementation DMACaptModel
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    DMACaptModel *model = [super modelWithDictionary:dictionary];
    model.type = model.type ?: @"0";
    model.smsType = model.smsType ?: @"2";
    return model;
}
@end

////////////////////////////////////////////////////////////////////////////////
/// @@class DMBindPickerModel
////////////////////////////////////////////////////////////////////////////////
///> 所属行业模型 
@interface DMBindPickerModel : NSObject<DMPickerDataDelegate>
///> 标题
@property (nonatomic, strong) NSString *title;
///> 选择
@property (nonatomic, strong) NSArray<NSNumber *> *selected;
///> 数据
@property (nonatomic, strong) NSArray *data;
@end
@implementation DMBindPickerModel
- (NSString *)titleKeyWithComponent:(NSInteger)idx {
    return @"text";
}
- (NSArray<NSNumber *> *)pickerSelect {
    return self.selected;
}
- (NSString *)pickerTitle {
    return self.title;
}
- (NSInteger)numberOfComponents {
    return 2;
}
- (NSArray<id> *)dataWithSelect:(NSArray<NSNumber *> *)select {
    if (select.count == 0) return self.data;
    return self.data[select.firstObject.intValue][@"data"];
}
@end

////////////////////////////////////////////////////////////////////////////////
/// @@class DMBindPickerModel
////////////////////////////////////////////////////////////////////////////////
///> 
@interface DMDatePickerModel : NSObject<DMPickerDataDelegate>
///>  
@property (nonatomic, strong) NSString *title;
///>  
@property (nonatomic, strong) NSString *maxDate;
///>  
@property (nonatomic, strong) NSString *maxYear;
///>  
@property (nonatomic, strong) NSString *maxMonth;
///>  
@property (nonatomic, strong) NSString *minDate;
///>  
@property (nonatomic, strong) NSString *minYear;
///>  
@property (nonatomic, strong) NSString *minMonth;
///>  
@property (nonatomic, strong) NSString *defaultDate;
///>  
@property (nonatomic, strong) NSArray<NSNumber *> *select;
///>  
@property (nonatomic, strong) NSArray<NSString *> *data;
@end
@implementation DMDatePickerModel
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    BOOL suc = [super modelSetWithDictionary:dic];
    NSMutableArray *mut = @[].mutableCopy;
    [self.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSNumber.class]) {
            [mut addObject:[obj stringValue]];
        } else if ([obj isKindOfClass:NSString.class]) {
            [mut addObject:obj];
        }
    }];
    self.data = mut.copy;
    NSArray *maxA = [self.maxDate componentsSeparatedByString:@"-"];
    NSArray *minA = [self.minDate componentsSeparatedByString:@"-"];
    self.maxYear  = maxA.firstObject;
    self.maxMonth = maxA.lastObject;
    self.minYear  = minA.firstObject;
    self.minMonth = minA.lastObject;
    return suc;
}

- (NSInteger)numberOfComponents {
    return 2;
}
- (NSArray<NSNumber *> *)pickerSelect {
    NSArray *sep = [self.defaultDate componentsSeparatedByString:@"-"];
    NSInteger year  = [[self dataWithSelect:@[]] indexOfObject:sep.firstObject];
    year = year == NSNotFound ? 0 : year;
    NSInteger month = [[self dataWithSelect:@[@(year)]] indexOfObject:sep.lastObject];
    month = month == NSNotFound ? 0 : month;
    return @[@(year), @(month)];
}
- (NSString *)pickerTitle {
    return self.title;
}
- (NSString *)confirmTitle {
    return @"确定";
}
- (NSArray<id> *)dataWithSelect:(NSArray<NSNumber *> *)select {
    if (select.count == 0) return self.data;
    NSArray *arr = @[@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12"];
    NSInteger idx = [select[0] integerValue];
    NSString *value = self.data[idx];
    if ([value isEqualToString:self.maxYear]) {
        NSInteger num = self.maxMonth.intValue;
        return [arr subarrayWithRange:NSMakeRange(0, num)];
    } else if ([value isEqualToString:self.minYear]) {
        NSInteger num = self.minMonth.intValue;
        return [arr subarrayWithRange:NSMakeRange(num-1, arr.count-num+1)];
    } else if (![value numberValue] && value) {
        return @[value];
    }
    return arr;
}
@end


@implementation DMAClientUI

+ (GTask *)getCustomerServicePhoneNumbers:(NSDictionary *)args {
//    NSString *phone =  [DMDataEngine sharedInstance].userDao.service_phone ?: @"";
    return [GTask taskWithValue:@{@"service_phone": @""}];
}

+ (GTask *)showCaptcha2Dialog:(NSDictionary *)args {
    //TODO: 检查是否有网
    DMACaptModel *model = [DMACaptModel modelWithJSON:args];
    
    id params = @{@"mobile": model.mobile ?: @"",
                  @"type": model.type,
                  @"smsType": model.smsType
                  };
    [HttpRequest jsonRequest].urlString(@"/api/v2/client/authCkCode").params(params)
    .method(HttpMethodPost).task.then(^id(HttpResult *t) {
        if (t.code == 1000) {
            return [GTask taskWithValue:@{@"status":@"1"}];
        } else if (t.code == -3) {
            UIView *view = [UIView new];
            view.backgroundColor = HEX(@"333333");
            view.frame = CGRectMake(100, 100, 300, 300);
        } else {
            [GHud toast:t.message];
        }
        return nil;
    });
    return nil;
}

#pragma mark - ALERT
///=============================================================================
/// @name 弹框
///=============================================================================
///> 输入弹框 
+ (GTask *)showInputDialog:(NSDictionary *)args {
    ///> 待优化
    GTaskSource *tcs = [GTaskSource source];
    /// 输入Action
    DMAlertAction *input = [DMAlertActions inputAction];
    [DMAlert alert].title(@"请输入标签")
    .addActions(input)
    .show(nil);
    return tcs.task;
}
///> 拨打电话弹框 
+ (GTask *)showPhoneDialog:(NSDictionary *)args {
    GTaskSource *tcs = [GTaskSource source];
    if (@available(iOS 10.2, *)) {
        NSString *ps = FORMAT(@"telprompt://%@", [args[@"message"] length]?args[@"message"]:args[@"title"]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:ps]];
        });
        [tcs setResult:@{@"status":@"1"}];
    } else {
        /// 拨打电话Action
        DMAlertAction *phone = [DMAlertActions phoneAction:args[@"title"] block:^(DMAlertType type){
            [tcs setResult:@{@"status":@"1"}];
        }].title(args[@"okBtn"]);
        /// 取消Action
        DMAlertAction *cancel = [DMAlertActions cancelAction:args[@"cancelBtn"]]
        .handler(^(DMAlertAction *action){
            [tcs setResult:@{@"status":@"0"}];
        });
        [DMAlert alert].title(args[@"title"]).message(args[@"message"])
        .addAction([DMAlertActions headerAction:DMAlertHeaderTypePhone])
        .addActions(@[cancel, phone])
        .show(nil);
    }
    return tcs.task;
}
+ (GTask *)showContactDialog:(NSDictionary *)args {
    GTaskSource *tcs = [GTaskSource source];
    DMAlertAction *camora = [DMAlertAction action].title(args[@"buttonTitle_1"])
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{@"status": @"1"}];
    });;
    DMAlertAction *photo  = [DMAlertAction action].title(args[@"buttonTitle_2"])
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{@"status": @"2"}];
    });;
    DMAlertAction *cancel = [DMAlertActions cancelAction:@"取消"]
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{@"status":@"0"}];
    });
    [DMAlert alert].addActions(@[camora, photo, cancel]).type(DMAlertTypeSheet).show(nil);
    return tcs.task;
}

#pragma mark - IMAGE SELECTED
///=============================================================================
/// @name 图片选择器
///=============================================================================
///> 图片选择弹框 
+ (GTask *)selectAndUploadImage:(NSDictionary *)args {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [GPermission photo];
    if (status == AuthStatusDenied || status == AuthStatusRestricted) {
        [GHud toast:@"没有访问相册的权限"];
        return nil;
    }
    if (status == AuthStatusUnDetermined) {
        return [GPermission photoAuth].then(^id(GTask *t){
            return nil;
        });
    }
    DMAlertAction *camora = [DMAlertAction action].title(@"拍照")
    .handler(^(DMAlertAction *action){
        [tcs setResult:[self handlerUpload:UIImagePickerControllerSourceTypeCamera]];
    });
    DMAlertAction *photo  = [DMAlertAction action].title(@"从手机相册选择")
    .handler(^(DMAlertAction *action) {
        [tcs setResult:[self handlerUpload:UIImagePickerControllerSourceTypePhotoLibrary]];
    });
    DMAlertAction *cancel = [DMAlertActions cancelAction:@"取消"]
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{}];
    });
    [DMAlert alert].addActions(@[camora, photo, cancel]).type(DMAlertTypeSheet).show(nil);
    return tcs.task;
}
+ (GTask *)handlerUpload:(UIImagePickerControllerSourceType)type {
    return [DMUploadImage uploadImage:type]
    .then(^id(NSDictionary *t) {
        if ([t[@"status"] integerValue] == 1) {
            NSMutableDictionary *mut = [NSMutableDictionary dictionaryWithDictionary:t];
            NSString *name = FORMAT(@"%li", (long)[NSDate timeIntervalSinceReferenceDate]);
            mut[@"imgPath"] = [NSHomeDirectory() stringByAppendingString:FORMAT(@"Document/tmpImgDirectory/tempImg%@.png", name)];
            return mut.copy;
        }
        return t;
    });
}

#pragma mark - Picker
///=============================================================================
/// @name 滚轮选择器
///=============================================================================
///> 滚轮选择 
+ (GTask *)showPicker:(NSDictionary *)args {
    DMPickerModel *model = [DMPickerModel modelWithJSON:args];
    return [self showPickerTask:[DMPicker show:model]];
}
///> 所属行业选择 
+ (GTask *)showBindPicker:(NSDictionary *)args {
    DMBindPickerModel *model = [DMBindPickerModel modelWithJSON:args];
    return [DMPicker show:model type:PickerTypeLinkage]
    .then(^id(GTaskResult<NSArray *> *t) {
        if (!t.suc) return @{@"status":@"0"};
        NSMutableDictionary *mut = @{@"status":@"1"}.mutableCopy;
        mut[@"selected"] = t.data;
        return mut.copy;
    });
}
///> 区间滚轮选择器 
+ (GTask *)showSalaryPick:(NSDictionary *)args {
    DMPickerModel *model = [DMPickerModel modelWithJSON:args];
    return [self showPickerTask:[DMPicker show:model type:PickerTypeSection]];
}
///> 日期滚轮选择器 
+ (GTask *)showDatePicker:(NSDictionary *)args {
    DMDatePickerModel *model = [DMDatePickerModel modelWithJSON:args];
    return [DMPicker show:model type:PickerTypeLinkage]
    .then(^id(GTaskResult<NSArray *> *t) {
        if (!t.suc) return @{@"status":@"0"};
        NSMutableDictionary *mut = @{@"status":@"1"}.mutableCopy;
        NSMutableArray *temp = @[].mutableCopy;
        [t.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *sel = @{}.mutableCopy;
            NSArray *arr = [model dataWithSelect:[t.data subarrayWithRange:NSMakeRange(0, idx)]];
            sel[@"name"] = arr[[obj integerValue]];
            sel[@"id"] = obj;
            [temp addObject:sel];
        }];
        mut[@"selected"] = temp.copy;
        return mut.copy;
    });
}
+ (GTask *)showPickerTask:(GTask *)task {
    return task.then(^id(GTaskResult<NSArray *> *t) {
        if (!t.suc) return @{@"status":@"0"};
        NSArray *result = t.data;
        NSMutableDictionary *mut = @{@"status":@"1"}.mutableCopy;
        [result enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            mut[FORMAT(@"data%ld",(long)idx+1)] = obj;
        }];
        return mut.copy;
    });
}

#pragma mark - 弹框
///=============================================================================
/// @name Alert
///=============================================================================

///> 显示弹框 
+ (GTask *)showDialog:(NSDictionary *)args {
    GTaskSource *tcs = [GTaskSource source];
    DMAlertAction *cancel  = [DMAlertActions cancelAction:args[@"cancelBtn"]]
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{@"status":@"0"}];
    });
    DMAlertAction *confirm = [DMAlertAction action].title(args[@"okBtn"])
    .handler(^(DMAlertAction *action){
        [tcs setResult:@{@"status":@"1"}];
    });
    id title   = [self handleAttr:args[@"titleAttribute"] string:args[@"title"]];
    id message = [self handleAttr:args[@"messageAttribute"] string:args[@"message"]];
    [DMAlert alert].title(title).message(message)
    .addAction([DMAlertActions headerActionWithTypeName:args[@"imageName"]])
    .addActions(@[cancel, confirm]).show(nil);
    return tcs.task;
}

+ (id)handleAttr:(NSString *)attrS string:(NSString *)string {
    if (!attrS || ![attrS isKindOfClass:NSArray.class]) return string;
    return string;
}


@end
