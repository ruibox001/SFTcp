////
////  UIResponder+SFAppBackgroupView.m
////  SofficeMoi
////
////  Created by wangshengyuan on 17/2/8.
////  Copyright © 2017年 Soffice. All rights reserved.
////

#import "SocketBgAutoHandler.h"
#import <objc/runtime.h>
#import "SFTcpSocket.h"
#import <UIKit/UIKit.h>

@implementation SocketBgAutoHandler

//默认创建类别时自动调用
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        Class class = [[UIApplication sharedApplication].delegate class];
        if (class) {
            [self exchangeInstanceMethodWithOrigin:(class) sel:@selector(applicationDidEnterBackground:) nSel:@selector(socket_applicationDidEnterBackground:)];
            [self exchangeInstanceMethodWithOrigin:(class) sel:@selector(applicationWillEnterForeground:) nSel:@selector(socket_applicationWillEnterForeground:)];
        }
    }
    return self;
}

//自定义替换实现该方法
- (void)socket_applicationDidEnterBackground:(UIApplication *)application {
    [[SFTcpSocket shareTcpSocket].handle applicationSocketWithEnterBackground:YES];
    if ([[SFTcpSocket shareTcpSocket].handle respondsToSelector:@selector(socket_applicationDidEnterBackground:)]) {
        [[SFTcpSocket shareTcpSocket].handle performSelector:@selector(socket_applicationDidEnterBackground:) withObject:application];
    }
}

//自定义替换实现该方法
- (void)socket_applicationWillEnterForeground:(UIApplication *)application {
    [[SFTcpSocket shareTcpSocket].handle applicationSocketWithEnterBackground:NO];
    if ([[SFTcpSocket shareTcpSocket].handle respondsToSelector:@selector(socket_applicationWillEnterForeground:)]) {
        [[SFTcpSocket shareTcpSocket].handle performSelector:@selector(socket_applicationWillEnterForeground:) withObject:application];
    }
    
}

- (void) exchangeInstanceMethodWithOrigin:(Class)class sel:(SEL)originalSelector nSel:(SEL)newSelector {
    NSParameterAssert(originalSelector);
    NSParameterAssert(newSelector);
    if ([class instancesRespondToSelector:originalSelector]) {
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method newMethod = class_getInstanceMethod([self class], newSelector);
        method_exchangeImplementations(originalMethod, newMethod);
    }
    else {
        NSAssert(NO, @"AppDelegate 必须实现applicationWillEnterForeground:和applicationDidEnterBackground:方法");
    }
}

- (void) applicationSocketWithEnterBackground:(BOOL)enter {
    NSLog(@"是否进入后台：%d",enter);
    if (enter) {
        if([SFTcpSocket shareTcpSocket].isConnected){
            [[SFTcpSocket shareTcpSocket] disConnect];
        }
    }
    else {
        [[SFTcpSocket shareTcpSocket] reConnect];
    }
}

@end
