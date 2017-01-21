//
//  YoyoSdkTool.h
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/17.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoyoApiObject.h"
#import "YoyoApi.h"

typedef void(^SdkCallBackDataBlock)(id data);
typedef void(^SdkCallBackEventBlock)(YoyoEvent event,id data);

@protocol YoyoSdkToolDelegate <NSObject>

@optional
- (void) yoyoSdkToolShowLoginView ;

- (void) yoyoSdkToolShowExchangeView;

- (void) yoyoSdkToolCallBackSingerListDataWithSingerRecord:(YoyoSingerListRecord*)singerListRecord;

- (void) yoyoSdkToolCallBackShareData:(id)data;

- (void) yoyoSdkToolCallBackErrorData:(id)errorData;

- (void) yoyoSdkToolCallBackWhenLoginSuccess;

- (void) yoyoSdkToolCallBackWhenExchangerSuccess;

- (void) yoyoSdkToolCallBackUserInfoWhenSuccess;

@end
@interface YoyoSdkTool : NSObject

@property (nonatomic,weak) id<YoyoSdkToolDelegate> delegate;

+ (instancetype) shareInstance;

+ (void) initSdk;

+ (void) yoyoSdkToolSetThirdSharePlatformWithThirdType:(NSArray*)thirdTypeArr;

+ (void) yoyoSdkToolSetLoginOut;

+ (void) yoyoSdkToolEnterRoomWithRoomID:(NSString*)roomID;

+ (void) yoyoSdkToolLoginWithOpenID:(NSString*)openID token:(NSString*)token;

+ (void) yoyoSdkToolExchangeWithMount:(NSInteger)mount orderId:(NSString*)orderID token:(NSString*)token;

+ (void) yoyoSdkToolUpdateAvatarUrl:(NSString*)avatarUrl alias:(NSString*)alias;
@end
