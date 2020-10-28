//
//  DMHCity.h
//  c_doumi
//
//  Created by iOS_Developer_G on 2019/6/21.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMHDropDelegate.h"
#import <GProtocol/ViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

///> 下拉菜单: 城市选择 
@interface DMHCity : UIView<DMHDropDelegate, ViewDelegate>
+ (void)loadCityData:(NSString *)cityID;
- (void)dismiss:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
