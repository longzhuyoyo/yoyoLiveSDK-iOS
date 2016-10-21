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

@interface YoyoSdkTool : NSObject
@property (nonatomic, strong) SdkCallBackDataBlock responseBlock;
@property (nonatomic, strong) SdkCallBackEventBlock eventBlock;

@property (nonatomic, strong) YoyoSingerListRecord *singerListRecord;

+ (instancetype) shareInstance;

+ (void) initSdk;

@end
