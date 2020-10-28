//
//  DMDekTask.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/10.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "DMDekTask.h"
#import <DMEncrypt/DMEncrypt.h>
#import <SSZipArchive/SSZipArchive.h>
#import <GBaseLib/GConvenient.h>
#import <GConst/HTMLConst.h>

@interface DMDekTask ()
///> DEK解压任务
@property (nonatomic, strong) GTaskSource *tcs;
///>  
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation DMDekTask

#pragma mark - Public
///=============================================================================
/// @name Public
///=============================================================================

+ (GTask *)task {
    return [DMDekTask new].tcs.task;
}

#pragma mark - Initilize
///=============================================================================
/// @name Initilize
///=============================================================================

- (instancetype)init {
    if (self = [super init]) {
        _tcs = [GTaskSource source];
        _queue = dispatch_queue_create("com.doumi.app.Dek", DISPATCH_QUEUE_SERIAL);
        dispatch_async(_queue, ^{
            [self handleDek:[self dekPath]];
        });
    }
    return self;
}

- (void)handleDek:(NSString *)dekPath {
    // name
    NSString *name = [[dekPath lastPathComponent] componentsSeparatedByString:@"."].firstObject;
    if (!name) return;
    // dek => zip
    NSString *zip = FORMAT(@"Documents/%@.zip", name);
    NSString *zipPath = [NSHomeDirectory() stringByAppendingPathComponent:zip];
    BOOL suc = [DMEncrypt decryptFile:dekPath des:zipPath keyString:@"$Guo$Zhong$Da$Key$H5"];
    if (!suc) {
        return;
    }
    // 是否存在html路径
    NSString *html = HTML_PATH;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:html]) {
        BOOL sc = [fm createDirectoryAtPath:html withIntermediateDirectories:YES attributes:nil error:nil];
        if (!sc) return;
    }

    NSString *staticDek = FORMAT(@"%@/static", HTML_PATH);
    if ([fm fileExistsAtPath:staticDek])  return;
    // 解压到html
    suc = [SSZipArchive unzipFileAtPath:zipPath toDestination:html];
    NSError *error;
    [fm removeItemAtPath:zipPath error:&error];
}

#pragma mark - Paths
///=============================================================================
/// @name Paths
///=============================================================================

- (NSString *)dekPath {
    return [[NSBundle mainBundle] pathForResource:@"main" ofType:@"dek"];
}

@end
