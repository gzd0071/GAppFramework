//
//  DMLoginAlertController.h
//  test
//
//  Created by JasonLin on 3/23/16.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DMDialogControllerStyle) {
    DMDialogControllerStyleCenter = 0,
    DMDialogControllerStyleBottom,
};

@class DMLoginBaseAlertView;

@interface DMLoginBaseAlertController : UIViewController 
@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UIView *dismissView;
@property (nonatomic, strong) NSString * titleStr;
@property (nonatomic, strong) NSString * subtitleStr;
@property (nonatomic, strong) NSString * confirmStr;
@property (nonatomic, strong) NSString * cancelStr;
@property (nonatomic, assign) DMDialogControllerStyle preferredStyle;
@property (nonatomic, strong) void (^confirmBlock)(id);
@property (nonatomic, strong) void (^cancelBlock)(void);

- (void)customInitWithTitle:(NSString *)aTitle subtitle:(NSString *)aSubTitle confirmStr:(NSString *)aConfirm cancelStr:(NSString *)aCancel confirmBlock:(void(^)(id))cfmBlock cancelBlock:(void(^)(void))cnlBlock preferredStyle:(DMDialogControllerStyle)aStyle;
- (void)addButton:(UIButton *)button action:(SEL)selector;
- (void)dismiss;

+ (UIImage *)base64ToImage:(NSString *)base64ImageStr;
+ (NSString *)imageToBase64:(UIImage *)image;
@end
