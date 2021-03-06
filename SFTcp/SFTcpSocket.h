//
//  UdpSocket.h
//  SmartHome3.0
//
//  Created by 王声远 on 15/6/27.
//  Copyright (c) 2015年 anody. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketBgAutoHandler.h"

//公用日志打印LOG
#ifdef DEBUG
#define HYString [NSString stringWithFormat:@"%s", __FILE__].lastPathComponent
#define SLOG(...) printf("%s 第%d行: %s\n", [HYString UTF8String] ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define SLOG(...)
#endif

@class SFTcpSocket;

#pragma mark - 代理定义
@protocol SFTcpSocketDelegate <NSObject>
@optional

#pragma mark - 代理收到数据回调
- (void)tcpSocket:(SFTcpSocket *)udpSocket receverData:(NSString *)data;

#pragma mark - 代理连接状态变化回调
- (void)tcpSocket:(SFTcpSocket *)udpSocket connectStatus:(BOOL)connect;

@end

@interface SFTcpSocket : NSObject

#pragma mark - 处理类
@property (nonatomic, strong) SocketBgAutoHandler *handle;

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
- (void)addDelegate:(id<SFTcpSocketDelegate>)delegate;

#pragma mark - 移除代理
- (void)removeDelegate:(id<SFTcpSocketDelegate>)delegate;

@end
