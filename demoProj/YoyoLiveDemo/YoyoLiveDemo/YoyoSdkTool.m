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
        [self initSdk];
        [self initTool];
    }
    return self;
}

/*
 demo帮助方法
 */
- (void) initTool{
    // 初始化状态参数
    self.isLogin = NO;
    self.isOpenLog = YES;
    self.isOpenThirdShare = YES;
    self.isOpenReviewVersin = NO;
}

/*
 初始化sdk（重要）
 */
- (void) initSdk{
    // 设置为测试网络 (默认为线上服务器,测试必须设置)
    [YoyoApi setUseDebugSDKServer:YES];
    [YoyoApi shareInstance].useHttps = NO;
    
    // 网络数据代理(必需)
    [YoyoApi shareInstance].serverDelegate = self;
    // 事件回调代理(必需)
    [YoyoApi shareInstance].eventDelegate = self;
    
    //注册（必需）
    [YoyoApi registerAppWithAppkey:@"10001" privateKey:@"123456"];

    // 开启 debug log（非必需）
    [YoyoApi setDebugLogEnable:YES];
    
    // 是否开启房间内分享，需要APP接入第三方分享（非必需）
    [YoyoApi setThirdSharePlatform:@[@(YoyoShareTypeWX)]];
    
    // 视频接入(非必需)
    self.ksyPlayer = [[YoyoCustomVideoPlayerKsy alloc] init];
    [YoyoApi shareInstance].videoDelegate = self.ksyPlayer;
}

#pragma mark - delegate
/*
 SDK网络接口回调（必需）,具体内容可由App 端自主编写，但是下面注册和获取主播列表的步骤不能变。
 */
- (void) onResponse:(YoyoBaseResp *)response{
    if(response.statusCode == YoyoStatusCodeOk){
        if ([YoyoServerMethodNameRegister isEqualToString:response.method]) {
            //注册成功后才能获取主播列表
            [YoyoApi getSingerList];
        }else if ([YoyoServerMethodNameGetSingerList isEqualToString:response.method]) {
            //获取主播列表成功
            if ([self.delegate respondsToSelector:@selector(yoyoSdkToolCallBackSingerListDataWithSingerRecord:)]) {
                [self.delegate yoyoSdkToolCallBackSingerListDataWithSingerRecord:(YoyoSingerListRecord*)response.data];
            }
        }else if ([YoyoServerMethodNameLogin isEqualToString:response.method]) {
            self.isLogin = YES;
            if ([self.delegate respondsToSelector:@selector(yoyoSdkToolCallBackWhenLoginSuccess)]) {
                [self.delegate yoyoSdkToolCallBackWhenLoginSuccess];
            }
        }else if ([YoyoServerMethodNameUpdateUserInfo isEqualToString:response.method]){
            if ([self.delegate respondsToSelector:@selector(yoyoSdkToolCallBackUserInfoWhenSuccess)]) {
                [self.delegate yoyoSdkToolCallBackUserInfoWhenSuccess];
            }
        }
        
    }else{
        //［注意］接口调用失败，原则上需要根据错误类型，提示用户或重新请求。
        NSLog(@"接口(%@)调用失败，原因：%@", response.method, response.statusStr);
    }
}

/*
 SDK事件回调，具体内容由App端自主编写。
 例如，用户没登陆，但是点击赠送荧光棒，此时会弹出AlertView提示是否登录，用户点击登录就会出发此回调，并且event的值为YoyoEventLogin
 因此，eventDelegate为被动触发的事件接口。
 兑换和分享类似。
 YoyoEventServerErrorMsg 表示网络调用失败会返回一个表示此失败的一个字符串，可忽略。
 */
- (void) onEvent:(YoyoEvent) event data:(id) data {
    if (event == YoyoEventServerErrorMsg) {
        [YoyoPopView createTipLabel:data];
    }
    
    switch (event) {
        case YoyoEventExchange:
            if ([self.delegate respondsToSelector:@selector(yoyoSdkToolShowExchangeView)]) {
                [self.delegate yoyoSdkToolShowExchangeView];
            }
            break;
        case YoyoEventLogin:
            if ([self.delegate respondsToSelector:@selector(yoyoSdkToolShowLoginView)]) {
                [self.delegate yoyoSdkToolShowLoginView];
            }
            break;
        case YoyoEventShare:
            if ([self.delegate respondsToSelector:@selector(yoyoSdkToolCallBackShareData:)]) {
                [self.delegate yoyoSdkToolCallBackShareData:data];
            }
            break;
        case YoyoEventServerErrorMsg:
            if ([self.delegate respondsToSelector:@selector(yoyoSdkToolCallBackErrorData:)]) {
                [self.delegate yoyoSdkToolCallBackErrorData:data];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Public Method
/**
 *设置分享平台
 */
+ (void) yoyoSdkToolSetThirdSharePlatformWithThirdType:(NSArray*)thirdTypeArr {
    [YoyoApi setThirdSharePlatform:thirdTypeArr];
}

/**
 *  退出页面
 */
+ (void) yoyoSdkToolSetLoginOut {
    [YoyoApi logout];
}

/**
 *  进入房间
 */
+ (void) yoyoSdkToolEnterRoomWithRoomID:(NSString*)roomID {
    [YoyoApi enterRoomWithRoomId:roomID];
}

/**
 *  登录
 */
+ (void) yoyoSdkToolLoginWithOpenID:(NSString*)openID token:(NSString*)token {
    [YoyoApi loginWithOpenID:openID token:token];
}

/**
 *  兑换
 */
+ (void) yoyoSdkToolExchangeWithMount:(NSInteger)mount orderId:(NSString*)orderID token:(NSString*)token {
    [YoyoApi exchangeWithMount:mount orderId:orderID token:token];
}

/**
 *  更新用户信息
 */
+ (void) yoyoSdkToolUpdateAvatarUrl:(NSString*)avatarUrl alias:(NSString*)alias {
    [YoyoApi updateUserAvatarUrl:avatarUrl alias:alias];
}

/**
 *  设置审核版本
 */
- (void)setIsOpenReviewVersin:(BOOL)isOpenReviewVersin {
    _isOpenReviewVersin = isOpenReviewVersin;
    
    [YoyoApi setReviewVersion:isOpenReviewVersin];
}

/**
 *  log开关
 */
- (void)setIsOpenLog:(BOOL)isOpenLog {
    _isOpenLog = isOpenLog;
    [YoyoApi setDebugLogEnable:isOpenLog];
}
@end
