//
//  URLInjectorRecorder.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/8/26.
//

#import "URLInjectorRecorder.h"
#import <GLogger/Logger.h>
#import <YYKit/NSString+YYAdd.h>
#import <YYKit/NSData+YYAdd.h>
#import <YYKit/NSObject+YYModel.h>
#import <GBaseLib/GConvenient.h>
#import <DMEncrypt/DMEncrypt.h>

#define DHttpImageTypes       @[@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap"]
static NSString * const kURLInjectorRecorder = @"kURLInjectorRecorder";

@interface URLInjectorRecorder()
@property (nonatomic, strong) NSCache *repCache;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSMutableArray<URLInjectorRequestPacket *> *ordered;
@property (nonatomic, strong) NSMutableDictionary<NSString *, URLInjectorRequestPacket *> *reqIDs;
@end

@implementation URLInjectorRecorder

#pragma mark - Initial
///=============================================================================
/// @name Initial
///=============================================================================

+ (instancetype)recorder {
    static URLInjectorRecorder *recorder = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        recorder = [self new];
    });
    return recorder;
}

+ (void)clearPackets {
    [URLInjectorRecorder recorder].ordered = @[].mutableCopy;
}

+ (NSMutableArray<URLInjectorRequestPacket *> *)packets {
    return [URLInjectorRecorder recorder].packets;
}

+ (NSData *)cachedResponseBody:(URLInjectorRequestPacket *)packet {
    return [[URLInjectorRecorder recorder].repCache objectForKey:packet.requestID];
}

- (instancetype)init {
    if (self = [super init]) {
        _repCache = [NSCache new];
        _ordered  = @[].mutableCopy;
        _reqIDs   = @{}.mutableCopy;
        _queue    = dispatch_queue_create([kURLInjectorRecorder UTF8String], DISPATCH_QUEUE_SERIAL);
        _repCache.totalCostLimit = 1024 * 1024 * 1024;
    }
    return self;
}

- (void)performBlock:(dispatch_block_t)block {
    if ([[NSThread currentThread].name isEqualToString:kURLInjectorRecorder]) {
        block();
    } else {
        dispatch_async(self.queue, block);
    }
}

- (NSMutableArray<URLInjectorRequestPacket *> *)packets {
    __block NSArray<URLInjectorRequestPacket *> *packets = nil;
    dispatch_sync(self.queue, ^{
        packets = [self.ordered copy];
    });
    return [packets mutableCopy];
}

#pragma mark - HTTP RECORD
///=============================================================================
/// @name HTTP RECORD
///=============================================================================

- (void)recordRequestWillBeSentWithRequestID:(NSString *)requestID request:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    // TODO: 黑名单
    NSDate *start = [NSDate date];
    if (redirectResponse) {
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
        [self recordLoadingFinishedWithRequestID:requestID responseBody:nil];
    }
    [self performBlock:^{
        URLInjectorRequestPacket *packet = [URLInjectorRequestPacket new];
        packet.requestID = requestID;
        packet.request   = request;
        packet.startDate = start;
        
        [self.ordered insertObject:packet atIndex:0];
        [self.reqIDs setObject:packet forKey:requestID];
        packet.state = URLInjectorPacketStateAwaitingResponse;
        [self recordResponseReceivedWithRequestID:requestID response:redirectResponse];
    }];
}
/// Call when HTTP response is available.
- (void)recordResponseReceivedWithRequestID:(NSString *)requestID response:(NSURLResponse *)response {
    NSDate *responseDate = [NSDate date];
    [self performBlock:^{
        URLInjectorRequestPacket *packet = self.reqIDs[requestID];
        if (!packet) return;
        packet.response = response;
        packet.state    = URLInjectorPacketStateReceivingData;
        packet.latency  = -[packet.startDate timeIntervalSinceDate:responseDate];
    }];
}
/// Call when data chunk is received over the network.
- (void)recordDataReceivedWithRequestID:(NSString *)requestID dataLength:(int64_t)dataLength {
    [self performBlock:^{
        URLInjectorRequestPacket *packet = self.reqIDs[requestID];
        if (!packet) return;
        packet.receivedDataLength += dataLength;
    }];
}
/// Call when HTTP request has finished loading.
- (void)recordLoadingFinishedWithRequestID:(NSString *)requestID responseBody:(NSData *)responseBody {
    NSDate *end = [NSDate date];
    [self performBlock:^{
        URLInjectorRequestPacket *packet = self.reqIDs[requestID];
        if (!packet) return;
        packet.state    = URLInjectorPacketStateFinished;
        packet.duration = -[packet.startDate timeIntervalSinceDate:end];
        
        BOOL shouldCache = responseBody.length > 0;
        if (shouldCache) [self.repCache setObject:responseBody forKey:requestID cost:responseBody.length];
        LOGD(@"[URLInjector] ============= 请求详情START =============");
        LOGD(@"[URLInjector] =>i.URL: %@", packet.url.absoluteString);
        LOGD(@"[URLInjector] =>i.请求类型: %@", packet.request.HTTPMethod);
        LOGD(@"[URLInjector] =>i.开始时间: %@", [self timeFormat:packet.startDate]);
        LOGD(@"[URLInjector] =>i.请求耗时: %@", [self formatTime:packet.duration]);
        if (packet.requestHeaders)  LOGD(@"[URLInjector] =>i.请求Headers: %@", [self handleRequestHeaders:packet.requestHeaders]);
        if (packet.requestBody)     LOGD(@"[URLInjector] =>i.请求Body: %@", [self handleRequestBody:packet.requestBody.utf8String]);
        if (packet.responseHeaders) LOGD(@"[URLInjector] =>i.响应Headers: %@", packet.responseHeaders);
        if (responseBody)           LOGD(@"[URLInjector] =>i.响应Body: %@", [responseBody jsonValueDecoded]);
        LOGD(@"[URLInjector] ============= 请求详情END =============");
    }];
}

- (NSDictionary *)handleRequestHeaders:(NSDictionary *)dict {
    NSMutableDictionary *mut = dict.mutableCopy;
    if (mut[@"Common"]) mut[@"Common"] = [self decodeParaString:mut[@"Common"]];
    if (mut[@"info"]) mut[@"info"] = [self decodeParaString:mut[@"info"]];
    if (mut[@"AccessToken"]) mut[@"AccessToken"] = [DMEncrypt decryptString:mut[@"AccessToken"]];
    if (mut[@"Cookie"]) mut[@"Cookie"] = [self paraString:mut[@"Cookie"]];
    return mut;
}

- (NSDictionary *)decodeParaString:(NSString *)str {
    str = [DMEncrypt decryptString:str];
    return [self paraString:str];
}

- (NSString *)timeFormat:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dateFormatter stringFromDate:date];
}

- (NSDictionary *)handleRequestBody:(NSString *)jsonString {
    NSDictionary *dict = jsonString.jsonValueDecoded;
    if (!dict) {
        return [self paraString:jsonString];
    };
    NSMutableDictionary *mut = dict.mutableCopy;
    if (mut[@"data"]) mut[@"data"] = [DMEncrypt decryptString:mut[@"data"]];
    return mut;
}

- (NSDictionary *)paraString:(NSString *)str {
    NSArray *arr = [str componentsSeparatedByString:@";"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    [arr enumerateObjectsUsingBlock:^(NSString *kv, NSUInteger idx, BOOL *stop) {
        NSArray *kva = [kv componentsSeparatedByString:@"="];
        NSString *key = kva.firstObject;
        key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSString *value = kva.count > 1 ? kva[1] : @"";
        value = [value stringByRemovingPercentEncoding];
        id jv = value.modelToJSONObject;
        if (jv) value = jv;
        dict[key] = value;
    }];
    return dict;
}

- (NSString *)formatTime:(NSTimeInterval)pad {
    if (pad >= 3600 * 24) {
        return FORMAT(@"%ldd", (long)(pad/(3600 *24)));
    } else if (pad >= 3600) {
        return FORMAT(@"%ldh", (long)(pad/(3600)));
    } else if (pad >= 60) {
        return FORMAT(@"%ldmin", (long)(pad/(60)));
    } else if (pad >= 1) {
        return FORMAT(@"%.2fs", pad);
    } else {
        return FORMAT(@"%ldms", (long)(pad * 1000));
    }
}

/// Call when HTTP request has failed to load.
- (void)recordLoadingFailedWithRequestID:(NSString *)requestID error:(NSError *)error {
    [self performBlock:^{
        URLInjectorRequestPacket *packet = self.reqIDs[requestID];
        if (!packet) return;
        packet.state    = URLInjectorPacketStateFailed;
        packet.duration = -[packet.startDate timeIntervalSinceNow];
        packet.error    = error;
    }];
}
/// Call to set the request mechanism anytime after recordRequestWillBeSent... has been called.
/// This string can be set to anything useful about the API used to make the request.
- (void)recordMechanism:(NSString *)mechanism forRequestID:(NSString *)requestID {
    [self performBlock:^{
        URLInjectorRequestPacket *packet = self.reqIDs[requestID];
        if (!packet) return;
        packet.mechanism = mechanism;
    }];
}

@end
