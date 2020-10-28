//
//  DMHCityModel.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/NSObject+YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMHCityModel : NSObject<YYModel>
///> 城市ID 
@property (nonatomic, strong) NSString *id;
///>  
@property (nonatomic, strong) NSString *parent_id;
///> 名称 
@property (nonatomic, strong) NSString *name;
///> 定位 
@property (nonatomic, strong) NSString *location;
///> 区域 
@property (nonatomic, strong) NSArray<DMHCityModel *> *streets;
///> 经度 
@property (nonatomic, strong) NSString *lat;
///> 纬度 
@property (nonatomic, strong) NSString *lng;
///>  
@property (nonatomic, assign) BOOL select;
@end

NS_ASSUME_NONNULL_END
