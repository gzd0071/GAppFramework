//
//  DMEncrypt.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/5/10.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DMEncrypt : NSObject

#pragma mark - String
///=============================================================================
/// @name String
///=============================================================================

+ (NSString *)decryptString:(NSString *)str;
+ (NSString *)encryptString:(NSString *)str;

#pragma mark - File
///=============================================================================
/// @name File
///=============================================================================

//+ (BOOL)encryptFile:(NSString *)src des:(NSString *)des keyString:(NSString *)key;
+ (BOOL)decryptFile:(NSString *)src des:(NSString *)des keyString:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
