//
//  GSocket.h
//  Debugger
//
//  Created by iOS_Developer_G on 2019/9/12.
//

#import <Foundation/Foundation.h>
@class WebSocket;
@class GCDAsyncSocket;
NS_ASSUME_NONNULL_BEGIN

@interface GSocket : NSObject
///> Socket:  
@property (nonatomic, strong) WebSocket *webSocket;

+ (instancetype)socket;
+ (GCDAsyncSocket *)asyncSocket;
+ (void)startConnect;
+ (BOOL)sendMessage:(NSString *)msg;
@end

NS_ASSUME_NONNULL_END
