//
//  DHttpServer.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/9/12.
//

#import "DHttpServer.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <GLogger/Logger.h>
#import <GLogger/GSocket.h>
#import <GBaseLib/GConvenient.h>
#import <DMEncrypt/DMEncrypt.h>
#import <SSZipArchive/SSZipArchive.h>
#import <CocoaHTTPServer/WebSocket.h>
#import <CocoaHTTPServer/HTTPServer.h>
#import <CocoaHTTPServer/HTTPMessage.h>
#import <CocoaHTTPServer/HTTPConnection.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <CocoaHTTPServer/HTTPDataResponse.h>
#import <CocoaHTTPServer/MultipartFormDataParser.h>
#import <CocoaHTTPServer/HTTPDynamicFileResponse.h>
#import <CocoaHTTPServer/MultipartMessageHeaderField.h>
#import "AServerFileHandlers.h"
#import <YYKit/NSDictionary+YYAdd.h>
#import <GConst/HTMLConst.h>

#define kUPLOAD_PATH_NAME @"Documents/upload"
#define kUPLOAD_PATH      [NSHomeDirectory() stringByAppendingPathComponent:kUPLOAD_PATH_NAME]

@interface DHttpServer ()
///> Server: 架设服务器
@property (nonatomic, strong) HTTPServer *server;
///> Socket:
@property (nonatomic, weak)   WebSocket *socket;
///> Reuqest
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDictionary *(^)(NSString *path)> *reuqests;
@end

@implementation DHttpServer

+ (instancetype)server {
    static DHttpServer *server;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        server = [DHttpServer new];
        server.reuqests = @{}.mutableCopy;
    });
    return server;
}

#pragma mark - Server Logic
///=============================================================================
/// @name Server Logic
///=============================================================================

+ (void)startServer {
    [[DHttpServer server] startServer];
}

+ (void)addGetRequest:(NSString *)path result:(NSDictionary * _Nonnull (^)(NSString * _Nonnull))result {
    [DHttpServer server].reuqests[path] = result;
}

- (instancetype)init {
    if (self = [super init]) {
        self.server = [HTTPServer new];
        self.server.type = @"_http._tcp.";
        [self.server setPort:15151];
        [self.server setConnectionClass:NSClassFromString(@"DHTTPConnection")];
        [self.server setDocumentRoot:[[NSBundle mainBundle] bundlePath]];
    }
    return self;
}

- (void)startServer {
    NSError *err;
    [self.server start:&err];
    if (!err) {
        LOGI(@"[HServer] => Started on %@:%hu.", [self.class getIPAddress:YES], [self.server listeningPort]);
    } else {
        LOGE(@"[HServer] => Error starting HTTP server: %@", err);
    }
}

#pragma mark - Websocket Logic
///=============================================================================
/// @name Websocket Logic
///=============================================================================

- (void)updateSocket:(WebSocket *)socket {
    self.socket = socket;
    [GSocket socket].webSocket = socket;
}

- (void)sendMessage:(NSString *)msg {
    if (!self.socket) return;
    
    [self.socket sendMessage:msg];
}

#pragma mark - IP
///=============================================================================
/// @name IP
///=============================================================================

+ (NSString *)getIPPort {
    return FORMAT(@"http://%@:%hu", [self getIPAddress:YES], [DHttpServer server].server.listeningPort);
}

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         if([self isValidatIP:address]) *stop = YES;
     }];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) return NO;
    
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:nil];
    if (!regex) return NO;
    return [regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

@end

// MARK: DHTTPConnection
////////////////////////////////////////////////////////////////////////////////
/// @@class DHTTPConnection
////////////////////////////////////////////////////////////////////////////////

@interface DHTTPConnection : HTTPConnection<MultipartFormDataParserDelegate> {
    NSFileHandle   *storeFile;
    NSMutableArray *uploadedFiles;
    MultipartFormDataParser *parser;
}
@end
@implementation DHTTPConnection

#pragma mark - TRANSFER TYPE
///=============================================================================
/// @name TRANSFER TYPE
///=============================================================================
/// 文件上传
- (BOOL)fileUpload:(NSString *)method path:(NSString *)path {
    return [method isEqualToString:@"POST"] && [path hasPrefix:@"/uploadDek"];
}
/// Socket
- (BOOL)socket:(NSString *)method path:(NSString *)path {
    return [path hasPrefix:@"/main."] && [path hasSuffix:@".chunk.js"];
}

#pragma mark - FILE UPLOAD
///=============================================================================
/// @name FILE UPLOAD
///=============================================================================

- (BOOL)fileUploadExpectsRequestBody:(NSString *)method path:(NSString *)path {
    NSString *ct  = [request headerField:@"Content-Type"];
    NSUInteger sl = [ct rangeOfString:@";"].location;
    if (sl == NSNotFound || sl >= ct.length - 1) {
        return NO;
    }
    NSString *type = [ct substringToIndex:sl];
    if (![type isEqualToString:@"multipart/form-data"]) {
        return NO;
    }
    NSArray *params = [[ct substringFromIndex:sl+1] componentsSeparatedByString:@";"];
    for (NSString *param in params) {
        sl = [param rangeOfString:@"="].location;
        if (sl == NSNotFound || sl >= ct.length - 1) continue;
        
        NSString *pn = [param substringWithRange:NSMakeRange(1, sl-1)];
        NSString *pv = [param substringFromIndex:sl+1];
        if ([pn isEqualToString:@"boundary"]) {
            [request setHeaderField:@"boundary" value:pv];
        }
    }
    return [request headerField:@"boundary"];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength {
    NSString *boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    uploadedFiles = [NSMutableArray new];
}

- (void)processBodyData:(NSData *)postDataChunk {
    [parser appendData:postDataChunk];
}

#pragma mark - MultipartFormDataParserDelegate
///=============================================================================
/// @name MultipartFormDataParserDelegate
///=============================================================================

- (NSString *)getFileName:(MultipartMessageHeader *)header {
    MultipartMessageHeaderField *dis = [header.fields objectForKey:@"Content-Disposition"];
    return [[dis.params objectForKey:@"filename"] lastPathComponent];
}

- (void)processStartOfPartWithHeader:(MultipartMessageHeader *)header {
    NSString *filename = [self getFileName:header];
    if (nil == filename || [filename isEqualToString: @""]) return;
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:kUPLOAD_PATH isDirectory:&isDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kUPLOAD_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [kUPLOAD_PATH stringByAppendingPathComponent:filename];
    NSString *subpath = FORMAT(@"%@/%@", kUPLOAD_PATH_NAME, filename);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        LOGV(@"[HServer] => Dek file remove Failed: %@.", subpath);
        storeFile = nil;
    } else {
        LOGV(@"[HServer] => Saving Dek file to %@", subpath);
        if(![[NSFileManager defaultManager] createDirectoryAtPath:kUPLOAD_PATH withIntermediateDirectories:true attributes:nil error:nil]) {
            LOGV(@"[HServer] => Could not create directory at path: %@", subpath);
        }
        if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
            LOGV(@"[HServer] => Could not create file at path: %@", subpath);
        }
        storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [uploadedFiles addObject:[NSString stringWithFormat:@"%@", filename]];
    }
}

- (void)processContent:(NSData *)data WithHeader:(MultipartMessageHeader *)header {
    if (!storeFile) return;
    [storeFile writeData:data];
}

- (void)processEndOfPartWithHeader:(MultipartMessageHeader *)header {
    if (storeFile) {
        LOGV(@"[HServer] => Saving Dek file success");
        [AServerFileHandlers handleFile:[self getFileName:header] path:kUPLOAD_PATH];
    }
    [storeFile closeFile];
    storeFile = nil;
}

#pragma mark - SOCKET
///=============================================================================
/// @name SOCKET
///=============================================================================

- (NSObject<HTTPResponse> *)socketHttpResponse:(NSString *)method path:(NSString *)path {
    NSString *host = [request headerField:@"Host"] ?: FORMAT(@"localhost:%hu", [asyncSocket localPort]);
    NSDictionary *rd = @{@"WEBSOCKET_URL":FORMAT(@"ws://%@/service", host)};
    return [[HTTPDynamicFileResponse alloc] initWithFilePath:[self filePathForURI:path]
                                               forConnection:self
                                                   separator:@"%%"
                                       replacementDictionary:rd];
}

#pragma mark - Delegate
///=============================================================================
/// @name Delegate
///=============================================================================
/// 请求类型
- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path {
    if ([self fileUpload:method path:path]) {
        return YES;
    }
    return [super supportsMethod:method atPath:path];
}
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path {
    if ([self fileUpload:method path:path]) {
        return [self fileUploadExpectsRequestBody:method path:path];
    }
    return [super expectsRequestBodyFromMethod:method atPath:path];
}
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path {
    NSURL *url = [NSURL URLWithString:path];
    if ([url.path hasPrefix:@"/main."] && [url.path hasSuffix:@".chunk.js"]) {
        return [self socketHttpResponse:method path:path];
    } else if ([[DHttpServer server].reuqests containsObjectForKey:url.path]) {
        id result = [DHttpServer server].reuqests[url.path](path);
        return [[HTTPDataResponse alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result options:0 error:nil]];
    }
    return [super httpResponseForMethod:method URI:path];
}
- (WebSocket *)webSocketForURI:(NSString *)path {
    if ([path isEqualToString:@"/service"]) {
        WebSocket *socket = [[WebSocket alloc] initWithRequest:request socket:asyncSocket];
        [[DHttpServer server] updateSocket:socket];
        return socket;
    }
    return [super webSocketForURI:path];
}
@end
