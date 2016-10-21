//
//  YoyoIjkPlayer.m
//  YoyoLiveDemo
//
//  Created by kaso on 17/10/16.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "YoyoKsyPlayer.h"

#import <KSYMediaPlayerDy/KSYMediaPlayerDy.h>

@interface YoyoKsyPlayer()

@property (nonatomic, strong) KSYMoviePlayerController *ksyMoviewPlayer;

@property (nonatomic, unsafe_unretained) BOOL isPlaying;

@end

@implementation YoyoKsyPlayer
-(KSYMoviePlayerController *)ksyMoviewPlayer{
    if (!_ksyMoviewPlayer) {
        NSString *url = [self.vhUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *nsUrl = [NSURL URLWithString:url];
        _ksyMoviewPlayer = [[KSYMoviePlayerController alloc] initWithContentURL:nsUrl];
        _ksyMoviewPlayer.view.layer.masksToBounds = YES;
        _ksyMoviewPlayer.shouldAutoplay = YES;
        _ksyMoviewPlayer.videoDecoderMode = MPMovieVideoDecoderMode_Software;
        _ksyMoviewPlayer.scalingMode = MPMovieScalingModeAspectFill;
        _ksyMoviewPlayer.bufferTimeMax = 0;
        _ksyMoviewPlayer.view.frame = self.vhFrame;
        [self.vhView addSubview:_ksyMoviewPlayer.view];
        [self addObservers];
    }
    return _ksyMoviewPlayer;
}

-(void)setVhFrame:(CGRect)vhFrame{
    _vhFrame = vhFrame;
    if (_ksyMoviewPlayer) {
        __weak KSYMoviePlayerController *weakPlayer = _ksyMoviewPlayer;
        [UIView animateWithDuration:0.15 animations:^{
            weakPlayer.view.frame = vhFrame;
        }];
    }
}

-(void) addObservers{
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserver:self selector:@selector(onLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(onPlaybackDidFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(onPlaybackStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [notifyCenter addObserver:self selector:@selector(onGotFirstVideoFrame:) name:MPMoviePlayerFirstVideoFrameRenderedNotification object:nil];
}

-(void) removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) onLoadStateChanged:(NSNotification *)notifier{
    MPMovieLoadState loadState = self.ksyMoviewPlayer.loadState;
    if (!loadState) {
        [self onError];
    }else if(loadState & MPMovieLoadStateStalled){
        [self onLoading];
    }else{
        [self onStarted];
    }
}

-(void) onGotFirstVideoFrame:(NSNotification *) notifier{
    self.ksyMoviewPlayer.bufferTimeMax = 2;
}

-(void) onPlaybackDidFinished:(NSNotification *)notifier{
    MPMovieFinishReason reason = [[notifier.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue];
    switch (reason) {
        case MPMovieFinishReasonUserExited:
        case MPMovieFinishReasonPlaybackEnded: {
            if (self.isPlaying) {
                [self onError];
            }else{
                [self onStoped];
            }
            break;
        }
        case MPMovieFinishReasonPlaybackError: {
            [self onError];
            break;
        }
    }
}

-(void) onPlaybackStateChanged:(NSNotification *)notifier{
    switch (self.ksyMoviewPlayer.playbackState) {
        case MPMoviePlaybackStateStopped: {
            if (self.isPlaying) {
                [self onError];
            }else{
                [self onStoped];
            }
            break;
        }
        case MPMoviePlaybackStatePlaying: {
            [self onStarted];
            break;
        }
        case MPMoviePlaybackStatePaused: {
            [self onLoading];
            break;
        }
        case MPMoviePlaybackStateInterrupted: {
            [self onError];
            break;
        }
        default:
            break;
    }
}

-(void) onError{
    [self.sdkEvtDelegate onAppEvent:YoyoVideoBridgeNotifySdkEventNeedRestart];
}

-(void) onLoading{
    [self.sdkEvtDelegate onAppEvent:YoyoVideoBridgeNotifySdkEventOnLoading];
}

-(void) onStarted{
    [self.sdkEvtDelegate onAppEvent:YoyoVideoBridgeNotifySdkEventOnStarted];
}

-(void) onStoped{
    [self.sdkEvtDelegate onAppEvent:YoyoVideoBridgeNotifySdkEventOnStoped];
}

-(void) startVideo{
    if (self.isPlaying) {
        [self stopVideo];
    }
    [self onLoading];
    [self.ksyMoviewPlayer prepareToPlay];
    self.isPlaying = YES;
}

-(void) stopVideo{
    if (!self.isPlaying) {
        return;
    }
    [self.ksyMoviewPlayer reset:NO];
    [self.ksyMoviewPlayer stop];
    [self.ksyMoviewPlayer.view removeFromSuperview];
    self.ksyMoviewPlayer = nil;
    [self removeObservers];
    self.isPlaying = NO;
}

@end
