//
//  YoyoSdkTool_args.h
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/19.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "YoyoSdkTool.h"

@interface YoyoSdkTool ()
/**
 *  登录状态
 */
@property (nonatomic, unsafe_unretained) BOOL isLogin;
/**
 *  支持守护状态
 */
@property (nonatomic, unsafe_unretained) BOOL isSupportGuard;
/**
 *  支持兑换状态
 */
@property (nonatomic, unsafe_unretained) BOOL isSupportExchange;
/**
 *  支持错误信息状态
 */
@property (nonatomic, unsafe_unretained) BOOL isOpenServierErrorMsgPopView;
/**
 *  log状态
 */
@property (nonatomic, unsafe_unretained) BOOL isOpenLog;
/**
 *  审核版本状态
 */
@property (nonatomic, unsafe_unretained) BOOL isOpenReviewVersin;
/**
 *  第三方分享功能状态
 */
@property (nonatomic, unsafe_unretained) BOOL isOpenThirdShare;

@end
