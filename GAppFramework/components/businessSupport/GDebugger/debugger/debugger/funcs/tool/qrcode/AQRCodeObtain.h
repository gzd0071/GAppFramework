//
//  AQRCodeObtain.h
//  Debugger
//
//  Created by iOS_Developer_G on 2019/11/13.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AQRCodeObtainConfigure : NSObject
/** 类方法创建 */
+ (instancetype)QRCodeObtainConfigure;

/** 会话预置，默认为：AVCaptureSessionPreset1920x1080 */
@property (nonatomic, copy) NSString *sessionPreset;
/** 元对象类型，默认为：AVMetadataObjectTypeQRCode */
@property (nonatomic, strong) NSArray *metadataObjectTypes;
/** 扫描范围，默认整个视图（每一个取值 0 ～ 1，以屏幕右上角为坐标原点）*/
@property (nonatomic, assign) CGRect rectOfInterest;
/** 是否需要样本缓冲代理（光线强弱），默认为：NO */
@property (nonatomic, assign) BOOL sampleBufferDelegate;
/** 打印信息，默认为：NO */
@property (nonatomic, assign) BOOL openLog;

@end

@class AQRCodeObtainConfigure, AQRCodeObtain;

typedef void(^AQRCodeObtainScanResultBlock)(AQRCodeObtain *obtain, NSString *result);
typedef void(^AQRCodeObtainScanBrightnessBlock)(AQRCodeObtain *obtain, CGFloat brightness);
typedef void(^AQRCodeObtainAlbumDidCancelImagePickerControllerBlock)(AQRCodeObtain *obtain);
typedef void(^AQRCodeObtainAlbumResultBlock)(AQRCodeObtain *obtain, NSString *result);

@interface AQRCodeObtain : NSObject
/** 类方法创建 */
+ (instancetype)QRCodeObtain;

#pragma mark - - 生成二维码相关方法
/**
 *  生成二维码
 *
 *  @param data    二维码数据
 *  @param size    二维码大小
 */
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size;
/**
 *  生成二维码（自定义颜色）
 *
 *  @param data     二维码数据
 *  @param size     二维码大小
 *  @param color    二维码颜色
 *  @param backgroundColor    二维码背景颜色
 */
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size color:(UIColor *)color backgroundColor:(UIColor *)backgroundColor;
/**
 *  生成带 logo 的二维码（推荐使用）
 *
 *  @param data     二维码数据
 *  @param size     二维码大小
 *  @param logoImage    logo
 *  @param ratio        logo 相对二维码的比例（取值范围 0.0 ～ 0.5f）
 */
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio;
/**
 *  生成带 logo 的二维码（拓展）
 *
 *  @param data     二维码数据
 *  @param size     二维码大小
 *  @param logoImage    logo
 *  @param ratio        logo 相对二维码的比例（取值范围 0.0 ～ 0.5f）
 *  @param logoImageCornerRadius    logo 外边框圆角（取值范围 0.0 ～ 10.0f）
 *  @param logoImageBorderWidth     logo 外边框宽度（取值范围 0.0 ～ 10.0f）
 *  @param logoImageBorderColor     logo 外边框颜色
 */
+ (UIImage *)generateQRCodeWithData:(NSString *)data size:(CGFloat)size logoImage:(UIImage *)logoImage ratio:(CGFloat)ratio logoImageCornerRadius:(CGFloat)logoImageCornerRadius logoImageBorderWidth:(CGFloat)logoImageBorderWidth logoImageBorderColor:(UIColor *)logoImageBorderColor;

#pragma mark - - 扫描二维码相关方法
/** 创建扫描二维码方法 */
- (void)establishQRCodeObtainScanWithController:(UIViewController *)controller configure:(AQRCodeObtainConfigure *)configure;
/** 扫描二维码回调方法 */
- (void)setBlockWithQRCodeObtainScanResult:(AQRCodeObtainScanResultBlock)block;
/** 扫描二维码光线强弱回调方法；调用之前配置属性 sampleBufferDelegate 必须为 YES */
- (void)setBlockWithQRCodeObtainScanBrightness:(AQRCodeObtainScanBrightnessBlock)block;
/** 开启扫描回调方法 */
- (void)startRunningWithBefore:(void (^)(void))before completion:(void (^)(void))completion;
/** 停止扫描方法 */
- (void)stopRunning;

/** 播放音效文件 */
- (void)playSoundName:(NSString *)name;

#pragma mark - - 相册中读取二维码相关方法
/** 创建相册并获取相册授权方法 */
- (void)establishAuthorizationQRCodeObtainAlbumWithController:(UIViewController *)controller;
/** 判断相册访问权限是否授权 */
@property (nonatomic, assign) BOOL isPHAuthorization;
/** 图片选择控制器取消按钮的点击回调方法 */
- (void)setBlockWithQRCodeObtainAlbumDidCancelImagePickerController:(AQRCodeObtainAlbumDidCancelImagePickerControllerBlock)block;
/** 相册中读取图片二维码信息回调方法 */
- (void)setBlockWithQRCodeObtainAlbumResult:(AQRCodeObtainAlbumResultBlock)block;

#pragma mark - - 手电筒相关方法
/** 打开手电筒 */
- (void)openFlashlight;
/** 关闭手电筒 */
- (void)closeFlashlight;

@end
