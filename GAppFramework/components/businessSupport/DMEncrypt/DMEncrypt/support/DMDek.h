//
//  KCDek.h
//  dek
//
//  Created by zihong on 15/11/21.
//  Copyright © 2015年 zihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMDek : NSObject

#pragma mark -
#pragma mark Data
+ (NSData *)encrypt:(NSData *)aPlainData key:(NSData *)aKey;
+ (NSData *)decrypt:(NSData *)aCipherData key:(NSData *)aKey;

+ (NSData *)encrypt:(NSData *)aPlainData keyString:(NSString *)aKey;
+ (NSData *)decrypt:(NSData *)aCipherData keyString:(NSString *)aKey;

+ (NSData *)encryptString:(NSString *)aPlainText keyString:(NSString *)aKey;
+ (NSString *)decryptToString:(NSData *)aCipherData keyString:(NSString *)aKey;


#pragma mark -
#pragma mark File
+ (BOOL)encryptFile:(NSString *)aSrcPath desPath:(NSString *)aDesPath key:(NSData *)aKey;
+ (BOOL)decryptFile:(NSString *)aSrcPath desPath:(NSString *)aDesPath key:(NSData *)aKey;

+ (BOOL)encryptFile:(NSString *)aSrcPath desPath:(NSString *)aDesPath keyString:(NSString *)aKey;
+ (BOOL)decryptFile:(NSString *)aSrcPath desPath:(NSString *)aDesPath keyString:(NSString *)aKey;


@end
