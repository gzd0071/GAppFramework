//
//  DMEmpty.h
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/18.
//

#import <UIKit/UIKit.h>
#import <GProtocol/ViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

///> 动画类型 
typedef NS_ENUM(NSInteger, DMEmptyType) {
    ///> 无数据
    DMEmptyTypeNoData  = 0,
    ///> 无网络
    DMEmptyTypeNetwork,
    ///> 无结果
    DMEmptyTypeNoFound,
    ///> 无服务
    DMEmptyTypeServerError,
    ///> 无数据含重试按钮
    DMEmptyTypeNoDataWithButton,
    ///> 无网络含重试按钮
    DMEmptyTypeNetworkWithButton,
    ///> 无数据含重试按钮
    DMEmptyTypeNoFoundWithButton,
    ///> 无服务含重试按钮
    DMEmptyTypeServerErrorWithButton,
    ///> 自定制
    DMEmptyTypeCustom
};

@protocol DMEmptyDataSource <NSObject>
@optional
///> 空页: 按钮文案 NSString or NSAttributeString 
- (NSAttributedString *)emptyButtonTxt:(UIControlState)state;
///> 空页: 按钮背景 
- (UIImage *)emptyButtonBackgroundImage:(UIControlState)state;
///> 空页: 按钮 
- (CGFloat)emptyButtonCornerRadius;
///> 空页: 提示文案 NSString or NSAttributeString 
- (NSAttributedString *)emptyTxt;
///> 空页: 图案 
- (UIImage *)emptyImage;
///> 空页: 背景色 
- (UIColor *)emptyBackgroundColor;
///> 空页: 空格 
- (CGFloat)emptyButtonSpace;
@end

/*!
 * 定制: 空白页
 */
@interface DMEmpty : UIView<ViewDelegate>
@end

@interface UIView (DMEmpty)
- (DMEmpty *)showEmpty:(DMEmptyType)type;
- (DMEmpty *)showEmpty:(DMEmptyType)type msg:(nullable NSString *)msg;
- (DMEmpty *)showEmpty:(DMEmptyType)type action:(nullable AActionBlock)action;
- (DMEmpty *)showEmpty:(DMEmptyType)type msg:(nullable NSString *)msg action:(nullable AActionBlock)action;
- (DMEmpty *)showEmptySouce:(id<DMEmptyDataSource>)model;
- (DMEmpty *)showEmptySouce:(id<DMEmptyDataSource>)model action:(nullable AActionBlock)action;
@end

NS_ASSUME_NONNULL_END
