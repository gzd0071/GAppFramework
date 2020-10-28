//
//  DMPicker.h
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/23.
//

#import <UIKit/UIKit.h>
#import <GBaseLib/GConvenient.h>

NS_ASSUME_NONNULL_BEGIN

///> 请求: 方法类型 
typedef NS_ENUM(NSInteger, PickerType) {
    ///> 默认
    PickerTypeDefault = 0,
    ///> 区间
    PickerTypeSection,
    ///> 联动数据
    PickerTypeLinkage
};

@protocol DMPickerRowDelegate <NSObject>
- (NSString *)rowTitle;
@end

@protocol DMPickerModelDelegate <NSObject>
///> 数据: 弹框标题 
- (NSString *)pickerTitle;
@optional
///> 数据: 选择数据 
- (NSArray<NSArray<id> *> *)pickerData;
///> 数据: 当前选择项 
- (NSArray<NSNumber *> *)pickerSelect;
///> 数据: 当前选择项 
- (NSString *)titleKeyWithComponent:(NSInteger)idx;
///> 数据: 确认按钮标题 
- (NSString *)confirmTitle;
@end

@protocol DMPickerDataDelegate <DMPickerModelDelegate>
///> 数据: 个数 
- (NSInteger)numberOfComponents;
///> 数据: 通过选择项获取数据 
- (NSArray<id> *)dataWithSelect:(NSArray<NSNumber *> *)select;
@end

@interface DMPicker<__covariant T> : UIView
///> 
+ (GTask<GTaskResult<T> *> *)show:(id<DMPickerModelDelegate>)model;
+ (GTask<GTaskResult<T> *> *)show:(id<DMPickerModelDelegate>)model type:(PickerType)type;
@end

NS_ASSUME_NONNULL_END
