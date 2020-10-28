//
//  URLInjectorRequestPacket.h
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/30.
//  Copyright © 2019 doumi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, URLInjectorPacketState) {
    ///
    URLInjectorPacketStateUnstarted,
    URLInjectorPacketStateAwaitingResponse,
    URLInjectorPacketStateReceivingData,
    URLInjectorPacketStateFinished,
    URLInjectorPacketStateFailed
};

////////////////////////////////////////////////////////////////////////////////
/// @@protocol DMDRequestPacket
////////////////////////////////////////////////////////////////////////////////

@interface URLInjectorRequestPacket : NSObject
///> 
@property (nonatomic, strong) NSString *requestID;
///> 
@property (nonatomic, strong) NSURLRequest *request;
///> 
@property (nonatomic) NSURLResponse *response;
///> 
@property (nonatomic, assign) URLInjectorPacketState state;
///> 请求: 开始 
@property (nonatomic, strong) NSDate *startDate;
///> 请求: 
@property (nonatomic, assign) NSTimeInterval latency;
///> 请求: 
@property (nonatomic, assign) NSTimeInterval duration;
///> 
@property (nonatomic, assign) int64_t receivedDataLength;
///> 
@property (nonatomic, strong) NSError *error;
///> 
@property (nonatomic, strong) NSString *mechanism;

///> 请求: Url 
@property (nonatomic, strong, readonly) NSURL *url;
///> 请求: Header 
@property (nonatomic, strong, readonly) NSDictionary *requestHeaders;
///> 请求: Body 
@property (nonatomic, strong, readonly) NSData *requestBody;
///> 请求: Method 
@property (nonatomic, strong, readonly) NSString *requestMethod;
///> Response: Header 
@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;
///> Response: Data 
@property (nonatomic, strong, readonly) NSData *responseData;
///> Response: Code 
@property (nonatomic, strong, readonly) NSString *statusCode;
@end

NS_ASSUME_NONNULL_END
