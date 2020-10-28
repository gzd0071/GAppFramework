//
//  HttpResult.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/7/16.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import "HttpResult.h"

HttpResultKey const HttpResultKeyCode    = @"code";
HttpResultKey const HttpResultKeyMessage = @"message";
HttpResultKey const HttpResultKeyData    = @"data";

@implementation HttpResult
- (NSString *)description {
    return [NSString stringWithFormat:@"HttpResult{code=%li, message='%@', data=%@}", (long)_code, _message, _data];
}
@end
