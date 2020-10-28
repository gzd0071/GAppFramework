//
//  DMHDropDelegate.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GBaseLib/GConvenient.h>

NS_ASSUME_NONNULL_BEGIN

#define kMENUHEIGHT 393 //(IS_IPHONE_5 ? 393 : IS_IPHONE_4_OR_LESS ? 355 : 485)

@protocol DMHDropDelegate <NSObject>
@required;
- (void)dismiss:(BOOL)animated com:(nullable void(^)(BOOL finish))comp;
- (NSString *)dropType;
@optional
+ (id)show:(nullable id)model block:(AActionBlock)block;
+ (id)show:(nullable id)model block:(AActionBlock)block view:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
