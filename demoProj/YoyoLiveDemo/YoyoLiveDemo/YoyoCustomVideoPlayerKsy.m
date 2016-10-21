//
//  IjkplayerVideoHandler.m
//  Yoyo_new
//
//  Created by kaso on 23/2/16.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "YoyoCustomVideoPlayerKsy.h"
#import "YoyoKsyPlayer.h"

@interface YoyoCustomVideoPlayerKsy()
@property (nonatomic, strong) YoyoKsyPlayer *ksyPlayer;
@end

@implementation YoyoCustomVideoPlayerKsy

-(YoyoKsyPlayer *)ksyPlayer{
    if (!_ksyPlayer) {
        _ksyPlayer = [[YoyoKsyPlayer alloc] init];
    }
    return _ksyPlayer;
}

-(void) onStartWithUrl:(NSString *)url superView:(UIView *)superView notifySdkEventDelegate:(id<YoyoVideoBridgeNotifySdkEventDelegate>) delegate{
    self.ksyPlayer.vhUrl = url;
    self.ksyPlayer.vhView = superView;
    self.ksyPlayer.sdkEvtDelegate = delegate;
    [self.ksyPlayer startVideo];
}

-(void) onStop{
    [self.ksyPlayer stopVideo];
}

-(void) onFrameChangedWithRect:(CGRect) rect{
    self.ksyPlayer.vhFrame = rect;
}

@end

