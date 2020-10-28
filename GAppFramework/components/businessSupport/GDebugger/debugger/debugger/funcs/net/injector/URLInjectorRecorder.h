//
//  URLInjectorRecorder.h
//  Debugger
//
//  Created by iOS_Developer_G on 2019/8/26.
//

#import <Foundation/Foundation.h>
#import "URLInjectorRequestPacket.h"

NS_ASSUME_NONNULL_BEGIN

@interface URLInjectorRecorder : NSObject

+ (instancetype)recorder;
+ (NSMutableArray<URLInjectorRequestPacket *> *)packets;
+ (NSData *)cachedResponseBody:(URLInjectorRequestPacket *)packet;
+ (void)clearPackets;
@property (nonatomic, strong, readonly) NSMutableArray<URLInjectorRequestPacket *> *packets;

#pragma mark - HTTP RECORD
///=============================================================================
/// @name HTTP RECORD
///=============================================================================

/// Call when app is about to send HTTP request.
- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)redirectResponse;

/// Call when HTTP response is available.
- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response;

/// Call when data chunk is received over the network.
- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength;

/// Call when HTTP request has finished loading.
- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(nullable NSData *)responseBody;

/// Call when HTTP request has failed to load.
- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error;

/// Call to set the request mechanism anytime after recordRequestWillBeSent... has been called.
/// This string can be set to anything useful about the API used to make the request.
- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID;

@end

NS_ASSUME_NONNULL_END
