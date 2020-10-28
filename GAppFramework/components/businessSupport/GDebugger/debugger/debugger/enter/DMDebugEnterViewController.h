//
//  DMDebugEnterViewController.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/29.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GProtocol/ViewProtocol.h>
#import "DebuggerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 * 入口页面
 */
@interface DMDebugEnterViewController : UIViewController<GSViewDelegate>
///> 
@property (nonatomic, strong) NSMutableDictionary<id, NSMutableArray<Class<DebuggerPluginDelegate>> *> *plugins;
@end

NS_ASSUME_NONNULL_END
