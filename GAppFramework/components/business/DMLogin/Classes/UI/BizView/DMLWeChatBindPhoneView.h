//
//  DMWechatBindPhoneView.h
//  c_doumi
//
//  Created by ltl on 2019/4/13.
//  Copyright © 2019 doumijianzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMLWeChatBindPhoneView : UIView
@property (nonatomic, strong)  UIView *topView;
@property (nonatomic, strong)  UIButton *backBtn;

@property (nonatomic, strong)  UITextField *phoneTF;
@property (nonatomic, strong)  UITextField *verificationTF;
@property (nonatomic, strong)  UILabel *subTitleLabel;
@property (nonatomic, strong)  UIView *firstLineView;
@property (nonatomic, strong)  UIView *secondLineView;
@property (nonatomic, strong)  UIButton *verificationBtn;
@property (nonatomic, strong)  UILabel *cannotGetVerificationLabel;

/*
 * 确定按钮
 */
@property (nonatomic, strong)  UIButton *positiveBtn;

- (void)resignTxtField;

@end

NS_ASSUME_NONNULL_END
