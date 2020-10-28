//
//  DMLoginNetWork.m
//  DMLogin
//
//  Created by NonMac on 2019/6/20.
//

#import "DMLoginNetWork.h"

@implementation DMLoginNetWork
//https://jz-c-test.doumi.com
//https://jz-c.doumi.com
// sms post     b /api/v2/client/authCkCode  c /api/v2/client/authCkCode
// login verify post json   b /api/v2/client/login   c /api/v2/client/login
//- (void)requestSMSAuthCodeForMobileNumber:(NSString *)mobileNumber capthcaString:(NSString *)capthca type:(NSString *)type smsType:(NSString *)smsType successBlock:(DMHttpSuccessBlock)successBlock failBlock:(DMHttpFailBlock)failBlock
//- (void)requestSMSAuthCodeForMobileNumber:(NSString *)mobileNumber capthcaString:(NSString *)capthca successBlock:(DMHttpSuccessBlock)successBlock failBlock:(DMHttpFailBlock)failBlock

// getPic  GET  https://jz-c-sim.doumi.com /api/v2/client/ajax/encodedcode
// linkThirdAccount /api/v3/client/ucenter/thirdbindlogin
//      c notificationState [[UIApplication sharedApplication] currentUserNotificationSettings].type off/on

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



- (void)dmLoginPostReq {
    NSString *url = @"https://jz-c.doumi.com/api/v2/client/authCkCode?platform=ios&token=";
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:url]];
    
    req.HTTPMethod = @"POST";
    NSDictionary *headers =
    @{@"Accept-Encoding" : @"gzip",
      @"Accept-Language" : @"zh-Hans-CN;q=1",
      @"AccessToken" : @" LmRlaxBuMmrBOdOW6gNyAI0CdoipCyJf0UzmhuoTNzDNV7Yomf5yf8QMljZqcye0zFfT7Zi6",
      @"Common" : @"LmRlaxCoF8CsDHtmOmRYZtaqw0cVazbD/O1bd4+GeLcwvoZWVWv3U81cW7dKVIrXZhtjkwAtR2PMXFt3qdWJBlMfo3I12JJGqMlOR1+hKTMWmjZCUMiCtvhZPgIK4VmDlvomwkXIZqOdnJj3SqSssyZac3KgnQKWqMnOIl8xfLO2vyYWlahXwF3NOwZK1YmX1s325+WIRGNtnFvXiiE55mJvRif2qAZieMneZwr16YZTDFdn1U0SNpi5bmJP8Rzztr8mFpWoV8DcXCtm2kFMw1ZKNidkCDdjXkw7tyoUOGNmmgPCRchmo52cmLeKpeljhx8nt8UMg9P8DKuz79Qp15PPJoSVSFejeP4+ZS/W/CNGK/MlN/rTdvhZKfNIATyD171EIgAdJQa/qSlFPyE55mJvRif2SBfT/Kx7FxvFWOYiKmZ2BFhXhu2cCrdqxIpm878mt9AIBLNdLDsjPyFp9vC+53ZVTQKGnVwqto8hODaT3jaEFclGs3jJ3scK1TgnAq+jBpX4l4Y9jAs3j6Ec9Fa9ZGVATDJ2OLm/Yl/WW2IRqvNi0e0iNihJDmXfoUsjNg==",
      @"Content-Type" : @"application/json",
      @"User-Agent" : @"DouMi/6.1.0 BuildCode/159 Platform/iOS ChannelID/AppStore dmdt/0cd97002f03e816d35e885952e7b390e",
      @"X-Ganji-CustomerId" : @"779",
      @"agency" : @"appstore",
      @"clientAgent" : @"iPhone#375*667",
      @"contentformat" : @"json2",
      @"doumi-protocol" : @"https",
      @"info" : @"LmRlaxBGj/Gdo+f6w1c1TRJmOHlbp4+GeLcwvoZWVS03o+xd+WePkcyHUz8mR0Sql3I8XivyT7HMpgL+5jfQ/RKGndxKBsrEWGMxf+aXFdtX8/38m/fvBquFkSryl1RYx6cpLDrnmgDMt4MPlifQLedj7I36JgpBCCZjb8PnRfgX5pipKXIYhmvz18oz4nBMQjbv7r81DxFsYnbac/KA/UW2mP7+Eu/UKdeTzyaE1WhHY20Z+yTaZJnmB5rDRyTIF3L9P3tmjw=="
      };
    for (NSString *key in headers.allKeys) {
        [req setValue:headers[key] forHTTPHeaderField:key];
    }
    
    //    req
    
    NSDictionary *body = @{@"mobile" : @"17400112015",
                           @"smsType" : @"1",
                           @"type" : @"0"};
    
    [req setHTTPBody:[NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil]];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    static NSURLSession *session;
    
    session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionTask *task = [session dataTaskWithRequest:req
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            if (error) {
                                                NSLog(@"处理失败");
                                            } else {
                                                NSLog(@"处理成功");
                                            }
                                        }];
    //    session.delegate = self;
    [task resume];
}

@end
