//
//  DMUploadImage.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/27.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMUploadImage.h"
#import <GHttpRequest/HttpRequest.h>
#import <ReactiveObjC/UIImagePickerController+RACSignalSupport.h>
#import <GRouter/GRouter.h>
#import <ReactiveObjC/RACSignal.h>
#import <AFNetworking/AFURLRequestSerialization.h>
#import <DMUILib/GHud.h>

///> 修正在iPhoneX手机上, 裁剪图片偏移的问题 
@interface DMPickerVC : UIImagePickerController
@end
@implementation DMPickerVC
- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}
- (BOOL)prefersStatusBarHidden {
    if (self.viewControllers.count == 3) return YES;
    return NO;
}
@end

@implementation DMUploadImage
///> 选取图片->上传服务器->获取地址 
+ (GTask *)uploadImage:(UIImagePickerControllerSourceType)type {
    return [self getImage:type].then(^id(GTaskResult<UIImage *> *t) {
        if (!t.suc) return [GTaskResult taskResultWithSuc:NO];
        return [self handlerImage:t.data];
    }).then(^id(GTaskResult<UIImage *> *t){
        if (t.suc) return t.data;
        return @{@"status":@"0"};
    });
}
///> 获取图片: 拍照 or 从相册选取 
+ (GTask *)getImage:(UIImagePickerControllerSourceType)type {
    GTaskSource *tcs = [GTaskSource source];
    DMPickerVC *pc = [[DMPickerVC alloc] init];
    pc.allowsEditing = YES;
    pc.sourceType = type;
    UIViewController *vc = [GRouter navi].visibleViewController;
    [pc.rac_imageSelectedSignal subscribeNext:^(NSDictionary *info) {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) [info objectForKey:UIImagePickerControllerOriginalImage];
        [tcs setResult:[GTaskResult taskResultWithSuc:YES data:image]];
        [vc dismissViewControllerAnimated:YES completion:^{}];
    } completed:^{
        [vc dismissViewControllerAnimated:YES completion:^{}];
        [tcs setResult:[GTaskResult taskResultWithSuc:NO]];
    }];
    pc.modalPresentationStyle = UIModalPresentationFullScreen;
    [vc presentViewController:pc animated:YES completion:^{}];
    return tcs.task;
}
///> 获取图片: 拍照 or 从相册选取 
+ (GTask *)handlerImage:(UIImage *)img {
    [GHud hud];
    HttpRequest *request = [HttpRequest jsonRequest]
    .urlString(@"/api/v3/client/photo").method(HttpMethodPost)
    .formData(^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(img, 0.8);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        [formData appendPartWithFileData:data name:@"photo" fileName:fileName mimeType:@"image/*"];
    });
    return request.task.then(^id(HttpResult *t){
        [GHud hide];
        if ([t.extra[@"info"] isKindOfClass:NSArray.class] && [t.extra[@"info"] count]) {
            NSString *imgURL  = t.extra[@"info"][0][@"thumbUrl"];
            NSString *imgName = t.extra[@"info"][0][@"url"];
            if ([imgURL isKindOfClass:NSString.class] && imgURL.length && imgName.length) {
                return [GTaskResult taskResultWithSuc:YES data:@{@"imageURL":imgURL, @"imageName": imgName, @"status": @"1"}];
            }
        }
        return [GTaskResult taskResultWithSuc:NO];
    });
}

@end
