//
//  DMPicker.m
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/23.
//

#import "DMPicker.h"
#import <GBaseLib/GConvenient.h>
#import <GUILib/GShow.h>

#define kPICKER_HEADER_HEIGHT 45.f
#define kPICKER_BUTTON_WIDTH  50.f
#define kPICKER_PICKER_HEIGHT 220.f

@interface DMPicker ()<UIPickerViewDelegate, UIPickerViewDataSource, GShowActionDelegate>
///> 
@property (nonatomic, strong) GShow *show;
///> 
@property (nonatomic, strong) AActionBlock action;
///> 
@property (nonatomic, strong) GTaskSource *tcs;
///>  
@property (nonatomic, strong) id<DMPickerDataDelegate> model;

///> 文案: 标题 
@property (nonatomic, strong) UILabel *title;
///> 按钮: 取消 
@property (nonatomic, strong) UILabel *cancel;
///> 按钮: 确认 
@property (nonatomic, strong) UILabel *confirm;
///> 视图: 分割线 
@property (nonatomic, strong) UIView *line;
///> 视图: 选择器 
@property (nonatomic, strong) UIPickerView *picker;

///> 选中 
@property (nonatomic, strong) NSMutableArray *data;
///> 数据: 显示数据 
@property (nonatomic, strong) NSArray<NSArray<id> *> *list;
///> 类型 
@property (nonatomic, assign) PickerType type;
@end

@implementation DMPicker

+ (GTask<GTaskResult<id> *> *)show:(id<DMPickerModelDelegate>)model {
    return [self show:model type:PickerTypeDefault block:^{}];
}

+ (GTask<GTaskResult<id> *> *)show:(id<DMPickerModelDelegate>)model type:(PickerType)type {
    return [self show:model type:type block:^{}];
}

+ (GTask *)show:(id)model type:(PickerType)type block:(AActionBlock)block {
    DMPicker *sub = [self viewWithFrame:CGRectZero model:model type:type action:block];
    sub.show = [GShow show:sub];
    return sub.tcs.task;
}

#pragma mark - GShowActionDelegate
///=============================================================================
/// @name GShowActionDelegate
///=============================================================================

- (void)backTapAction {
    [self.show dismiss:YES];
    [self.tcs setResult:GTaskResult(NO)];
}

#pragma mark - ViewDelegate
///=============================================================================
/// @name ViewDelegate
///=============================================================================

+ (id)viewWithFrame:(CGRect)frame model:(id)model type:(PickerType)type action:(AActionBlock)action {
    return [[self alloc] initWithFrame:frame model:model type:type action:action];
}

- (instancetype)initWithFrame:(CGRect)frame model:(id)model type:(PickerType)type action:(AActionBlock)action {
    CGFloat height = kPICKER_HEADER_HEIGHT+kPICKER_PICKER_HEIGHT+HALFPixal;
    CGRect rect = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, height);
    if (self = [super initWithFrame:rect]) {
        _action = action;
        _model  = model;
        _type   = type;
        _tcs    = [GTaskSource source];
        [self initList];

        self.backgroundColor = HEX(@"ffffff", @"1c1c1e");
        [self addViews:nil];
    }
    return self;
}

#pragma mark - 类型兼容
///=============================================================================
/// @name 类型兼容
///=============================================================================

- (void)initList {
    if (self.type == PickerTypeLinkage) {
        _data = [NSMutableArray arrayWithCapacity:[self.model numberOfComponents]];
        return;
    }
    NSArray<NSArray<id> *> *data = [_model pickerData];
    if (data.count == 0) return;
    if (self.type == PickerTypeSection) {
        NSMutableArray *mut = data[0].mutableCopy;
        NSMutableArray *arr = @[].mutableCopy;
        [arr addObject:[mut subarrayWithRange:NSMakeRange(0, mut.count-1)]];
        [arr addObject:[mut subarrayWithRange:NSMakeRange(1, mut.count-1)]];
        self.list = arr.copy;
    } else {
       self.list = data;
    }
    _data = [NSMutableArray arrayWithCapacity:self.list.count];
}

- (void)initSelect {
    NSInteger count = self.type == PickerTypeLinkage ? [self.model numberOfComponents] : self.list.count;
    for (NSInteger i=0; i<count; i++) {
        self.data[i] = (self.type == PickerTypeSection) ? @(i) : @0;
    }
    if (![self.model respondsToSelector:@selector(pickerSelect)]) return;
    NSArray<NSNumber *> *select = self.model.pickerSelect;
    if (!select) return;
    @weakify(self);
    [select enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        if (idx >= count) { *stop = YES;  return; }
        NSInteger i = 0;
        NSInteger objI = obj.integerValue;
        if (self.type == PickerTypeLinkage) {
            i = objI;
            self.data[idx] = obj;
            [self.picker selectRow:i inComponent:idx animated:NO];
        } else {
            NSInteger i = (objI < self.list[idx].count) ? objI : self.list[idx].count - 1;
            if (i < 0) return;
            self.data[idx] = @(i);
            if (self.type == PickerTypeSection && idx == 1 && objI < self.list[idx].count) {
                i = i - 1;
            }
            [self.picker selectRow:i inComponent:idx animated:YES];
        }
    }];
}

#pragma mark - PickerDelegate
///=============================================================================
/// @name PickerDelegate
///=============================================================================

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *arr = (self.type == PickerTypeLinkage) ? [self.model dataWithSelect:[self.data subarrayWithRange:NSMakeRange(0, component)]] : self.list[component];
    if (row >= arr.count) return @"";
    id str = arr[row];
    if ([str respondsToSelector:@selector(rowTitle)]) {
        return [str rowTitle];
    } else if ([str isKindOfClass:NSDictionary.class] && [_model respondsToSelector:@selector(titleKeyWithComponent:)]) {
        id key = [_model titleKeyWithComponent:component];
        return str[key];
    } else if ([str isKindOfClass:NSNumber.class]) {
        return [str stringValue];
    }
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.type == PickerTypeSection) {
        NSArray *ori = [self.model pickerData][0];
        if (component == 0) {
            self.data[0] = @([ori indexOfObject:self.list[0][row]]);
            NSInteger cs = [self.picker selectedRowInComponent:1];
            if (cs >= row) return;
            [self.picker selectRow:row inComponent:1 animated:YES];
            self.data[1] = @([ori indexOfObject:self.list[1][row]]);
        } else {
            NSInteger cf   = [self.picker selectedRowInComponent:0];
            NSInteger trow = row >= cf ? row : cf;
            if (row < cf) [self.picker selectRow:cf inComponent:1 animated:YES];
            self.data[1] = @([ori indexOfObject:self.list[1][trow]]);
        }
    } else if (self.type == PickerTypeLinkage) {
        self.data[component] = @(row);
        for (NSInteger i=component+1; i<[self.model numberOfComponents]; i++) {
            [self.picker reloadComponent:i];
            self.data[i] = @([self.picker selectedRowInComponent:i]);
        }
    } else {
        self.data[component] = @(row);
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.type == PickerTypeLinkage) return [self.model numberOfComponents];
    return self.list.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.type == PickerTypeLinkage) {
        NSArray *arr = [self.model dataWithSelect:[self.data subarrayWithRange:NSMakeRange(0, component)]];
        return arr.count;
    }
    return self.list[component].count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30.f;
}

#pragma mark - View
///=============================================================================
/// @name View
///=============================================================================

- (void)addViews:(UIView *)header {
    if (header) {
        [self addSubview:header];
    } else {
        [self addSubview:self.header];
        [self addSubview:self.title];
        [self addSubview:self.cancel];
        [self addSubview:self.confirm];
        [self addSubview:self.line];
    }
    [self addSubview:self.picker];
    [self initSelect];
}

- (UIView *)header {
    UIView *view = [UIView new];
    view.backgroundColor = HEX(@"F5F5F5", @"262628");
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, kPICKER_HEADER_HEIGHT);
    return view;
}

- (UIView *)line {
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = HEX(@"E8E5DE", @"3d3d41");
        _line.frame = CGRectMake(0, kPICKER_HEADER_HEIGHT, SCREEN_WIDTH, HALFPixal);
    }
    return _line;
}

- (UILabel *)title {
    if (!_title) {
        _title = [UILabel new];
        CGFloat p = kPICKER_BUTTON_WIDTH+16;
        _title.frame = CGRectMake(p, 0, SCREEN_WIDTH-2*p, kPICKER_HEADER_HEIGHT);
        _title.font = FONT(16);
        _title.textAlignment = NSTextAlignmentCenter;
        _title.textColor = HEX(@"181119", @"dddddd");
        _title.text = [self.model pickerTitle];
    }
    return _title;
}

- (UILabel *)cancel {
    if (!_cancel) {
        _cancel = [UILabel new];
        _cancel.frame = CGRectMake(0, 0, kPICKER_BUTTON_WIDTH, kPICKER_HEADER_HEIGHT);
        _cancel.text = @"取消";
        _cancel.font = FONT(14);
        _cancel.textAlignment = NSTextAlignmentCenter;
        _cancel.textColor = HEX(@"414141", @"d1d1d1");
        @weakify(self);
        [_cancel addTapGesture:^{
            @strongify(self);
            [self backTapAction];
        }];
    }
    return _cancel;
}

- (UILabel *)confirm {
    if (!_confirm) {
        _confirm = [UILabel new];
        _confirm.frame = CGRectMake(SCREEN_WIDTH-kPICKER_BUTTON_WIDTH, 0, kPICKER_BUTTON_WIDTH, kPICKER_HEADER_HEIGHT);
        if ([self.model respondsToSelector:@selector(confirmTitle)]) {
            _confirm.text = [self.model confirmTitle];
        } else {
            _confirm.text = @"完成";
        }
        _confirm.font = FONT(14);
        _confirm.textAlignment = NSTextAlignmentCenter;
        _confirm.textColor = HEX(@"414141", @"d1d1d1");
        @weakify(self);
        [_confirm addTapGesture:^{
            @strongify(self);
            [self.show dismiss:YES];
            [self.tcs setResult:GTaskResult(YES, self.data)];
        }];
    }
    return _confirm;
}

- (UIPickerView *)picker {
    if (!_picker) {
        _picker = [UIPickerView new];
        _picker.frame = CGRectMake(0, kPICKER_HEADER_HEIGHT+HALFPixal, SCREEN_WIDTH, kPICKER_PICKER_HEIGHT);
        _picker.delegate   = self;
        _picker.dataSource = self;
    }
    return _picker;
}

@end

