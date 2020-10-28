//
//  GTextField.h
//  GUILib
//
//  Created by iOS_Developer_G on 2019/11/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTextField : UITextField
///> leftView x偏移距离
@property (nonatomic, assign) CGFloat lvx;
///> rightView x偏移距离
@property (nonatomic, assign) CGFloat rvx;
///> text x偏移距离
@property (nonatomic, assign) CGFloat tx;
@end

NS_ASSUME_NONNULL_END
