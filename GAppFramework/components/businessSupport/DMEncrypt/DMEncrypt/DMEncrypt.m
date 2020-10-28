//
//  DMEncrypt.m
//  Doumi
//
//  Created by iOS_Developer_G on 2019/5/10.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "DMEncrypt.h"
#import "DMDek.h"
#import <YYKit/NSData+YYAdd.h>

#define kDMEncryptKey @"%&%DOUMI!@!DEVICE#%#ID^&^"

@implementation DMEncrypt

#pragma mark - String
///=============================================================================
/// @name String
///=============================================================================

+ (NSString *)decryptString:(NSString *)str {
    NSData *base64 = [NSData dataWithBase64EncodedString:str];
    return [DMDek decryptToString:base64 keyString:kDMEncryptKey];
}

+ (NSString *)encryptString:(NSString *)str {
    NSData *result = [DMDek encryptString:str keyString:kDMEncryptKey];
    return [result base64EncodedString];
}

+ (BOOL)decryptFile:(NSString *)src des:(NSString *)des keyString:(NSString *)key {
    return [DMDek decryptFile:src desPath:des keyString:key];
}

@end
