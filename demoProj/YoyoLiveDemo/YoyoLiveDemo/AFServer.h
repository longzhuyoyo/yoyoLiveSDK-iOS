//
//  AFServer.h
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/17.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CallBackBlock)(id response);
@interface AFServer : NSObject

+(void) HttpPost: (NSString *)method params: (id) params success:(CallBackBlock)successBlock error:(CallBackBlock)errorBlock;

@end
