//
//  ViewController.h
//  YoyoLiveDemo
//
//  Created by kaso on 16/10/16.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YoyoPopView;
@interface ViewController : UIViewController
/**
 *  登录页面
 */
@property (nonatomic, weak) YoyoPopView *loginView;
/**
 *  登录处理
 */
- (void) showLoginView ;

@end

