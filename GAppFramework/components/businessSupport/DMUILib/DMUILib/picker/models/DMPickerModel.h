//
//  DMPickerModel.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/10/21.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMPicker.h"
#import <YYKit/NSObject+YYModel.h>

NS_ASSUME_NONNULL_BEGIN

///> 
@interface DMPickerModel : NSObject<DMPickerModelDelegate>
///> 弹框: 标题
@property (nonatomic, strong) NSString *title;
///> 弹框: 当前选择项
@property (nonatomic, strong) NSArray<NSNumber *> *select;
///> 弹框: 数据
@property (nonatomic, strong) NSDictionary *data;
///> 弹框: 取数据key
@property (nonatomic, strong) NSString *key;
@end


@interface DMCityPickerModel : NSObject<DMPickerDataDelegate>
///>
@property (nonatomic, assign) BOOL showDefault;
///> 弹框: 标题
@property (nonatomic, strong) NSString *title;
///> 弹框: 当前选择项(以-分隔)
@property (nonatomic, strong) NSString *select;
///> 弹框: 城市等级
@property (nonatomic, assign) NSInteger level;
///> 弹框: 城市数据
@property (nonatomic, strong) NSArray *provinces;
@end

NS_ASSUME_NONNULL_END
