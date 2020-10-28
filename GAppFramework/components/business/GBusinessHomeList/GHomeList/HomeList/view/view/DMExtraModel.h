//
//  DMExtraModel.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/8/20.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYKit/NSObject+YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMCityInfoModel : NSObject<YYModel>
///> 城市: 简写 
@property (nonatomic, strong) NSString *domain;
///> 城市: 全拼 
@property (nonatomic, strong) NSString *pinyin;
///> 城市: ID 
@property (nonatomic, strong) NSString *id;
///> 城市: 名称 
@property (nonatomic, strong) NSString *name;
///> 城市: 父ID 
@property (nonatomic, strong) NSString *parentID;
///> 城市: 请求ID 
@property (nonatomic, strong) NSString *reqid;
@end

@interface DMExtraModel : NSObject<YYModel>
///>  
@property (nonatomic, strong) DMCityInfoModel *cityInfo;
///>  
@property (nonatomic, strong) NSString *token;
@end

NS_ASSUME_NONNULL_END
