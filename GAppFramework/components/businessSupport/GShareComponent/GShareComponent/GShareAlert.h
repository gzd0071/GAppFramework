//
//  GShareAlert.h
//  GShareComponent
//
//  Created by iOS_Developer_G on 2019/11/30.
//

#import <UIKit/UIKit.h>
#import "GShareComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GShareAlert : UIView
/// 分享弹框
/// @param scene 分享的场景
+ (GTask *)alert:(GShareScene)scene;
@end

NS_ASSUME_NONNULL_END
