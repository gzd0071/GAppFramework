//
//  HttpResult.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/7/16.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * HttpResultKey NS_TYPED_EXTENSIBLE_ENUM;

UIKIT_EXTERN HttpResultKey const HttpResultKeyCode;
UIKIT_EXTERN HttpResultKey const HttpResultKeyMessage;
UIKIT_EXTERN HttpResultKey const HttpResultKeyData;

@interface HttpResult<T, E> : NSObject
///> 请求结果: 错误码 
@property (nonatomic, assign) NSInteger code;
///> 请求结果: 错误描述 
@property (nonatomic, strong) NSString *message;
///> 请求结果: 数据 
@property (nonatomic, strong) T data;
///> 请求结果: 额外数据 
@property (nonatomic, strong) E extra;
///> 请求结果: 额外数据 
@property (nonatomic, strong) id originData;
///> 请求成功:  
@property (nonatomic, assign) BOOL suc;
///> 请求结果: 错误 
@property (nonatomic, strong) NSDictionary *userInfo;
@end

NS_ASSUME_NONNULL_END
