//
//  YoyoIjkPlayer.h
//  YoyoLiveDemo
//
//  Created by kaso on 17/10/16.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YoyoApi.h"

@interface YoyoKsyPlayer : NSObject
@property (nonatomic, copy) NSString *vhUrl;
@property (nonatomic, unsafe_unretained) CGRect vhFrame;
@property (nonatomic, strong) UIView *vhView;
@property (nonatomic, weak) id<YoyoVideoBridgeNotifySdkEventDelegate> sdkEvtDelegate;

-(void) startVideo;
-(void) stopVideo;
@end
