//
//  YoyoPopView.h
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/17.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^OnClickConfigureBlock)(NSDictionary *textFileContent);
typedef void(^OnClickCancelBlock)();

@interface YoyoPopView : UIControl

+ (instancetype) YoyoPopView;
/**
 *  初始化弹出页面
 *
 *  @param NameArr           弹框中textFile内容
 *  @param title             弹框标题
 *  @param configureCallBack 回调block
 */
-(void) initYoyoPopViewWithTestFilePlaceNameArr:(NSArray*)NameArr title:(NSString*)title OnClickConfigureBlock:(OnClickConfigureBlock)configureCallBack onCancel:(OnClickCancelBlock) onCancel;

/**
 *  同上个方法，cancel为空
 */
-(void) initYoyoPopViewWithTestFilePlaceNameArr:(NSArray*)NameArr title:(NSString*)title OnClickConfigureBlock:(OnClickConfigureBlock)configureCallBack;

/**
 *  弹框label
 *
 *  @param tipStr 提示字符串
 */
+ (void) createTipLabel:(NSString*)tipStr;
@end
