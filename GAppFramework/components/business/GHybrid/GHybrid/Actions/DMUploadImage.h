//
//  DMUploadImage.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/9/27.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GBaseLib/GConvenient.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMUploadImage : NSObject
+ (GTask<GTaskResult *> *)uploadImage:(UIImagePickerControllerSourceType)type;
@end

NS_ASSUME_NONNULL_END
