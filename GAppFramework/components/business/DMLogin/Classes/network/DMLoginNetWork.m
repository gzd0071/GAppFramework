//
//  DMLoginNetWork.m
//  DMLogin
//
//  Created by NonMac on 2019/6/20.
//

#import "DMLoginNetWork.h"

@implementation DMLoginNetWork

+ (void)postJsonRequestWithUrl:(NSString *)urlStr headers:(NSDictionary *)headers body:(NSDictionary *)body success:(successBlock)sBlock fail:(failBlock)fBlock {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setHTTPMethod:@"POST"];
    
    for (NSString *key in headers.allKeys) {
        [req setValue:headers[key] forHTTPHeaderField:key];
    }
    
    if (body) {
        if (![req valueForHTTPHeaderField:@"Content-Type"]) {
            [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        }
        [req setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil]];
    }
    
    static NSURLSession *session;
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setTimeoutIntervalForRequest:30];
    session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionTask *task = [session dataTaskWithRequest:req
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                            if (error) {
                                                if (fBlock) {
                                                    fBlock(error, response);
                                                }
                                            } else {
                                                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                                                    NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                    NSLog(@"%@\n%@", urlStr, obj);
                                                    if (resp.statusCode <= 200) {
                                                        if (sBlock) {
                                                            sBlock(obj, response);
                                                        }
                                                    } else {
                                                        fBlock(error, obj);
                                                    }
                                                }
                                            }
                                                });
                                        }];
    [task resume];
}

+ (void)getJsonRequestWithUrl:(NSString *)urlStr headers:(NSDictionary *)headers body:(NSDictionary *)body success:(successBlock)sBlock fail:(failBlock)fBlock {
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [req setHTTPMethod:@"GET"];
    
    for (NSString *key in headers.allKeys) {
        [req setValue:headers[key] forHTTPHeaderField:key];
    }
    
    NSString *query;
    NSMutableArray *pairs = NSMutableArray.new;
    for (NSString *key in body.allKeys) {
        NSString *aPairStr = [NSString stringWithFormat:@"%@=%@", key, [body objectForKey:key]];
        [pairs addObject:aPairStr];
    }
    query = [pairs componentsJoinedByString:@"%&"];
    
    req.URL = [NSURL URLWithString:[[req.URL absoluteString] stringByAppendingFormat:@"?%@", query]];
    
    static NSURLSession *session;
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionTask *task = [session dataTaskWithRequest:req
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                            if (error) {
                                                if (fBlock) {
                                                    fBlock(error, response);
                                                }
                                            } else {
                                                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                                    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
                                                    NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                    NSLog(@"%@\n%@", urlStr, obj);
                                                    if (resp.statusCode <= 200) {
                                                        if (sBlock) {
                                                            sBlock(obj, response);
                                                        }
                                                    } else {
                                                        fBlock(error, obj);
                                                    }
                                                }
                                            }
                                            });
                                        }];
    [task resume];
    
}

#define kAppleUrlToCheckNetStatus @"http://captive.apple.com/"
+ (BOOL)checkNetCanUse {
    __block BOOL canUse = NO;
    NSString *urlString = kAppleUrlToCheckNetStatus;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 3;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    //**// 使用信号量实现NSURLSession同步请求**
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString* result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //解析html页面
        NSString *htmlString = [self filterHTML:result];
        //除掉换行符
        NSString *resultString = [htmlString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        if ([resultString isEqualToString:@"SuccessSuccess"]) {
            canUse = YES;
            NSLog(@"手机所连接的网络是可以访问互联网的: %d",canUse);
        } else {
            canUse = NO;
            NSLog(@"手机无法访问互联网: %d",canUse);
        }
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return canUse;
}

+ (NSString *)filterHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ;
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
                [NSString stringWithFormat:@"%@>", text]
                                               withString:@""];
    }
    return html;
}

@end
