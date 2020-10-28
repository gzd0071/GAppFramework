//
//  DMLVerifyCodeInputLabel.h
//  DMLVerifyCodeInputLabel
//
//  Created by tangjin on 2018/11/21.
//  Copyright © 2018年 tangjin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMLVerifyCodeInputLabel : UILabel
/**验证码/密码的位数*/
@property (nonatomic,assign)NSInteger numberOfVertificationCode;
/**控制验证码/密码是否密文显示*/
@property (nonatomic,assign)bool secureTextEntry;  
@end
