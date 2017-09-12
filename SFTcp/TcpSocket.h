//
//  UdpSocket.h
//  SmartHome3.0
//
//  Created by 王声远 on 15/6/27.
//  Copyright (c) 2015年 anody. All rights reserved.
//

#import <Foundation/Foundation.h>

//公用日志打印LOG
#ifdef DEBUG
#define HYString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define SLOG(...) printf("%s 第%d行: %s\n", [HYString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define SLOG(...)
#endif

@class TcpSocket;

@protocol TcpSocketDelegate <NSObject>
@optional

- (void)tcpSocket:(TcpSocket *)udpSocket receverData:(NSString *)data;
- (void)tcpSocket:(TcpSocket *)udpSocket connectStatus:(BOOL)connect;

@end

@interface TcpSocket : NSObject

#pragma mark - tcp单利
+ (instancetype) shareTcpSocket;

#pragma mark - 连接到服务器
- (void)connect:(NSString *)host port:(int)port;

#pragma mark - 端开连接
- (void)disConnect;

#pragma mark - 是否正在连接
- (BOOL)isConnected;

#pragma mark - 重新连接
- (void)reConnect;

#pragma mark - 发送数据
- (void)sendData:(NSData *)data;
- (void)sendString:(NSString *)string;

#pragma mark - 添加代理
- (void)addDelegate:(id<TcpSocketDelegate>)delegate;

#pragma mark - 移除代理
- (void)removeDelegate:(id<TcpSocketDelegate>)delegate;

@end
