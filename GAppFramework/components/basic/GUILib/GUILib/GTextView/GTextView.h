//
//  GTextView.h
//  GUILib
//
//  Created by iOS_Developer_G on 2019/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GTextView : UITextView
///> 占位文字:
@property (nonatomic, strong) NSString *holder;
///> 占位文字
@property (nonatomic, strong) NSAttributedString *attributeHolder;
///> 占位文字: 字体
@property (nonatomic, strong) UIFont *holderFont;
///> 占位文字: 颜色
@property (nonatomic, strong) UIColor *holderColor;
@end

NS_ASSUME_NONNULL_END
