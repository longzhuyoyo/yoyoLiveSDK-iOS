//
//  YoyoSdkTool.m
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/17.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "YoyoSdkTool.h"

#import "YoyoCustomVideoPlayerKsy.h"
#import "YoyoSdkTool+Args.h"
#import "YoyoPopView.h"
@interface YoyoSdkTool () <YoyoServerDelegate,YoyoEventDelegate>
@property (nonatomic, strong) YoyoCustomVideoPlayerKsy *ksyPlayer;
@end

@implementation YoyoSdkTool

//单例
+ (instancetype) shareInstance {
    static YoyoSdkTool *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[YoyoSdkTool alloc] init];
    });
    return handler;
}

+ (void) initSdk{
    [self shareInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initInner];
    }
    return self;
}

- (void) initInner{
    // 设置为测试网络 (默认为线上服务器,测试必须设置)
    [YoyoApi setUseDebugSDKServer:YES];
    // 网络数据代理(必须)
    [YoyoApi shareInstance].serverDelegate = self;
    // 事件回调代理(必须)
    [YoyoApi shareInstance].eventDelegate = self;
    
    //注册(必须,默认支持bugly)
    [YoyoApi registerAppWithAppkey:@"10001" privateKey:@"123456"];
    
    // 开启 debug log
    [YoyoApi setDebugLogEnable:YES];
    
    // 是否开启房间内分享，需要APP接入第三方分享
    [YoyoApi setThirdShareEnable:YES];
    
    // 关闭SDK内部错误提示
    [YoyoApi setServerErrorMsgPopViewEnable:NO];
    
    // 视频接入
    self.ksyPlayer = [[YoyoCustomVideoPlayerKsy alloc] init];
    [YoyoApi shareInstance].videoDelegate = self.ksyPlayer;
    
    // 初始化状态参数
    self.isLogin = NO;
    self.isOpenLog = YES;
    self.isSupportExchange = YES;
    self.isSupportGuard = YES;
    self.isOpenServierErrorMsgPopView = YES;
    self.isOpenThirdShare = YES;
    self.isOpenReviewVersin = YES;
}

#pragma mark - delegate
- (void) onResponse:(YoyoBaseResp *)response{
    if(response.statusCode == YoyoStatusCodeOk){
        if ([YoyoServerMethodNameRegister isEqualToString:response.method]) {
            //注册成功后才能获取主播列表
            [YoyoApi getSingerList];
        }else if ([YoyoServerMethodNameGetSingerList isEqualToString:response.method]) {
            //获取主播列表成功
            self.singerListRecord = (YoyoSingerListRecord *)response.data;
        }else if ([YoyoServerMethodNameLogin isEqualToString:response.method]) {
            self.isLogin = YES;
        }
        
        if (self.responseBlock) {
            self.responseBlock(response);
        }
    }else{
        //［注意］接口调用失败，原则上需要根据错误类型，提示用户或重新请求。
        NSLog(@"接口(%@)调用失败，原因：%@", response.method, response.statusStr);
    }
}

- (void) onEvent:(YoyoEvent) event data:(id) data {
    if (event == YoyoEventServerErrorMsg) {
        [YoyoPopView createTipLabel:data];
    }
    
    if (self.eventBlock) {
        self.eventBlock(event,data);
    }
}

@end
