//
//  DMDNetHistoryViewController.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/30.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebuggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * 请求:
 * TODO:
 *   1.请求复制
 *   2.能记录UI修改操作, 提示修改
 */
@interface DMDNetHistoryViewController : UIViewController<DebuggerPluginDelegate>

@end

NS_ASSUME_NONNULL_END
