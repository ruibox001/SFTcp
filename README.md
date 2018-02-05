# SFTcp
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/ibireme/YYKit/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/YYKit.svg?style=flat)](http://cocoadocs.org/docsets/YYKit)&nbsp;
[![Build Status](https://travis-ci.org/ibireme/YYKit.svg?branch=master)](https://travis-ci.org/ibireme/YYKit)

iOSTcp连接库：<br>
  >1、封装Tcp连接<br>
  >2、自动重连<br>
  >3、IPV6支持<br>
  >4、实例导读<br>

</p>

---

封装了Tcp请求类，使用方便，源码开放

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
    
# 安装

###  CocoaPods

        1. 在 `Podfile` 中添加 `pod 'SFTcp'`
        2. 执行 `pod install` 或 `pod update`

### 手动安装

        1. 下载`SFTcp`文件夹内的所有内容。
        2. 将`SFTcp`内的源文件添加(拖放)到你的工程。
