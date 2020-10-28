//
//  DMHNavBar.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/6/14.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GProtocol/ViewProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMHNavBar : UIView<ViewDelegate>
- (void)changeHot;
@end

NS_ASSUME_NONNULL_END
