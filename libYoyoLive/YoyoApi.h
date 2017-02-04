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
 * 是否使用https 默认开启
 */
@property (nonatomic, unsafe_unretained) BOOL useHttps;

/**
 *   单例方法
 */
+ (instancetype) shareInstance;

/**
 *  sdk版本号
 */
+ (NSString *) version;

/**
 *  设置是否使用SDK调试服务器,默认为正式服务器 (请在初始化sdk之前调用)
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
 *  分享平台定制功能，在开启第三方分享的情况下，可调用此方法添加想要分享的目标平台，目前支持qq好友，qq空间，微信好友，微信朋友圈，新浪微博，剪贴板等
 *  在参数sharePlatform数组内传入shareType的枚举值即可，若不调用此方法且开启分享功能，默认可分享到上述所有平台
 *
 *  @param sharePlatforms 要分享的平台，数组元素从 YoyoShareType 里面取。传入空值nil关闭分享。
 *  @return 是否使用指定参数开启分享功能
 */
+ (BOOL) setThirdSharePlatform:(NSArray *)sharePlatforms;

/**
 *  SDK初始化，必须调用此接口初始化SDK，否则SDK无法使用。参数由SDK服务端提供.
 *
 *  @return 是否成功调用接口
 */
+ (BOOL) registerAppWithAppkey:(NSString *)appkey privateKey:(NSString *)privateKey;

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

@end
