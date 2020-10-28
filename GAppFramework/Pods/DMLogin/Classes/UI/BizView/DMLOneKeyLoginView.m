//
//  DMNewLoginOneKeyLoginView.m
//  c_doumi
//
//  Created by ltl on 2019/3/20.
//  Copyright © 2019 GAppFramework. All rights reserved.
//

static  NSString *const kLoginBtnTitle = @"本机号码一键登录";


#import "DMLOneKeyLoginView.h"
#import "UIView+LoginUIViewPosition.h"
//#import <TYRZSDK/TYRZSDK.h>

@implementation DMLOneKeyLoginView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self addViews];
    }
    return self;
}

- (void )addViews {
    
    [self addOneKeyLoginBtn];
    [self addOtherPhoneLogin];
    [self addAgreementView];
}

- (void)addOneKeyLoginBtn {
    
    UIButton *btn = [[UIButton alloc] init];
    btn.enabled = YES;
    //TODO: ；颜色替换
    UIColor *color = [UIColor colorWithRed:(255)/255.0 green:(204)/255.0 blue:(0)/255.0 alpha:1.0];//DMColorHexFFCC00
    [btn setTitleColor:color forState:UIControlStateNormal];
    btn.backgroundColor = color;
    btn.layer.shadowColor = color.CGColor;
    btn.layer.shadowOffset = CGSizeMake(0, 2);
    btn.layer.shadowRadius = 14.f;
    btn.layer.shadowOpacity = 0.4f;
    btn.layer.cornerRadius = 4.f;
    
    [btn setTitleColor:[UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    self.oneKeyLoginBtn = btn;
    [self addSubview:btn];
    [btn setTitle:kLoginBtnTitle forState:UIControlStateNormal];
    btn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    
    
    btn.DL_left = self.DL_bounds_left;
    btn.DL_top = self.DL_bounds_top;
    btn.DL_width = self.DL_width;
    btn.DL_height = 44;
    //TODO: ；约束设置
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.mas_centerX);
//        make.top.equalTo(self.mas_top).offset(0);
//        make.left.equalTo(self.mas_left).offset(0);
//        make.right.equalTo(self.mas_right).offset(0);
//        make.height.equalTo(@44);
//    }];
    
    
//    TL_RAC_BUTTON(btn, [self clickOneKeyLoginBtn]);
    
};

//- (void)clickOneKeyLoginBtn{
//    [TYRZUILogin getTokenExpWithController:self.superview complete:^(id sender) {
//        complete(sender);
//    }];
//};

- (void)addOtherPhoneLogin {

    UIButton *btn = [[UIButton alloc] init];
    self.otherPhoneLogin = btn;
    btn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [btn setTitle:@"使用其他手机号" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [self addSubview:btn];
    
    //TODO: 约束设置
    btn.DL_size = CGSizeMake(84, 17);
    btn.DL_top = self.oneKeyLoginBtn.DL_bottom + 24;
    btn.DL_right = self.DL_bounds_right;
};

- (void)addAgreementView {
    NSString *string = @"注册登录即表示同意《用户注册与隐私保护服务协议》";
    NSDictionary *attrs = @{NSFontAttributeName :[UIFont fontWithName:@"PingFangSC-Regular" size:12]};
    CGSize contentSize = [string boundingRectWithSize:CGSizeMake(108 + 180, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"注册登录即表示同意";
    label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    [self addSubview:label];
    
    //TODO: 约束设置
    label.DL_top = self.oneKeyLoginBtn.DL_bottom + 65;
    label.DL_left = self.DL_bounds_left + (([UIScreen mainScreen].bounds.size.width - 80 - contentSize.width) * 0.5);
    label.DL_size = CGSizeMake(108, 17);
    

    UIButton *btn = [[UIButton alloc] init];
    self.agreementBtn = btn;
    btn.titleLabel.font =  [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    [btn setTitle:@"《用户注册与隐私保护服务协议》"forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:69/255.0 green:109/255.0 blue:180/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [self addSubview:btn];
    
    //TODO: 约束设置
    btn.DL_top = self.oneKeyLoginBtn.DL_bottom + 65;
    btn.DL_left = label.DL_right;
    btn.DL_size = CGSizeMake(180, 17);
    
    
    UILabel *uniteLabel = [[UILabel alloc] init];
    uniteLabel.text = @"和中国移动和通行证联合授权登录";
    uniteLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
    uniteLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
    [self addSubview:uniteLabel];
    
    //TODO: 约束设置
    uniteLabel.DL_top = self.oneKeyLoginBtn.DL_bottom + 85;
    uniteLabel.DL_size = CGSizeMake(self.DL_width, 17);
    uniteLabel.center = CGPointMake(self.center.x, uniteLabel.center.y);
    
};


@end
