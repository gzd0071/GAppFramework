//
//  DMNewLoginMiddleView.h
//  c_doumi
//
//  Created by ltl on 2019/3/18.
//  Copyright © 2019 doumijianzhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMLSMSValidationVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface DMLLoginMiddleView : UIView <DMLSMSDelegate, UITextFieldDelegate>
@property (nonatomic, strong)  UITextField *phoneTF;
@property (nonatomic, strong)  UIView *lineView;
@property (nonatomic, strong)  UIButton *verificationBtn;
@property (nonatomic, strong)  UIButton *bottomView;
@property (nonatomic, strong)  UIButton *getVerificationBtn;
@property (nonatomic, strong)  UIButton *agreementBtn;
@property (nonatomic, copy) void(^verificationBtnBlock)(void);

- (void)checkVerifyButtonState;

@end

NS_ASSUME_NONNULL_END
