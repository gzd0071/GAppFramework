//
//  URLInjector.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/30.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "URLInjector.h"
#import "URLInjectorRecorder.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <GLogger/Logger.h>

static char const * const kURLInjectorRequestIDKey = "kURLInjectorRequestIDKey";
static char const * const kURLInjectorQueue        = "kURLInjectorQueue";
static NSString * kURLInjectorDefaultsKey          = @"com.doumi.debugger.urlInjector.enabled";

typedef void (^NSURLSessionAsyncCompletion)(id fileURLOrData, NSURLResponse *response, NSError *error);

#pragma mark - INLINE
///=============================================================================
/// @name INLINE
///=============================================================================

static inline void urlMethodExchangeBlock(Class cls, Method oriM, id block, SEL swiS) {
    IMP imp = imp_implementationWithBlock(block);
    class_addMethod(cls, swiS, imp, method_getTypeEncoding(oriM));
    Method swiM = class_getInstanceMethod(cls, swiS);
    method_exchangeImplementations(oriM, swiM);
}

static inline void urlMethodExchangeKnown(Class cls, SEL oriS, id block, SEL swiS) {
    Method oriM = class_getInstanceMethod(cls, oriS);
    if (!oriM) return;
    urlMethodExchangeBlock(cls, oriM, block, swiS);
}

////////////////////////////////////////////////////////////////////////////////
/// @@protocol RequestPacket
////////////////////////////////////////////////////////////////////////////////

@interface RequestPacket : NSObject
///> 请求 
@property (nonatomic, copy) NSURLRequest *request;
///> 请求数据 
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation RequestPacket
@end

////////////////////////////////////////////////////////////////////////////////
/// @@protocol URLInjector
////////////////////////////////////////////////////////////////////////////////

@interface URLInjector()
///> 队列 
@property (nonatomic, strong) dispatch_queue_t queue;
///> 
@property (nonatomic, strong) NSMutableDictionary<NSString *, RequestPacket *> *requests;
@end

@implementation URLInjector

#pragma mark - PUBLIC
///=============================================================================
/// @name PUBLIC
///=============================================================================

+ (BOOL)isEnabled {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kURLInjectorDefaultsKey] boolValue];
}

+ (void)setEnabled:(BOOL)enabled {
//    BOOL pre = [self isEnabled];
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kURLInjectorDefaultsKey];
    if (enabled) [self injectDelegateOnce];
}

#pragma mark - INITIAL
///=============================================================================
/// @name INITIAL
///=============================================================================

+ (void)load {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self isEnabled]) return;
        [self injectDelegateOnce];
    });
}

+ (instancetype)injector {
    static URLInjector *injector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        injector = [[URLInjector alloc] init];
    });
    return injector;
}

- (instancetype)init {
    if (self = [super init]) {
        _queue = dispatch_queue_create(kURLInjectorQueue, DISPATCH_QUEUE_SERIAL);
        _requests = @{}.mutableCopy;
    }
    return self;
}

- (void)performBlock:(dispatch_block_t)block {
    dispatch_async(_queue, block);
}

- (RequestPacket *)requestPacket:(NSString *)reqID {
    RequestPacket *packet = self.requests[reqID];
    if (packet) return packet;
    packet = [RequestPacket new];
    self.requests[reqID] = packet;
    return packet;
}

- (void)removePacket:(NSString *)reqID {
    [self.requests removeObjectForKey:reqID];
}

#pragma mark - PRIVITE
///=============================================================================
/// @name PRIVITE
///=============================================================================
+ (NSURLSessionAsyncCompletion)asyncWrapper:(NSString *)mechanism reqID:(NSString *)reqID completion:(NSURLSessionAsyncCompletion)completion {
    NSURLSessionAsyncCompletion wrapper = ^(id fileURLOrData, NSURLResponse *response, NSError *error) {
        [[URLInjectorRecorder recorder] recordMechanism:mechanism forRequestID:reqID];
        [[URLInjectorRecorder recorder] recordResponseReceivedWithRequestID:reqID response:response];
        NSData *data = nil;
        if ([fileURLOrData isKindOfClass:[NSURL class]]) {
            data = [NSData dataWithContentsOfURL:fileURLOrData];
        } else if ([fileURLOrData isKindOfClass:[NSData class]]) {
            data = fileURLOrData;
        }
        [[URLInjectorRecorder recorder] recordDataReceivedWithRequestID:reqID dataLength:data.length];
        if (error) {
            [[URLInjectorRecorder recorder] recordLoadingFailedWithRequestID:reqID error:error];
        } else {
            [[URLInjectorRecorder recorder] recordLoadingFinishedWithRequestID:reqID responseBody:data];
        }
        // Call through to the original completion handler
        if (completion) completion(fileURLOrData, response, error);
    };
    return wrapper;
}
/// 将要取消
- (void)connectionWillCancel:(NSURLConnection *)connection {
    [self performBlock:^{
        // Mimic the behavior of NSURLSession which is to create an error on cancellation.
        NSDictionary<NSString *, id> *userInfo = @{ NSLocalizedDescriptionKey : @"cancelled" };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
        [self connection:connection didFailWithError:error delegate:nil];
    }];
}
/// 将要恢复下载
- (void)sessionTaskWillResume:(NSURLSessionTask *)task {
    // Since resume can be called multiple times on the same task, only treat the first resume as
    // the equivalent to connection:willSendRequest:...
    [self performBlock:^{
        NSString *reqID = [self.class requestIDForTask:task];
        RequestPacket *packet =  [self requestPacket:reqID];
        if (!packet.request) {
            packet.request = task.currentRequest;
            [[URLInjectorRecorder recorder] recordRequestWillBeSentWithRequestID:reqID request:task.currentRequest redirectResponse:nil];
        }
    }];
}
/// 请求将要开始
- (void)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:connection];
        RequestPacket *packet =  [self requestPacket:reqID];
        packet.request = request;
        [[URLInjectorRecorder recorder] recordRequestWillBeSentWithRequestID:reqID request:request redirectResponse:response];
        NSString *mechanism = [NSString stringWithFormat:@"NSURLConnection (delegate: %@)", [delegate class]];
        [[URLInjectorRecorder recorder] recordMechanism:mechanism forRequestID:reqID];
    }];
}
/// 请求开始接受数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data delegate:(id<NSURLConnectionDelegate>)delegate {
    // Just to be safe since we're doing this async
    data = [data copy];
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:connection];
        RequestPacket *packet =  [self requestPacket:reqID];
        [packet.data appendData:data];
        [[URLInjectorRecorder recorder] recordDataReceivedWithRequestID:reqID dataLength:data.length];
    }];
}
///
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:connection];
        RequestPacket *packet =  [self requestPacket:reqID];
        NSMutableData *data = nil;
        if (response.expectedContentLength < 0) {
            data = [NSMutableData new];
        } else if (response.expectedContentLength < 52428800) {
            data = [[NSMutableData alloc] initWithCapacity:(NSUInteger)response.expectedContentLength];
        }
        packet.data = data;
        [[URLInjectorRecorder recorder] recordResponseReceivedWithRequestID:reqID response:response];
    }];
}
///
- (void)connectionDidFinishLoading:(NSURLConnection *)connection delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:connection];
        RequestPacket *packet =  [self requestPacket:reqID];
        [[URLInjectorRecorder recorder] recordLoadingFinishedWithRequestID:reqID responseBody:packet.data];
        [self removePacket:reqID];
    }];
}
///
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error delegate:(id<NSURLConnectionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:connection];
        RequestPacket *packet =  [self requestPacket:reqID];
        // Cancellations can occur prior to the willSendRequest:... NSURLConnection delegate call.
        // These are pretty common and clutter up the logs. Only record the failure if the recorder already knows about the request through willSendRequest:...
        if (packet.request) {
            [[URLInjectorRecorder recorder] recordLoadingFailedWithRequestID:reqID error:error];
        }
        [self removePacket:reqID];
    }];
}
///
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:task];
        [[URLInjectorRecorder recorder] recordRequestWillBeSentWithRequestID:reqID request:request redirectResponse:response];
    }];
}
///
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:dataTask];
        RequestPacket *packet =  [self requestPacket:reqID];

        NSMutableData *data = nil;
        if (response.expectedContentLength < 0) {
            data = [NSMutableData new];
        } else {
            data = [[NSMutableData alloc] initWithCapacity:(NSUInteger)response.expectedContentLength];
        }
        packet.data = data;
        NSString *requestMechanism = [NSString stringWithFormat:@"NSURLSessionDataTask (delegate: %@)", [delegate class]];
        [[URLInjectorRecorder recorder] recordMechanism:requestMechanism forRequestID:reqID];
        [[URLInjectorRecorder recorder] recordResponseReceivedWithRequestID:reqID response:response];
    }];
}
///
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        // By setting the request ID of the download task to match the data task,
        // it can pick up where the data task left off.
        NSString *reqID = [[self class] requestIDForTask:dataTask];
        [[self class] setReqID:reqID reqTtask:downloadTask];
    }];
}
///
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data delegate:(id<NSURLSessionDelegate>)delegate {
    // Just to be safe since we're doing this async
    data = [data copy];
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:dataTask];
        RequestPacket *packet =  [self requestPacket:reqID];
        [packet.data appendData:data];
        [[URLInjectorRecorder recorder] recordDataReceivedWithRequestID:reqID dataLength:data.length];
    }];
}
///
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:task];
        RequestPacket *packet =  [self requestPacket:reqID];
        if (error) {
            [[URLInjectorRecorder recorder] recordLoadingFailedWithRequestID:reqID error:error];
        } else {
            [[URLInjectorRecorder recorder] recordLoadingFinishedWithRequestID:reqID responseBody:packet.data];
        }
        [self removePacket:reqID];
    }];
}
///
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite delegate:(id<NSURLSessionDelegate>)delegate {
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:downloadTask];
        RequestPacket *packet =  [self requestPacket:reqID];
        if (!packet.data) {
            NSUInteger unsignedBytesExpectedToWrite = totalBytesExpectedToWrite > 0 ? (NSUInteger)totalBytesExpectedToWrite : 0;
            packet.data = [[NSMutableData alloc] initWithCapacity:unsignedBytesExpectedToWrite];
            [[URLInjectorRecorder recorder] recordResponseReceivedWithRequestID:reqID response:downloadTask.response];

            NSString *requestMechanism = [NSString stringWithFormat:@"NSURLSessionDownloadTask (delegate: %@)", [delegate class]];
            [[URLInjectorRecorder recorder] recordMechanism:requestMechanism forRequestID:reqID];
        }
        [[URLInjectorRecorder recorder] recordDataReceivedWithRequestID:reqID dataLength:bytesWritten];
    }];
}
///
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location data:(NSData *)data delegate:(id<NSURLSessionDelegate>)delegate {
    data = [data copy];
    [self performBlock:^{
        NSString *reqID = [[self class] requestIDForTask:downloadTask];
        RequestPacket *packet =  [self requestPacket:reqID];
        [packet.data appendData:data];
    }];
}

#pragma mark - INJECTOR
///=============================================================================
/// @name 注入 源自FLEX
///=============================================================================

+ (void)injectDelegateOnce {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self injectDelegate];
    });
}

+ (void)injectDelegate {
    const SEL selectors[] = {
        @selector(connectionDidFinishLoading:),
        @selector(connection:willSendRequest:redirectResponse:),
        @selector(connection:didReceiveResponse:),
        @selector(connection:didReceiveData:),
        @selector(connection:didFailWithError:),
        @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:),
        @selector(URLSession:dataTask:didReceiveData:),
        @selector(URLSession:dataTask:didReceiveResponse:completionHandler:),
        @selector(URLSession:task:didCompleteWithError:),
        @selector(URLSession:dataTask:didBecomeDownloadTask:),
        @selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:),
        @selector(URLSession:downloadTask:didFinishDownloadingToURL:)
    };
    const int numSelectors = sizeof(selectors) / sizeof(SEL);
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (NSInteger classIndex = 0; classIndex < numClasses; ++classIndex) {
            Class class = classes[classIndex];
            if (class == [URLInjector class]) continue;
            
            unsigned int methodCount = 0;
            Method *methods = class_copyMethodList(class, &methodCount);
            BOOL matchingSelectorFound = NO;
            for (unsigned int methodIndex = 0; methodIndex < methodCount; methodIndex++) {
                for (int selectorIndex = 0; selectorIndex < numSelectors; ++selectorIndex) {
                    if (method_getName(methods[methodIndex]) == selectors[selectorIndex]) {
                        [self injectIntoDelegateClass:class];
                        matchingSelectorFound = YES;
                        break;
                    }
                }
                if (matchingSelectorFound)  break;
            }
            free(methods);
        }
        free(classes);
    }
    
    [self injectConnectionCancel];
    [self injectSessionTaskResume];
    [self injectConnectionAsyncClassMethod];
    [self injectConnectionSyncClassMethod];

    [self injectSessionTaskAsyncMethods];
    [self injectSessionTaskAsyncUploadMethods];
}

///
+ (NSString *)requestBefore:(NSURLRequest *)request originSelector:(SEL)oriS class:(Class)class {
    NSString *reqID = [self uniqueID];
    [[URLInjectorRecorder recorder] recordRequestWillBeSentWithRequestID:reqID request:request redirectResponse:nil];
    NSString *mecha = [self mechanism:oriS cls:class];
    [[URLInjectorRecorder recorder] recordMechanism:mecha forRequestID:reqID];
    return reqID;
}

+ (void)requestAfter:(NSURLResponse *)response data:(NSData *)data error:(NSError *)err reqID:(NSString *)reqID {
    [[URLInjectorRecorder recorder] recordResponseReceivedWithRequestID:reqID response:response];
    [[URLInjectorRecorder recorder] recordDataReceivedWithRequestID:reqID dataLength:data.length];
    if (err) {
        [[URLInjectorRecorder recorder] recordLoadingFailedWithRequestID:reqID error:err];
    } else {
        [[URLInjectorRecorder recorder] recordLoadingFinishedWithRequestID:reqID responseBody:data];
    }
}

+ (void)injectConnectionCancel {
    Class class = [NSURLConnection class];
    SEL selector = @selector(cancel);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Method oriM = class_getInstanceMethod(class, selector);
    
    void (^block)(NSURLConnection *) = ^(NSURLConnection *slf) {
        [[URLInjector injector] connectionWillCancel:slf];
        ((void(*)(id, SEL))objc_msgSend)(slf, swiS);
    };
    urlMethodExchangeBlock(class, oriM, block, swiS);
}

+ (void)injectSessionTaskResume {
    // In iOS 7 resume lives in __NSCFLocalSessionTask
    // In iOS 8 resume lives in NSURLSessionTask
    // In iOS 9 resume lives in __NSCFURLSessionTask
    Class class = Nil;
    if (![NSProcessInfo.processInfo respondsToSelector:@selector(operatingSystemVersion)]) {
        class = NSClassFromString([@[@"__", @"NSC", @"FLocalS", @"ession", @"Task"] componentsJoinedByString:@""]);
    } else if ([NSProcessInfo.processInfo operatingSystemVersion].majorVersion < 9) {
        class = [NSURLSessionTask class];
    } else {
        class = NSClassFromString([@[@"__", @"NSC", @"FURLS", @"ession", @"Task"] componentsJoinedByString:@""]);
    }
    SEL selector = @selector(resume);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Method oriM = class_getInstanceMethod(class, selector);
    
    void (^block)(NSURLSessionTask *) = ^(NSURLSessionTask *slf) {
        [[URLInjector injector] sessionTaskWillResume:slf];
        ((void(*)(id, SEL))objc_msgSend)(slf, swiS);
    };
    urlMethodExchangeBlock(class, oriM, block, swiS);
}

+ (void)injectConnectionAsyncClassMethod {
    Class class = objc_getMetaClass(class_getName([NSURLConnection class]));
    SEL oriS = @selector(sendAsynchronousRequest:queue:completionHandler:);
    SEL swiS = [self swizzledSelectorForSelector:oriS];
    
    typedef void (^ConnectionAsyncCompletion)(NSURLResponse* response, NSData* data, NSError *connectionError);
    
    void (^block)(Class, NSURLRequest *, NSOperationQueue *, ConnectionAsyncCompletion) = ^(Class slf, NSURLRequest *request, NSOperationQueue *queue, ConnectionAsyncCompletion completion) {
        if ([URLInjector isEnabled]) {
            NSString *reqID = [URLInjector requestBefore:request originSelector:oriS class:class];
            ConnectionAsyncCompletion completionWrapper = ^(NSURLResponse *response, NSData *data, NSError *error) {
                [URLInjector requestAfter:response data:data error:error reqID:reqID];
                if (completion) completion(response, data, error);
            };
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, request, queue, completionWrapper);
        } else {
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, request, queue, completion);
        }
    };
    urlMethodExchangeKnown(class, oriS, block, swiS);
}

+ (void)injectConnectionSyncClassMethod {
    Class class = objc_getMetaClass(class_getName([NSURLConnection class]));
    SEL oriS = @selector(sendSynchronousRequest:returningResponse:error:);
    SEL swiS = [self swizzledSelectorForSelector:oriS];
    
    NSData *(^block)(Class, NSURLRequest *, NSURLResponse **, NSError **) = ^NSData *(Class slf, NSURLRequest *request, NSURLResponse **response, NSError **error) {
        NSData *data = nil;
        if ([self isEnabled]) {
            NSString *reqID = [self requestBefore:request originSelector:oriS class:class];
            NSError *err = nil;
            NSURLResponse *rep = nil;
            data = ((id(*)(id, SEL, id, NSURLResponse **, NSError **))objc_msgSend)(slf, swiS, request, &rep, &err);
            [self requestAfter:rep data:data error:err reqID:reqID];
            if (error) *error = err;
            if (response) *response = rep;
        } else {
            data = ((id(*)(id, SEL, id, NSURLResponse **, NSError **))objc_msgSend)(slf, swiS, request, response, error);
        }
        return data;
    };
    urlMethodExchangeKnown(class, oriS, block, swiS);
}

+ (void)injectSessionTaskAsyncMethods {
    Class class = [NSURLSession class];
    // The method signatures here are close enough that we can use the same logic to inject into all of them.
    const SEL selectors[] = {
        @selector(dataTaskWithRequest:completionHandler:),
        @selector(dataTaskWithURL:completionHandler:),
        @selector(downloadTaskWithRequest:completionHandler:),
        @selector(downloadTaskWithResumeData:completionHandler:),
        @selector(downloadTaskWithURL:completionHandler:)
    };
    
    const int numSelectors = sizeof(selectors) / sizeof(SEL);
    
    for (int selectorIndex = 0; selectorIndex < numSelectors; selectorIndex++) {
        SEL oriS = selectors[selectorIndex];
        SEL swiS = [self swizzledSelectorForSelector:oriS];
        
        if ([self respondsButNotImplementSelector:oriS class:class]) {
            // iOS 7 does not implement these methods on NSURLSession. We actually want to
            // swizzle __NSCFURLSession, which we can get from the class of the shared session
            class = [NSURLSession.sharedSession class];
        }
        
        NSURLSessionTask *(^block)(Class, id, NSURLSessionAsyncCompletion) = ^NSURLSessionTask *(Class slf, id argument, NSURLSessionAsyncCompletion completion) {
            NSURLSessionTask *task = nil;
            if ([self isEnabled] && completion) {
                NSString *reqID = [self uniqueID];
                NSString *mechanism = [self mechanism:oriS cls:class];
                NSURLSessionAsyncCompletion wrapper = [self asyncWrapper:mechanism reqID:reqID completion:completion];
                task = ((id(*)(id, SEL, id, id))objc_msgSend)(slf, swiS, argument, wrapper);
                [self setReqID:reqID reqTtask:task];
            } else {
                task = ((id(*)(id, SEL, id, id))objc_msgSend)(slf, swiS, argument, completion);
            }
            return task;
        };
        
        urlMethodExchangeKnown(class, oriS, block, swiS);
    }
}

+ (void)injectSessionTaskAsyncUploadMethods {
    Class class = [NSURLSession class];
    // The method signatures here are close enough that we can use the same logic to inject into both of them.
    // Note that they have 3 arguments, so we can't easily combine with the data and download method above.
    const SEL selectors[] = {
        @selector(uploadTaskWithRequest:fromData:completionHandler:),
        @selector(uploadTaskWithRequest:fromFile:completionHandler:)
    };
    const int numSelectors = sizeof(selectors) / sizeof(SEL);
    for (int selectorIndex = 0; selectorIndex < numSelectors; selectorIndex++) {
        SEL oriS = selectors[selectorIndex];
        SEL swiS = [self swizzledSelectorForSelector:oriS];
        
        if ([self respondsButNotImplementSelector:oriS class:class]) {
            // iOS 7 does not implement these methods on NSURLSession. We actually want to
            // swizzle __NSCFURLSession, which we can get from the class of the shared session
            class = [NSURLSession.sharedSession class];
        }
        
        NSURLSessionUploadTask *(^block)(Class, NSURLRequest *, id, NSURLSessionAsyncCompletion) = ^NSURLSessionUploadTask *(Class slf, NSURLRequest *request, id argument, NSURLSessionAsyncCompletion completion) {
            NSURLSessionUploadTask *task = nil;
            if ([self isEnabled] && completion) {
                NSString *reqID = [self uniqueID];
                NSString *mechanism = [self mechanism:oriS cls:class];
                NSURLSessionAsyncCompletion wrapper = [self asyncWrapper:mechanism reqID:reqID completion:completion];
                task = ((id(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, request, argument, wrapper);
                [self setReqID:reqID reqTtask:task];
            } else {
                task = ((id(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, request, argument, completion);
            }
            return task;
        };
        urlMethodExchangeKnown(class, oriS, block, swiS);
    }
}

#pragma mark - Delegate Injector
///=============================================================================
/// @name Delegate Injector
///=============================================================================

+ (void)injectIntoDelegateClass:(Class)cls {
    // Connections
    [self injectWillSendRequest:cls];
    [self injectDidReceiveData:cls];
    [self injectDidReceiveResponse:cls];
    [self injectDidFinishLoading:cls];
    [self injectDidFailWithError:cls];
    // Sessions
    [self injectTaskWillPerformHTTPRedirection:cls];
    [self injectTaskDidReceiveData:cls];
    [self injectTaskDidReceiveResponse:cls];
    [self injectTaskDidCompleteWithError:cls];
    [self injectRespondsToSelector:cls];
    // Data tasks
    [self injectDataTaskDidBecomeDownloadTask:cls];
    // Download tasks
    [self injectDownloadTaskDidWriteData:cls];
    [self injectDownloadTaskDidFinishDownloading:cls];
}

+ (void)injectWillSendRequest:(Class)cls {
    SEL selector = @selector(connection:willSendRequest:redirectResponse:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) protocol = @protocol(NSURLConnectionDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef NSURLRequest *(^NSURLConnectionWillSendRequestBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response);
    
    NSURLConnectionWillSendRequestBlock unBlock = ^NSURLRequest *(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response) {
        [[URLInjector injector] connection:connection willSendRequest:request redirectResponse:response delegate:slf];
        return request;
    };
    NSURLConnectionWillSendRequestBlock impBlock = ^NSURLRequest *(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLRequest *request, NSURLResponse *response) {
        __block NSURLRequest *returnValue = nil;
        [self sniff:connection selector:selector sniffingBlock:^{
            unBlock(slf, connection, request, response);
        } originBlock:^{
            returnValue = ((id(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, connection, request, response);
        }];
        return returnValue;
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectDidReceiveData:(Class)cls {
    SEL selector = @selector(connection:didReceiveData:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) protocol = @protocol(NSURLConnectionDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLConnectionDidReceiveDataBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSData *data);
    
    NSURLConnectionDidReceiveDataBlock unBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSData *data) {
        [[URLInjector injector] connection:connection didReceiveData:data delegate:slf];
    };
    NSURLConnectionDidReceiveDataBlock impBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSData *data) {
        [self sniff:connection selector:selector sniffingBlock:^{
            unBlock(slf, connection, data);
        } originBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(slf, swiS, connection, data);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectDidReceiveResponse:(Class)cls {
    SEL selector = @selector(connection:didReceiveResponse:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) protocol = @protocol(NSURLConnectionDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLConnectionDidReceiveResponseBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLResponse *response);
    
    NSURLConnectionDidReceiveResponseBlock unBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLResponse *response) {
        [[URLInjector injector] connection:connection didReceiveResponse:response delegate:slf];
    };
    NSURLConnectionDidReceiveResponseBlock impBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSURLResponse *response) {
        [self sniff:connection selector:selector sniffingBlock:^{
            unBlock(slf, connection, response);
        } originBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(slf, swiS, connection, response);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectDidFinishLoading:(Class)cls {
    SEL selector = @selector(connectionDidFinishLoading:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSURLConnectionDataDelegate);
    if (!protocol) protocol = @protocol(NSURLConnectionDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLConnectionDidFinishLoadingBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection);
    
    NSURLConnectionDidFinishLoadingBlock unBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection) {
        [[URLInjector injector] connectionDidFinishLoading:connection delegate:slf];
    };
    NSURLConnectionDidFinishLoadingBlock impBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection) {
        [self sniff:connection selector:selector sniffingBlock:^{
            unBlock(slf, connection);
        } originBlock:^{
            ((void(*)(id, SEL, id))objc_msgSend)(slf, swiS, connection);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectDidFailWithError:(Class)cls {
    SEL selector = @selector(connection:didFailWithError:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSURLConnectionDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLConnectionDidFailWithErrorBlock)(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSError *error);
    
    NSURLConnectionDidFailWithErrorBlock unBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSError *error) {
        [[URLInjector injector] connection:connection didFailWithError:error delegate:slf];
    };
    NSURLConnectionDidFailWithErrorBlock impBlock = ^(id <NSURLConnectionDelegate> slf, NSURLConnection *connection, NSError *error) {
        [self sniff:connection selector:selector sniffingBlock:^{
            unBlock(slf, connection, error);
        } originBlock:^{
            ((void(*)(id, SEL, id, id))objc_msgSend)(slf, swiS, connection, error);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectTaskWillPerformHTTPRedirection:(Class)cls {
    SEL selector = @selector(URLSession:task:willPerformHTTPRedirection:newRequest:completionHandler:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    
    typedef void (^NSURLSessionWillPerformHTTPRedirectionBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSHTTPURLResponse *response, NSURLRequest *newRequest, void(^completionHandler)(NSURLRequest *));
    
    NSURLSessionWillPerformHTTPRedirectionBlock unBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSHTTPURLResponse *response, NSURLRequest *newRequest, void(^completionHandler)(NSURLRequest *)) {
        [[URLInjector injector] URLSession:session task:task willPerformHTTPRedirection:response newRequest:newRequest completionHandler:completionHandler delegate:slf];
        completionHandler(newRequest);
    };
    NSURLSessionWillPerformHTTPRedirectionBlock impBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSHTTPURLResponse *response, NSURLRequest *newRequest, void(^completionHandler)(NSURLRequest *)) {
        [self sniff:task selector:selector sniffingBlock:^{
            [[URLInjector injector] URLSession:session task:task willPerformHTTPRedirection:response newRequest:newRequest completionHandler:completionHandler delegate:slf];
        } originBlock:^{
            ((id(*)(id, SEL, id, id, id, id, void(^)(NSURLRequest *)))objc_msgSend)(slf, swiS, session, task, response, newRequest, completionHandler);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectTaskDidReceiveData:(Class)cls {
    SEL selector = @selector(URLSession:dataTask:didReceiveData:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLSessionDidReceiveDataBlock)(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
    
    NSURLSessionDidReceiveDataBlock unBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        [[URLInjector injector] URLSession:session dataTask:dataTask didReceiveData:data delegate:slf];
    };
    NSURLSessionDidReceiveDataBlock impBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data) {
        [self sniff:dataTask selector:selector sniffingBlock:^{
            unBlock(slf, session, dataTask, data);
        } originBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, session, dataTask, data);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectDataTaskDidBecomeDownloadTask:(Class)cls {
    SEL selector = @selector(URLSession:dataTask:didBecomeDownloadTask:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLSessionDidBecomeDownloadTaskBlock)(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask);
    
    NSURLSessionDidBecomeDownloadTaskBlock unBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask) {
        [[URLInjector injector] URLSession:session dataTask:dataTask didBecomeDownloadTask:downloadTask delegate:slf];
    };
    NSURLSessionDidBecomeDownloadTaskBlock impBlock = ^(id <NSURLSessionDataDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask) {
        [self sniff:dataTask selector:selector sniffingBlock:^{
            unBlock(slf, session, dataTask, downloadTask);
        } originBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, session, dataTask, downloadTask);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectTaskDidReceiveResponse:(Class)cls {
    SEL selector = @selector(URLSession:dataTask:didReceiveResponse:completionHandler:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSURLSessionDataDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLSessionDidReceiveResponseBlock)(id <NSURLSessionDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response, void(^completionHandler)(NSURLSessionResponseDisposition disposition));
    
    NSURLSessionDidReceiveResponseBlock unBlock = ^(id <NSURLSessionDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response, void(^completionHandler)(NSURLSessionResponseDisposition disposition)) {
        [[URLInjector injector] URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler delegate:slf];
        completionHandler(NSURLSessionResponseAllow);
    };
    NSURLSessionDidReceiveResponseBlock impBlock = ^(id <NSURLSessionDelegate> slf, NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response, void(^completionHandler)(NSURLSessionResponseDisposition disposition)) {
        [self sniff:dataTask selector:selector sniffingBlock:^{
            [[URLInjector injector] URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler delegate:slf];
        } originBlock:^{
            ((void(*)(id, SEL, id, id, id, void(^)(NSURLSessionResponseDisposition)))objc_msgSend)(slf, swiS, session, dataTask, response, completionHandler);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectTaskDidCompleteWithError:(Class)cls {
    SEL selector = @selector(URLSession:task:didCompleteWithError:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    Protocol *protocol = @protocol(NSURLSessionTaskDelegate);
    
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLSessionTaskDidCompleteWithErrorBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSError *error);
    
    NSURLSessionTaskDidCompleteWithErrorBlock unBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSError *error) {
        [[URLInjector injector] URLSession:session task:task didCompleteWithError:error delegate:slf];
    };
    NSURLSessionTaskDidCompleteWithErrorBlock impBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionTask *task, NSError *error) {
        [self sniff:task selector:selector sniffingBlock:^{
            unBlock(slf, session, task, error);
        } originBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, session, task, error);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectRespondsToSelector:(Class)cls {
    // Used for overriding AFNetworking behavior
    SEL selector = @selector(respondsToSelector:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    
    Method method = class_getInstanceMethod(cls, selector);
    struct objc_method_description methodD = *method_getDescription(method);
    
    BOOL (^unBlock)(id <NSURLSessionTaskDelegate>, SEL) = ^(id slf, SEL sel) {
        return YES;
    };
    BOOL (^impBlock)(id <NSURLSessionTaskDelegate>, SEL) = ^(id <NSURLSessionTaskDelegate> slf, SEL sel) {
        if (sel == @selector(URLSession:dataTask:didReceiveResponse:completionHandler:)) {
            return unBlock(slf, sel);
        }
        return ((BOOL(*)(id, SEL, SEL))objc_msgSend)(slf, swiS, sel);
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectDownloadTaskDidWriteData:(Class)cls {
    SEL selector = @selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionDownloadDelegate);
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLSessionDownloadTaskDidWriteDataBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
    
    NSURLSessionDownloadTaskDidWriteDataBlock unBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        [[URLInjector injector] URLSession:session downloadTask:task didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite delegate:slf];
    };
    NSURLSessionDownloadTaskDidWriteDataBlock impBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        [self sniff:task selector:selector sniffingBlock:^{
            unBlock(slf, session, task, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        } originBlock:^{
            ((void(*)(id, SEL, id, id, int64_t, int64_t, int64_t))objc_msgSend)(slf, swiS, session, task, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

+ (void)injectDownloadTaskDidFinishDownloading:(Class)cls {
    SEL selector = @selector(URLSession:downloadTask:didFinishDownloadingToURL:);
    SEL swiS = [self swizzledSelectorForSelector:selector];
    
    Protocol *protocol = @protocol(NSURLSessionDownloadDelegate);
    struct objc_method_description methodD = protocol_getMethodDescription(protocol, selector, NO, YES);
    typedef void (^NSURLSessionDownloadTaskDidFinishDownloadingBlock)(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, NSURL *location);
    
    NSURLSessionDownloadTaskDidFinishDownloadingBlock unBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, NSURL *location) {
        NSData *data = [NSData dataWithContentsOfFile:location.relativePath];
        [[URLInjector injector] URLSession:session task:task didFinishDownloadingToURL:location data:data delegate:slf];
    };
    NSURLSessionDownloadTaskDidFinishDownloadingBlock impBlock = ^(id <NSURLSessionTaskDelegate> slf, NSURLSession *session, NSURLSessionDownloadTask *task, NSURL *location) {
        [self sniff:task selector:selector sniffingBlock:^{
            unBlock(slf, session, task, location);
        } originBlock:^{
            ((void(*)(id, SEL, id, id, id))objc_msgSend)(slf, swiS, session, task, location);
        }];
    };
    [self methodExchange:selector swizzledSelector:swiS class:cls methodDescription:methodD implementationBlock:impBlock undefinedBlock:unBlock];
}

#pragma mark - EXTERN
///=============================================================================
/// @name EXTERN
///=============================================================================

+ (NSString *)uniqueID {
    return [[NSUUID UUID] UUIDString];
}

+ (SEL)swizzledSelectorForSelector:(SEL)selector {
    return NSSelectorFromString([NSString stringWithFormat:@"_debugger_swizzle_%x_%@", arc4random(), NSStringFromSelector(selector)]);
}

+ (NSString *)mechanism:(SEL)selector cls:(Class)cls {
    return [NSString stringWithFormat:@"+[%@ %@]", NSStringFromClass(cls), NSStringFromSelector(selector)];
}

+ (void)sniff:(NSObject *)obj selector:(SEL)selector sniffingBlock:(void (^)(void))sniffingBlock originBlock:(void (^)(void))originBlock {
    if (!obj) {
        originBlock();
        return;
    }
    const void *key = selector;
    // Don't run the sniffing block if we're inside a nested call
    if (!objc_getAssociatedObject(obj, key)) {
        sniffingBlock();
    }
    // Mark that we're calling through to the original so we can detect nested calls
    objc_setAssociatedObject(obj, key, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    originBlock();
    objc_setAssociatedObject(obj, key, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)respondsButNotImplementSelector:(SEL)selector class:(Class)cls {
    if ([cls instancesRespondToSelector:selector]) {
        unsigned int numMethods = 0;
        Method *methods = class_copyMethodList(cls, &numMethods);
        BOOL implementsSelector = NO;
        for (int index = 0; index < numMethods; index++) {
            SEL methodSelector = method_getName(methods[index]);
            if (selector == methodSelector) {
                implementsSelector = YES;
                break;
            }
        }
        free(methods);
        if (!implementsSelector) return YES;
    }
    return NO;
}

+ (void)methodExchange:(SEL)selector swizzledSelector:(SEL)swiS class:(Class)cls methodDescription:(struct objc_method_description)methodD implementationBlock:(id)impBlock undefinedBlock:(id)unBlock {
    if ([self respondsButNotImplementSelector:selector class:cls]) return;
    
    IMP imp = imp_implementationWithBlock((id)([cls instancesRespondToSelector:selector] ? impBlock : unBlock));
    Method oriM = class_getInstanceMethod(cls, selector);
    if (oriM) {
        class_addMethod(cls, swiS, imp, methodD.types);
        Method siwM = class_getInstanceMethod(cls, swiS);
        method_exchangeImplementations(oriM, siwM);
    } else {
        class_addMethod(cls, selector, imp, methodD.types);
    }
}

+ (NSString *)requestIDForTask:(id)task {
    NSString *reqID = objc_getAssociatedObject(task, kURLInjectorRequestIDKey);
    if (!reqID) {
        reqID = [self uniqueID];
        [self setReqID:reqID reqTtask:task];
    }
    return reqID;
}

+ (void)setReqID:(NSString *)requestID reqTtask:(id)reqTtask {
    objc_setAssociatedObject(reqTtask, kURLInjectorRequestIDKey, requestID, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
