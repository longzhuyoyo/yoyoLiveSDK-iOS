//
//  YoyoSwitchListViewController.m
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/18.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "YoyoSwitchListViewController.h"
#import "YoyoPopView.h"
#import "AFServer.h"
#import "YoyoPopView.h"
#import "YoyoSdkTool.h"
#import "YoyoSdkTool+Args.h"
#define TEST_TABLE_VIEW_CELL @"test_table_view_cell"
typedef void(^CallBackBlock)(id response);
#define StringIsEmpty(string) ((string) == nil || (string).length == 0)
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface YoyoSwitchListViewController ()<UITableViewDelegate, UITableViewDataSource,YoyoSdkToolDelegate>
/**
 *  tableView
 */
@property (nonatomic, weak) UITableView *tableView;
/**
 *  标题label
 */
@property (nonatomic, weak) UILabel *titleLabel;
/**
 *  关闭button
 */
@property (nonatomic, weak) UIButton *closeBtn;
/**
 *  cell数组
 */
@property (nonatomic, strong) NSMutableArray *dataArr;
/**
 *  keywindow
 */
@property (nonatomic, strong) UIWindow *window;
/**
 *  用户昵称
 */
@property (nonatomic, strong) NSString *userName;
/**
 *  兑换popView
 */
@property (nonatomic, weak) YoyoPopView *updateInfoView;
/**
 *  是否点击充值
 */
@property (nonatomic, unsafe_unretained) BOOL pendingExchange;
/**
 *  登录页面
 */
@property (nonatomic, weak) YoyoPopView *loginView;
@end

@implementation YoyoSwitchListViewController{
    YoyoSdkTool *sdkTool;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initCell];
    sdkTool = [YoyoSdkTool shareInstance];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    sdkTool.delegate = self;
}


#pragma mark - yoyoSdkDelegate
- (void) yoyoSdkToolCallBackErrorData:(id)errorData {
    NSLog(@"statusStr = %@",errorData);
}

- (void)yoyoSdkToolCallBackUserInfoWhenSuccess {
    [YoyoPopView createTipLabel:@"更新SDK用户信息成功!"];
    [self.updateInfoView removeFromSuperview];
}

- (void)yoyoSdkToolCallBackWhenLoginSuccess {
    [self.loginView removeFromSuperview];
    [YoyoPopView createTipLabel:@"SDK登录成功!"];
    [self setUpdateUserInfo];
}

/**
 *  初始化子控件
 */
-(void) initView{
    // 设置全局view
    self.view.backgroundColor = [UIColor whiteColor];
    [self titleLabel];
    [self closeBtn];
    [self tableView];
}

#pragma mark tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *data = self.dataArr[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEST_TABLE_VIEW_CELL];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TEST_TABLE_VIEW_CELL];
    }
    cell.textLabel.text = data[@"name"];
    return cell;
}
//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = self.dataArr[indexPath.row];
    [self performSelector:NSSelectorFromString(data[@"selector"]) withObject:nil afterDelay:0];
}

/**
 *  初始化点击事件
 */
-(void) initCell{
    [self addCellWithName:@"更新个人信息" selector:@selector(setUpdateUserInfo)];
    [self addCellWithName:@"退出登录" selector:@selector(setLoginOut)];
   // [self addCellWithName:@"分享开关" selector:@selector(setThirdShare)];
    [self addCellWithName:@"设置审核版本" selector:@selector(setReviewVersion)];
    [self addCellWithName:@"SDKDebugLog开关" selector:@selector(setDebugLog)];
    [self addCellWithName:@"自定义分享平台" selector:@selector(setThirdSharePlatform)];
}

#pragma mark - Event Response
/**
 *  更新用户信息
 */
-(void) setUpdateUserInfo{
    if (!sdkTool.isLogin) {
      self.loginView = [self.viewController showLoginView];
        [YoyoPopView createTipLabel:@"请先登录SDK!"];
        return;
    }
    YoyoPopView *popView = [[YoyoPopView alloc] init];
    popView.frame = self.view.bounds;
    [popView initYoyoPopViewWithTestFilePlaceNameArr:@[@"AvatarUrl",@"alias"] title:@"更新用户信息" OnClickConfigureBlock:^(NSDictionary *textFileContent) {
        [YoyoSdkTool yoyoSdkToolUpdateAvatarUrl:textFileContent[@"AvatarUrl"] alias:textFileContent[@"alias"]];
    }];
    [self.window addSubview:popView];
    self.updateInfoView = popView;
}

/**
 *  设置房间页是否需要第三方分享页面
 */
-(void) setThirdShare {
    sdkTool.isOpenThirdShare = !sdkTool.isOpenThirdShare;
    
    [YoyoSdkTool  yoyoSdkToolSetThirdSharePlatformWithThirdType:@[@(YoyoShareTypeWX)]];
    if (sdkTool.isOpenThirdShare) {
        [YoyoPopView createTipLabel:@"开启房间分享功能!"];
    } else {
        [YoyoPopView createTipLabel:@"关闭房间分享功能!"];
    }
}

/**
 *  设置审核版本状态
 */
-(void) setReviewVersion{
    sdkTool.isOpenReviewVersin = !sdkTool.isOpenReviewVersin;

    if (sdkTool.isOpenReviewVersin) {
        [YoyoPopView createTipLabel:@"设置房间为审核版本!"];
    } else {
        [YoyoPopView createTipLabel:@"设置房间为非审核版本!"];
    }
}

/**
 *  退出登录
 */
-(void) setLoginOut {
    if (!sdkTool.isLogin) {
        [YoyoPopView createTipLabel:@"您还没有登录SDK!"];
        return;
    }
    [YoyoSdkTool yoyoSdkToolSetLoginOut];
    [YoyoPopView createTipLabel:@"SDK退出登录!"];
    sdkTool.isLogin = NO;
}
/**
 *  log开关
 */
-(void) setDebugLog {
    sdkTool.isOpenLog = !sdkTool.isOpenLog;

    if (sdkTool.isOpenLog) {
        [YoyoPopView createTipLabel:@"开启SDKLog!"];
    } else {
        [YoyoPopView createTipLabel:@"关闭SDKLog!"];
    }
}

/**
 *设置分享平台
 */
-(void)setThirdSharePlatform{
    [YoyoSdkTool yoyoSdkToolSetThirdSharePlatformWithThirdType:@[@(YoyoShareTypeWXTimeLine), @(YoyoShareTypeXinLang), @(YoyoShareTypePasteBoard)]];
    [YoyoPopView createTipLabel:@"开启分享功能：朋友圈，微博，剪切板!"];
}

#pragma mark - Privite Method
/**
 *  退出页面
 */
-(void) onClosePage{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  设置cell
 *
 *  @param name     标题名称
 *  @param selector 方法名称
 */
-(void) addCellWithName:(NSString *)name selector:(SEL)selector{
    [self.dataArr addObject:@{@"name": name, @"selector": NSStringFromSelector(selector)}];
}

#pragma mark - setter Or getter

-(NSMutableArray *) dataArr{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

-(UITableView *) tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), SCREEN_WIDTH, SCREEN_HEIGHT - CGRectGetMaxY(self.titleLabel.frame));
        [self.view addSubview:tableView];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView = tableView;
    }
    return _tableView;
}

-(UIWindow *) window{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        _window = keyWindow;
    }
    return _window;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        CGFloat titleW = 200;
        CGFloat titleH = 50;
        CGFloat titleX = (SCREEN_WIDTH - titleW) * 0.5;
        CGFloat titleY = 10 + 20;
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"SDK其他功能";
        [titleLabel sizeToFit];
        [self.view addSubview:titleLabel];
        titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat closeButtontW = 80;
        CGFloat closeButtontH = 50;
        CGFloat closeButtontX = SCREEN_WIDTH - closeButtontW;
        CGFloat closeButtontY = self.titleLabel.frame.origin.y;
        closeButton.frame = CGRectMake(closeButtontX, closeButtontY, closeButtontW, closeButtontH);
        closeButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [closeButton setTitle:@"观众列表" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClosePage) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];
        
        _closeBtn = closeButton;

    }
    return _closeBtn;
}

@end
