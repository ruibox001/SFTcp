//
//  UdpSocket.m
//  SmartHome3.0
//
//  Created by 王声远 on 15/6/27.
//  Copyright (c) 2015年 anody. All rights reserved.
//

#import "TcpSocket.h"
#import "GCDAsyncSocket.h"

#define tcpSocketMaxReconnectTimes 3
#define tcpSocketReconnectSleepTimes 20

@interface TcpSocket()<GCDAsyncSocketDelegate>

@property (nonatomic,strong) GCDAsyncSocket *mSocket;
@property (nonatomic,strong) NSString *host;
@property (nonatomic,assign) int port;
@property (nonatomic,assign,getter=isConnect) BOOL connect;
@property (nonatomic,assign) NSInteger reconnectTimes;

//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation TcpSocket

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static TcpSocket *udpInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        udpInstance = [super allocWithZone:zone];
    });
    return udpInstance;
}

+ (instancetype) shareTcpSocket
{
    return [[self alloc] init];
}

#pragma mark - 初始化网络
- (GCDAsyncSocket *)mSocket
{
    if (!_mSocket) {
        _mSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue() socketQueue:dispatch_queue_create("com.sinllia", DISPATCH_QUEUE_SERIAL)];
    }
    return _mSocket;
}

#pragma mark - 连接host和port
- (void)connect:(NSString *)host port:(int)port {
    self.host = host;
    self.port = port;
    self.reconnectTimes = 0;
    [self reConnect];
}

#pragma mark - 断开连接
- (void)disConnect {
    [self.mSocket disconnect];
    self.reconnectTimes = 0;
    self.connect = NO;
}

#pragma mark - 是否连接
- (BOOL)isConnected {
    return self.isConnect;
}

#pragma mark - 发生数据
- (void)sendData:(NSData *)data {
    if(self.isConnect) {
        [self.mSocket writeData:data withTimeout:0 tag:0];
    }
}

- (void)sendString:(NSString *)string {
    if(self.isConnect) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        [self.mSocket writeData:data withTimeout:0 tag:0];
    }
}

#pragma mark - 重新链接
- (void)reConnect {
    if (!self.isConnect) {
        NSError *error = nil;
        if(![self.mSocket connectToHost:self.host onPort:self.port withTimeout:10 error:&error]){
            SLOG(@"connect error = %@",error);
        }
    }
}

#pragma mark - 链接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    SLOG(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    // Backgrounding doesn't seem to be supported on the simulator yet
    self.connect = YES;
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(tcpSocket:connectStatus:)]) {
            [delegate tcpSocket:self connectStatus:self.connect];
        }
    }
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    SLOG(@"didWriteDataWithTag: %ld", tag);
}

#pragma - mark - 读取数据成功
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SLOG(@"收到数据:\n%@", msg);
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(tcpSocket:receverData:)]) {
            [delegate tcpSocket:self receverData:msg];
        }
    }
    [sock readDataWithTimeout:-1 tag:tag];
}

#pragma - mark - 连接断开
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    SLOG(@"socketDidDisconnect:%p withError: %@ ->> times: %ld", sock, err,self.reconnectTimes);
    self.connect = NO;
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(tcpSocket:connectStatus:)]) {
            [delegate tcpSocket:self connectStatus:self.connect];
        }
    }
    if (!err) {
        SLOG(@"主动断开链接了");
        return;
    }
    
    self.reconnectTimes ++;
    if (self.reconnectTimes < tcpSocketMaxReconnectTimes) {
        [self reConnect];
        SLOG(@"小于%d次重连",tcpSocketMaxReconnectTimes);
    }
    else {
        SLOG(@"大于%d次延迟：%d",tcpSocketMaxReconnectTimes,tcpSocketReconnectSleepTimes);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(tcpSocketReconnectSleepTimes * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SLOG(@"延迟：%d到重新连接",tcpSocketReconnectSleepTimes);
            self.reconnectTimes = 0;
            [self reConnect];
        });
    }
}

- (NSMutableArray *)delegates
{
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

#pragma mark - 添加代理
- (void)addDelegate:(id<TcpSocketDelegate>)delegate
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

#pragma mark - 移除代理
- (void)removeDelegate:(id<TcpSocketDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

@end
