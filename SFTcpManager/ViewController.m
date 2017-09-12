//
//  ViewController.m
//  SFTcpManager
//
//  Created by 王声远 on 2017/9/5.
//  Copyright © 2017年 王声远. All rights reserved.
//

#import "ViewController.h"
#import "TcpSocket.h"

@interface ViewController ()<TcpSocketDelegate,UITextFieldDelegate>

@property (nonatomic,strong) TcpSocket *tcpSocket;

@property (weak, nonatomic) IBOutlet UITextView *showMessageTextView;
@property (weak, nonatomic) IBOutlet UITextField *remotePortTextField;
@property (weak, nonatomic) IBOutlet UITextField *remoteIpTextField;
@property (weak, nonatomic) IBOutlet UITextField *sendMsgTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tcpSocket = [TcpSocket shareTcpSocket];
    [self.tcpSocket addDelegate:self];
    self.remoteIpTextField.delegate = self;
    self.remotePortTextField.delegate = self;
    self.sendMsgTextField.delegate = self;
    
    self.showMessageTextView.userInteractionEnabled = NO;
}

- (IBAction)clearReceverData:(UIButton *)sender {
    self.showMessageTextView.text = @"";
}

- (IBAction)sendMessage:(UIButton *)sender {
    if (!self.tcpSocket.isConnected) {
        [self showAlertWithMessage:@"请先连接"];
        return;
    }
    
    //获取发送内容
    NSString *msg = self.sendMsgTextField.text;
    if (msg.length == 0) {
        [self showAlertWithMessage:@"请先输入发送内容"];
        return;
    }
    
    NSData *sData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [self.tcpSocket sendData:sData];
}

- (IBAction)connectClick:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:@"连接"]) {
        if (!self.tcpSocket.isConnected) {
            //获取对方IP
            NSString *ip = self.remoteIpTextField.text;
            if (ip.length == 0) {
                [self showAlertWithMessage:@"请先输入对方iP"];
                return;
            }
            
            //获取对方端口
            NSString *port = self.remotePortTextField.text;
            if (port.length == 0) {
                [self showAlertWithMessage:@"请先输入对方端口"];
                return;
            }
            int p = [port intValue];
            
            [self.tcpSocket connect:ip port:p];
            [self.view endEditing:YES];
        }
    }
    else {
        [self.tcpSocket disConnect];
    }
}

- (void)tcpSocket:(TcpSocket *)udpSocket connectStatus:(BOOL)connect {
    SLOG(@"tcp状态改变：%d",connect);
    [self.connectBtn setTitle:connect?@"断开":@"连接" forState:UIControlStateNormal];
    self.showMessageTextView.text = @"";
}

- (void)tcpSocket:(TcpSocket *)udpSocket receverData:(NSString *)data {
    SLOG(@"tcp收到：%@",data);
    self.showMessageTextView.text = data;
}

//弹出对话框
- (void)showAlertWithMessage:(NSString *)msg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:alertAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

@end
