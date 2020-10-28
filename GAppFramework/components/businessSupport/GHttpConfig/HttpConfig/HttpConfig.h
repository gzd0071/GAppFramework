//
//  HttpConfig.h
//  Doumi
//
//  Created by iOS_Developer_G on 2019/8/9.
//  Copyright © 2019 GCompany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHttpRequest/HttpRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpConfig : NSObject<HttpRequestConfigDelegate>
- (NSString *)requestBaseUrl;
@end

NS_ASSUME_NONNULL_END
