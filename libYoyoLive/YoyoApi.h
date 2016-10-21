//
//  YoyoApi.h
//  Yoyo_new
//
//  Created by xcyo on 16/9/27.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YoyoApiObject.h"

/**
 *  SDK的主入口
 */
@interface YoyoApi : NSObject

/**
 *  服务器回调
 */
@property (nonatomic, weak) id <YoyoServerDelegate> serverDelegate;

/**
 *  事件回调
 */
@property (nonatomic, weak) id <YoyoEventDelegate> eventDelegate;

/**
 *  自定义RTMP播放器回调，没有自定义播放器的话，默认使用hls播放视频。
 */
@property (nonatomic, weak) id<YoyoVideoBridgeNotifyAppEventDelegate> videoDelegate;

/**
 *   初始化方法
 */
+ (instancetype) shareInstance;

/**
 *  版本号
 */
+ (NSString *) version;

/**
 *  设置是否为SDK调试服务器,默认为正式服务器 (请在初始化sdk之前调用)
 *  调试时可以使用此服务器，上线后必须使用正式服务器（不调用此方法，默认就是正式服务器）
 *  
 *  @param isDebug 是否使用调试服务器。
 *
 *  @return 操作是否成功
 */
+ (BOOL) setUseDebugSDKServer:(BOOL) isDebug;

/**
 *  设置是否显示SDK内部测试log，默认关闭
 *
 *  @param enable 是否显示
 *
 *  @return 操作是否成功
 */
+ (BOOL) setDebugLogEnable:(BOOL) enable;

/**
 *  是否开启第三方分享功能，如果关闭，房间页面内看不到分享按钮，默认关闭
 *
 *  @param enable 是否开启
 *
 *  @return 操作是否成功
 */
+ (BOOL) setThirdShareEnable:(BOOL) enable;

/**
 *  sdk内部调用的接口，如果服务端返回错误，可能会有一个系统默认的提示框。用此开关可以控制是否显示此提示框。
 *  默认为打开。
 *  如果设置为关闭，不会弹出任何内容，错误消息会通过 YoyoEventServerErrorMsg 事件通知APP，可以定制APP自己风格的显示框。
 *
 *  @param enable 是否打开
 *
 *  @return 操作是否成功
 */
+ (BOOL) setServerErrorMsgPopViewEnable:(BOOL) enable;

/**
 *  SDK初始化，必须调用此接口初始化SDK，否则SDK无法使用。参数由SDK服务端提供。(默认支持bugly)
 *
 *  @return 是否成功调用接口
 */
+ (BOOL) registerAppWithAppkey:(NSString *)appkey privateKey:(NSString *)privateKey;
+ (BOOL) registerAppWithAppkey:(NSString *)appkey privateKey:(NSString *)privateKey isSupportBugly:(BOOL)isSupport;

/**
 *  登录SDK，APP内如果登录了，必须调用此接口登录SDK
 *
 *  @param openId APP登录帐号的唯一标识符，用来唯一区别此帐号的id，由APP服务端提供接口。
 *  @param token  APP服务器为登录接口生成的token，有次数和时间限制
 *
 *  @return 是否成功调用接口
 */
+ (BOOL) loginWithOpenID:(NSString *) openId token:(NSString *)token;

/**
 *  退出登录，APP内如果退出登录了，必须调用此接口退出登录SDK。
 *
 *  @return 是否退出登录
 */
+ (BOOL) logout;

/**
 *  设置当前是否是审核版本（默认为审核版本），可过滤一些敏感信息的显示
 *  敏感信息包含下面2条内容：
 *  1. 礼物名称中，非审核版本可能会违规的词语：如，蛇精病，草泥马，单身狗，滚蛋，猪头等。审核版本对应改为，吃药吧，羊驼，小狗，鸡蛋，小猪。
 *  2. 房间内有个守护功能，非审核版本点击开通守护后，会显示购买守护时长的选项，这是违规的内容。审核版本点击开通守护，不会弹出购买页面，会有一个不违规的提示。
 *  @param isReview 是否是审核版本
 */
+ (BOOL) setReviewVersion:(BOOL) isReview;

/**
 *  进入直播间，需要提前通过调用getSingerList接口获取所有主播的roomId/封面照等数据。
 *
 *  @param roomId 主播房间号。 
 *
 *  @return 是否已进入房间
 */
+ (BOOL) enterRoomWithRoomId:(NSString*) roomId;

/**
 *  更新用户信息。为保持APP内昵称和头像同SDK保持一致，APP修改用户信息的时候，如果头像和昵称发生了变化，需要通知sdk修改这些信息
 *
 *  @param avatar 要修改的头像完整地址
 *  @param alias  要修改的昵称
 *
 *  @return 是否成功调用接口
 */
+ (BOOL) updateUserAvatarUrl:(NSString *)avatar alias:(NSString *)alias;

/**
 *   获取主播列表
 *
 *  @return 是否成功调用接口
 */
+ (BOOL) getSingerList;

/**
 *  兑换悠币
 *
 *  @param mount   兑换金额 （单位：人民币 元)
 *  @param orderId APP向服务器请求后生成的订单号
 *  @param token   APP服务器为本次请求生成的token，有时间和次数限制
 *
 *  @return 是否成功调用接口
 */
+ (BOOL) exchangeWithMount:(NSInteger)mount orderId:(NSString *)orderId token:(NSString *)token;

/**
 *  是否支持兑换悠币功能（默认支持）
 *
 *  @param isSupport 是否支持
 *
 *  @return 是否操作成功
 */
+ (BOOL) setIsExchangeSupport:(BOOL) isSupport;

/**
 *  是否支持开通守护功能（默认支持）
 *
 *  @param isSupport 是否支持
 *
 *  @return 是否操作成功
 */
+ (BOOL) setIsOpenGuardSupport:(BOOL) isSupport;

/**
 *  直接请求SDK服务器，此方法返回数据不通过serverDelegate，只通过callback block返回。
 *
 *  @param method   方法名
 *  @param params   参数
 *  @param callback 结果数据（json 格式）
 *
 *  @return 是否成功调用接口
 */
+(BOOL) HttpPost: (NSString *)method params: (id) params callback:(void (^)(id))callback;

/**
 *  获取完整的图片Url，调用接口返回的图片地址可能是相对路径，调用此方法，返回完整的地址。头像和其他图片调用不同的方法。
 *
 *  @param urlTail
 *
 *  @return 完整的url
 */
+ (NSString *) getFullImageUrl:(NSString *)urlTail;
+ (NSString *) getFullAvatarUrl:(NSString *)urlTail;

@end

/**
 * 不支持的功能类型
 */
typedef enum : NSUInteger {
    YoyoApiNotSupportFunctionTypeExchange,//兑换
    YoyoApiNotSupportFunctionTypeOpenGuard,//开通守护
} YoyoApiNotSupportFunctionType;

/**
 *  当用户选择了不支持的功能，通过实现此方法，给用户提示。
 */
@protocol YoyoApiNotSupportFunctionTipDelegate <NSObject>
-(void) onNotSupportFunction:(YoyoApiNotSupportFunctionType) funcType tip:(NSString *)tip;
@end

@interface YoyoApi (NotSupportFunction)
/**
 *  是否支持兑换功能
 */
@property (nonatomic, unsafe_unretained) BOOL isSupportExchange;

/**
 *  是否支持开启守护功能
 */
@property (nonatomic, unsafe_unretained) BOOL isSupportOpenGuard;

/**
 *  如果当前功能不可用，通过此代理提示用户。
 */
@property (nonatomic, weak) id<YoyoApiNotSupportFunctionTipDelegate> notSupportFunctionTipDelegate;
@end
