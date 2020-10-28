//
//  DMDLogViewController.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/8/12.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DebuggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * [] 1.可以查看日志文件log
 * [] 2.可以在网页查看日志log
 */
@interface DMDLogViewController : UIViewController<DebuggerPluginDelegate>

@end

NS_ASSUME_NONNULL_END
