//
//  AServerFileHandlers.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/11/18.
//

#import "AServerFileHandlers.h"
#import <GLogger/Logger.h>
#import <DMEncrypt/DMEncrypt.h>
#import <GBaseLib/GConvenient.h>
#import <SSZipArchive/SSZipArchive.h>

@implementation AServerFileHandlers

/// 处理文件
+ (void)handleFile:(NSString *)filename path:(NSString *)path {
    if ([filename hasSuffix:@".dek"]) {
        [self handleDek:filename path:path];
    } else if ([filename hasSuffix:@".html"] ||
               [filename hasSuffix:@".js"] ||
               [filename hasSuffix:@".png"] ||
               [filename hasSuffix:@".jpg"] ||
               [filename hasPrefix:@".css"]) {
        [self handleHtml:filename path:path];
    } else {
        LOGE(@"[HServer] => %@, 文件不支持", filename);
        LOGE(@"[HServer] => 当前支持类型: [dek、html、js、png、jpg、css]");
    }
}


+ (void)handleHtml:(NSString *)filename path:(NSString *)path {
    NSString *html = [NSHomeDirectory() stringByAppendingString:@"Documents/html"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:html]) {
        LOGE(@"[DEBUG] => /Documents/html文件夹不存在");
        BOOL sc = [fm createDirectoryAtPath:html withIntermediateDirectories:YES attributes:nil error:nil];
        if (!sc) return;
    }
    NSString *des = FORMAT(@"%@%@/%@", html, ![filename hasSuffix:@".html"]?@"/static":@"", filename);
    if ([fm fileExistsAtPath:des]) {
        [fm removeItemAtPath:des error:nil];
    }
    if (![fm fileExistsAtPath:FORMAT(@"%@/static", html)]) {
        BOOL sc = [fm createDirectoryAtPath:FORMAT(@"%@/static", html) withIntermediateDirectories:YES attributes:nil error:nil];
        if (!sc) return;
    }
    LOGV(@"[DEBUG] => 移动%@到/Documents/html", filename);
    NSError *error;
    [fm moveItemAtPath:FORMAT(@"%@/%@", path, filename) toPath:des error:&error];
    if (error) {
        LOGV(@"[DEBUG] => 文件 移动失败: %@.", error);
    } else {
        LOGV(@"[DEBUG] => 文件%@, 替换成功.", filename);
    }
}

+ (void)handleDek:(NSString *)filename path:(NSString *)path {
    NSString *dek = [path stringByAppendingPathComponent:filename];
    if (![dek hasSuffix:@".dek"]) {
        LOGE(@"[DEBUGGER] => 请上传正确的DEK文件.");
        return;
    }
    NSString *zipPath = [path stringByAppendingPathComponent:@"/main.zip"];
    LOGI(@"[DEBUGGER] => DEK 开始解密.");
    BOOL suc = [DMEncrypt decryptFile:dek des:zipPath keyString:@"$Guo$Zhong$Da$Key$H5"];
    if (!suc) {
        LOGV(@"[DEBUGGER] => DEK 解密失败.");
        return;
    }
    NSString *html = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/html"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:html]) {
        LOGV(@"[DEBUGGER] => DEK /Documents/html存在, 先移除");
        [fm removeItemAtPath:html error:nil];
    }
    if (![fm fileExistsAtPath:html]) {
        BOOL sc = [fm createDirectoryAtPath:html withIntermediateDirectories:YES attributes:nil error:nil];
        if (!sc) return;
    }
    LOGV(@"[DEBUGGER] => DEK 解压到/Documents/html");
    suc = [SSZipArchive unzipFileAtPath:zipPath toDestination:html];
    NSError *error;
    [fm removeItemAtPath:zipPath error:&error];
    if (suc) LOGI(@"[DEBUGGER] => DEK 文件替换成功.");
}

@end
