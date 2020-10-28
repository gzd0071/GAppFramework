//
//  DMDSanboxViewController.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/5/6.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GRouter/GRouter.h>
#import "DebuggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMDSanboxViewController : UIViewController<GRouterTaskDelegate, DebuggerPluginDelegate>

@end

NS_ASSUME_NONNULL_END
