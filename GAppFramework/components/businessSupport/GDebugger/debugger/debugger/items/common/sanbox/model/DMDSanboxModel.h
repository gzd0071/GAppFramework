//
//  DMDSanboxModel.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/5/6.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMDSanboxModel : NSObject
///> 
@property (nonatomic, copy) NSString *name;
///> 
@property (nonatomic, copy) NSString *path;
///> 
@property (nonatomic, assign) BOOL isFile;
@end

NS_ASSUME_NONNULL_END
