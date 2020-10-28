//
//  AQRCode.h
//  Debugger
//
//  Created by iOS_Developer_G on 2019/11/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class GTask<__covariant ResultType>;

@interface AQRCode<__covariant ResultType> : NSObject
+ (GTask<NSArray *> *)qrcode;
@end

NS_ASSUME_NONNULL_END
