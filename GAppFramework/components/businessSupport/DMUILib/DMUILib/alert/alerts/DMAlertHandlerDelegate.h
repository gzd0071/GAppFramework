//
//  DMAlertHandlerDelegate.h
//  DMUILib
//
//  Created by iOS_Developer_G on 2019/9/26.
//

#import <Foundation/Foundation.h>
#import "DMAlert.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DMAlertHandlerDelegate <NSObject>
+ (instancetype)show:(DMAlert *)alert vc:(UIViewController *)vc;
- (void)dismiss:(BOOL)animate complete:(void(^)(void))block;
@end

NS_ASSUME_NONNULL_END
