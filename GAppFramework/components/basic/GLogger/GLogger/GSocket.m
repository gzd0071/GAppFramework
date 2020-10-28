//
//  GSocket.m
//  Debugger
//
//  Created by iOS_Developer_G on 2019/9/12.
//

#import "GSocket.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <CocoaHTTPServer/WebSocket.h>
#import "Logger.h"

@interface GSocket ()<GCDAsyncSocketDelegate>
///> Socket: 连接 
@property (nonatomic, assign) BOOL connected;
///> Socket: Socket 
@property (nonatomic, strong) GCDAsyncSocket *socket;
///> Socket: 心跳 
@property (nonatomic, strong) NSTimer *timer;
///> Socket:  
@property (nonatomic, strong) NSMutableArray *historys;
@end

@implementation GSocket

+ (instancetype)socket {
    static GSocket *socket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socket = [GSocket new];
        socket.historys = [NSMutableArray array];
    });
    return socket;
}

+ (GCDAsyncSocket *)asyncSocket {
    return [GSocket socket].socket;
}

+ (void)startConnect {
    [[GSocket socket] startConnect];
}

+ (BOOL)sendMessage:(NSString *)str {
    return [[GSocket socket] sendMessage:str];
}

- (void)startConnect {
    if (self.connected) { LOGI(@"[ASocket] => Connected."); return; }
    
    LOGI(@"[ASocket] => Start.");
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    NSError *err = nil;
    uint16_t port = 3004;
    NSString *host = @"";
    [self.socket connectToHost:@"10.216.102.139" onPort:port error:&err];
    if (!err) return;
    LOGI(@"[ASocket] => Connect to host(%@:%li) failed, error:%@.", host, port, err);
}

- (void)disconnect {
    [self.socket disconnect];
    if (self.timer) [self.timer fire];
    self.timer = nil;
    LOGI(@"[ASocket] => Disconnect.");
}

#pragma mark - GCDAsyncSocketDelegate
///=============================================================================
/// @name GCDAsyncSocketDelegate
///=============================================================================

///> 回调: 连接成功 
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.connected = YES;
    LOGI(@"[ASocket] => Connect to host(%@:%li) Success.", host, port);
    id mes = [NSString stringWithFormat:@"[ASocket] => %@ connected.", [UIDevice currentDevice].name];
    [self sendMessage:mes];
    [self addTimer];
}

///> 回调: 连接失败 
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    LOGI(@"[ASocket] => Connect err:%@", err);
}

///> 回调: write成功? 
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    [self.socket readDataWithTimeout:-1 tag:tag];
}

///> 回调: 接收消息 
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
}

#pragma mark - Heart Connection
///=============================================================================
/// @name Heart Connection
///=============================================================================

- (void)addTimer {
    if (self.timer) return;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(longHeartSocket) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)longHeartSocket {
    LOGV(@"[ASocket] => 心跳.");
    [self sendMessage:@"[ASocket] => Heart beat."];
}

#pragma mark - Send Data
///=============================================================================
/// @name Send Data
///=============================================================================

- (void)setWebSocket:(WebSocket *)webSocket {
    _webSocket = webSocket;
    if (self.historys.count==0) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *his = self.historys.copy;
        self.historys = @[].mutableCopy;
        [his enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.webSocket sendMessage:obj];
        }];
    });
}

- (BOOL)sendMessage:(NSString *)str {
    if (!self.webSocket) {
        [self.historys addObject:str];
    } else {
        [self.webSocket sendMessage:str];
    }
    
    if (!self.connected) return NO;
    if (!str || ![str isKindOfClass:NSString.class] || str.length==0) return NO;
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:0];
    return YES;
}

@end
