//
//  DMDRequestPacket.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/30.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "URLInjectorRequestPacket.h"

@interface URLInjectorRequestPacket()
///> 
@property (nonatomic, strong, readwrite) NSData *requestBody;
@end

@implementation URLInjectorRequestPacket

#pragma mark - PrettyLog
///=============================================================================
/// @name PrettyLog
///=============================================================================

- (NSString *)description {
    NSString *des = [super description];
    des = [des stringByAppendingFormat:@" id = %@;", self.requestID];
    des = [des stringByAppendingFormat:@" url = %@;", self.request.URL];
    des = [des stringByAppendingFormat:@" duration = %f;", self.duration];
    des = [des stringByAppendingFormat:@" receivedDataLength = %lld", self.receivedDataLength];
    return des;
}

- (NSData *)requestBody {
    if (!_requestBody) {
        if (self.request.HTTPBody != nil) {
            _requestBody = self.request.HTTPBody;
        } else if ([self.request.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
            NSInputStream *bodyStream = [self.request.HTTPBodyStream copy];
            const NSUInteger bufferSize = 1024;
            uint8_t buffer[bufferSize];
            NSMutableData *data = [NSMutableData data];
            [bodyStream open];
            NSInteger readBytes = 0;
            do {
                readBytes = [bodyStream read:buffer maxLength:bufferSize];
                [data appendBytes:buffer length:readBytes];
            } while (readBytes > 0);
            [bodyStream close];
            _requestBody = data;
        }
    }
    return _requestBody;
}

- (NSURL *)url {
    return self.request.URL;
}

- (NSDictionary *)requestHeaders {
    return self.request.allHTTPHeaderFields;
}

- (NSString *)requestMethod {
    return self.request.HTTPMethod;
}

- (NSString *)statusCode {
    if ([self.response isKindOfClass:NSHTTPURLResponse.class]) {
        return [@([(NSHTTPURLResponse *)self.response statusCode]) stringValue];
    }
    return @"999";
}

- (NSDictionary *)responseHeaders {
    if ([self.response isKindOfClass:NSHTTPURLResponse.class]) {
        return [(NSHTTPURLResponse *)self.response allHeaderFields];
    }
    return nil;
}

@end
