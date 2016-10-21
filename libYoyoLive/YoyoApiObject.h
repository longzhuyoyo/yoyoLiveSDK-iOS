//
//  YoyoApiObject.h
//  Yoyo_new
//
//  Created by fanqile on 16/9/29.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YoyoBaseResp;
@class YoyoBaseRecord;

/**
 * SDK服务器请求错误码
 */
typedef enum : NSUInteger{
    YoyoStatusCodeOk = 0,//正确
    YoyoStatusCodeErrorNoNet = -1,//没有网络
    YoyoStatusCodeErrorServer = -2,//服务器错误
    YoyoStatusCodeErrorOther = 33333,  // 其他错误
    //下面为具体服务器错误
    YoyoStatusCodeErrorAppKey = 22222 ,    //appkey为空
    YoyoStatusCodeErrorParams = 10002,  //参数错误
    YoyoStatusCodeErrorSystem = 10005,     //系统错误
    YoyoStatusCodeErrorInvalidSign = 10008 ,//签名错误
    YoyoStatusCodeErrorToken = 10009,  //yoyoToken过期或没有
    YoyoStatusCodeErrorInvalidUser = 40301, //用户不存在
    YoyoStatusCodeErrorNeedLogin = 40304, //未登录
    YoyoStatusCodeErrorExchange = 40501, //兑换失败
    YoyoStatusCodeErrorInvalidRoomId = 40601, //房间不存在
    YoyoStatusCodeErrorChannel = 40801, // 渠道错误
    YoyoStatusCodeErrorThirdStatus = 40802,         // 第三方请求状态错误
    YoyoStatusCodeErrorThirdParams = 40803,         // 第三方请求返回参数错误
    YoyoStatusCodeErrorThirdSign = 40804,           // 第三方签名错误
    YoyoStatusCodeErrorThirdToken = 40805,          // 第三方token错误
    YoyoStatusCodeErrorTransactionID = 40806,       // 第三方交易号错误
    YoyoStatusCodeErrorTransactionAmount = 40807,   // 第三方交易金额错误
} YoyoStatusCode;

/**
 *  SDK服务器请求回调，SDK内调用的服务器接口回调，用以获取调用接口的状态及返回数据。
 */

@protocol YoyoServerDelegate <NSObject>

- (void) onResponse:(YoyoBaseResp *) response;

@end

/**
 *  SDK通知APP的事件
 */
typedef enum: NSUInteger{
    YoyoEventExchange,  //兑换
    YoyoEventLogin, //登录
    YoyoEventShare, // 分享点击
    YoyoEventServerErrorMsg, //SDK服务器接口调用错误消息
} YoyoEvent;

/**
 *  第三方分享类型
 */
typedef enum: NSUInteger{
    YoyoShareTypeQqFriend,     // qq
    YoyoShareTypeQZone,        // qq空间
    YoyoShareTypeWX,           // 微信
    YoyoShareTypeWXTimeLine,   // 微信朋友圈
    YoyoShareTypeXinLang,      // 新浪
    YoyoShareTypePasteBoard,   // 剪切板
} YoyoShareType;

/**
 *  SDK通知APP的事件回调，SDK内一些事件通知，APP要根据通知的类型，调用一些代码。
 */

@protocol YoyoEventDelegate <NSObject>

- (void) onEvent:(YoyoEvent) event data:(id) data;

@end


/**
 * 自定义RTMP播放器，需要APP给SDK返回当前视频状态。
 */
typedef enum : NSUInteger {
    YoyoVideoBridgeNotifySdkEventOnStarted,//视频已开始
    YoyoVideoBridgeNotifySdkEventOnLoading,//视频正在loading
    YoyoVideoBridgeNotifySdkEventOnStoped,//视频已停止
    YoyoVideoBridgeNotifySdkEventNeedRestart,//视频因错误需要重启
} YoyoVideoBridgeNotifySdkEvent;

/**
 * 自定义RTMP播放器SDK回调，由SDK实现，APP调用，提醒SDK当前视频流播放状态
 */
@protocol YoyoVideoBridgeNotifySdkEventDelegate <NSObject>
/**
 *  APP端自定义播放器，如果发生了状态变化，需要调用此方法通知SDK
 *
 *  @param appEvent 播放器状态所对应的事件
 */
-(void) onAppEvent:(YoyoVideoBridgeNotifySdkEvent) appEvent;
@end

/**
 *  自定义RTMP播放器APP回调。
 *  由APP实现，SDK调用，提醒APP，SDK中对视频的控制。
 *  如果需要使用外部播放器，必须指定这个回调。
 */
@protocol YoyoVideoBridgeNotifyAppEventDelegate <NSObject>

/**
 *  打开自定义RTMP视频播放器
 *
 *  @param url       RTMP url
 *  @param superView 自定义播放器view的superView
 *  @param delegate  APP需要保存这个delegate，然后根据自定义播放器的状态，提醒SDK当前播放状态。
 */
-(void) onStartWithUrl:(NSString *)url superView:(UIView *)superView notifySdkEventDelegate:(id<YoyoVideoBridgeNotifySdkEventDelegate>) delegate;

/**
 *  关闭自定义RTMP视频播放器
 */
-(void) onStop;

/**
 *  自定义视频播放器改变尺寸
 *
 *  @param rect 将要改变的尺寸
 */
-(void) onFrameChangedWithRect:(CGRect) rect;
@end

/**
 *  SDK服务器接口返回值
 */
@interface YoyoBaseResp : NSObject

/**
 *  数据
 */
@property (nonatomic, strong) YoyoBaseRecord *data;

/**
 *  错误码
 */
@property (nonatomic, unsafe_unretained) YoyoStatusCode statusCode;

/**
 *  错误提示字符串
 */
@property (nonatomic, copy) NSString *statusStr;

/**
 *  方法名
 */
@property (nonatomic, copy) NSString *method;
@end


#ifndef _YOYO_BASE_RECORD_H_
#define _YOYO_BASE_RECORD_H_

@interface YoyoBaseRecord : NSObject<NSCopying>
/**
 *  时间戳
 */
@property (nonatomic, unsafe_unretained) NSInteger timestamp;
@end

#endif

/**
 *  服务端数据预置方法名，也就是YoyoBaseResp.method
 */
extern const NSString *YoyoServerMethodNameRegister;//注册接口
extern const NSString *YoyoServerMethodNameLogin;//登录接口
extern const NSString *YoyoServerMethodNameGetSingerList;//获取主播列表接口
extern const NSString *YoyoServerMethodNameExchange;//兑换接口
extern const NSString *YoyoServerMethodNameUpdateUserInfo;//更新用户信息接口

#pragma mark - YoyoSingerDetailRecord
@interface YoyoSingerDetailRecord : YoyoBaseRecord
/**
 *  房间封面
 */
@property (nonatomic, copy) NSString *cover;
/**
 *  房间标示
 */
@property (nonatomic, unsafe_unretained) BOOL isLive;
/**
 *  rtmpURL
 */
@property (nonatomic, copy) NSString *rtmpUrl;
/**
 *  主播等级
 */
@property (nonatomic, unsafe_unretained) NSInteger singerLevel;
/**
 *  房间标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  观众人数
 */
@property (nonatomic, unsafe_unretained) NSInteger memberNum;
/**
 *  主播昵称
 */
@property (nonatomic, copy) NSString *alias;
/**
 *  房间ID
 */
@property (nonatomic, copy) NSString *roomId;

@end

#pragma mark - 获取歌手列表
@interface YoyoSingerListRecord : YoyoBaseRecord
/**
 *  主播列表数组
 */
@property (nonatomic, strong) NSArray *list;

@end

@interface YoyoApiObject : NSObject
@end
