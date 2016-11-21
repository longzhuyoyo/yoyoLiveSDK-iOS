//
//  YoyoSwitchListViewController.m
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/18.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "YoyoSwitchListViewController.h"
#import "YoyoApi.h"
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
@interface YoyoSwitchListViewController ()<UITableViewDelegate, UITableViewDataSource>
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
 *  loadingview
 */
@property (nonatomic, weak) UIActivityIndicatorView *loadingView;
/**
 *  歌手列表模型
 */
@property (nonatomic, readonly, strong) YoyoSingerListRecord *singerListRecord;
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
    // 网络数据回调
    [self handleNetDataCallBack];
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
    [self addCellWithName:@"分享开关" selector:@selector(setThirdShare)];
    [self addCellWithName:@"设置审核版本" selector:@selector(setReviewVersion)];
    [self addCellWithName:@"SDKDebugLog开关" selector:@selector(setDebugLog)];
    [self addCellWithName:@"服务器错误弹出框开关" selector:@selector(setServerErrorMsgPopViewEnable)];
    [self addCellWithName:@"兑换功能开关" selector:@selector(setIsExchangeSupport)];
    [self addCellWithName:@"守护功能开关" selector:@selector(setIsOpenGuardSupport)];
}

#pragma mark - NetDataCallBack
/**
 *  网络数据回调处理
 */
- (void) handleNetDataCallBack {
    __weak typeof(self) weakSelf = self;
    [sdkTool setResponseBlock:^(YoyoBaseResp *response) {
       if ([YoyoServerMethodNameUpdateUserInfo isEqualToString:response.method]) {
            [YoyoPopView createTipLabel:@"更新SDK用户信息成功!"];
           [weakSelf.updateInfoView removeFromSuperview];
       } else if ([YoyoServerMethodNameLogin isEqualToString:response.method]) {
           [weakSelf.viewController.loginView removeFromSuperview];
           [YoyoPopView createTipLabel:@"SDK登录成功!"];
           [weakSelf setUpdateUserInfo];
       }
    }];
}

#pragma mark - Event Response
/**
 *  更新用户信息
 */
-(void) setUpdateUserInfo{
    if (!sdkTool.isLogin) {
        [self.viewController showLoginView];
        [YoyoPopView createTipLabel:@"请先登录SDK!"];
        return;
    }
    YoyoPopView *popView = [[YoyoPopView alloc] init];
    popView.frame = self.view.bounds;
    [popView initYoyoPopViewWithTestFilePlaceNameArr:@[@"AvatarUrl",@"alias"] title:@"更新用户信息" OnClickConfigureBlock:^(NSDictionary *textFileContent) {
        [YoyoApi updateUserAvatarUrl:textFileContent[@"AvatarUrl"] alias:textFileContent[@"alias"]];
    }];
    [self.window addSubview:popView];
    self.updateInfoView = popView;
}

/**
 *  设置房间页是否需要第三方分享页面
 */
-(void) setThirdShare {
    sdkTool.isOpenThirdShare = !sdkTool.isOpenThirdShare;
    
    [YoyoApi setThirdShareEnable:sdkTool.isOpenThirdShare];
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
    
    [YoyoApi setReviewVersion:sdkTool.isOpenReviewVersin];
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
    [YoyoApi logout];
    [YoyoPopView createTipLabel:@"SDK退出登录!"];
    sdkTool.isLogin = NO;
}
/**
 *  log开关
 */
-(void) setDebugLog {
    sdkTool.isOpenLog = !sdkTool.isOpenLog;
    
    [YoyoApi setDebugLogEnable:sdkTool.isOpenLog];
    if (sdkTool.isOpenLog) {
        [YoyoPopView createTipLabel:@"开启SDKLog!"];
    } else {
        [YoyoPopView createTipLabel:@"关闭SDKLog!"];
    }
}
/**
 *  服务器错误提示开关
 *
 */
-(void) setServerErrorMsgPopViewEnable{
    sdkTool.isOpenServierErrorMsgPopView = !sdkTool.isOpenServierErrorMsgPopView;
    
    [YoyoApi setServerErrorMsgPopViewEnable:sdkTool.isOpenServierErrorMsgPopView];
    if (sdkTool.isOpenServierErrorMsgPopView) {
        [YoyoPopView createTipLabel:@"开启房间服务器错误提示功能!"];
    } else {
        [YoyoPopView createTipLabel:@"关闭房间服务器错误提示功能!"];
    }
}
/**
 *  设置是否支持兑换功能
 */
-(void) setIsExchangeSupport{
    sdkTool.isSupportExchange = !sdkTool.isSupportExchange;
    
    [YoyoApi setIsExchangeSupport:sdkTool.isSupportExchange];
    if (sdkTool.isSupportExchange) {
        [YoyoPopView createTipLabel:@"开启房间兑换功能!"];
    } else {
        [YoyoPopView createTipLabel:@"关闭房间兑换功能!"];
    }
}
/**
 *  设置是否支持守护功能
 */
-(void) setIsOpenGuardSupport{
    sdkTool.isSupportGuard = !sdkTool.isSupportGuard;
    
    [YoyoApi setIsOpenGuardSupport:sdkTool.isSupportGuard];
    if (sdkTool.isSupportGuard) {
        [YoyoPopView createTipLabel:@"开启房间守护功能!"];
    } else {
        [YoyoPopView createTipLabel:@"关闭房间守护功能!"];
    }
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
        titleLabel.text = @"房间开关功能页";
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
        [closeButton setTitle:@"关闭页面" forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(onClosePage) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:closeButton];
        
        _closeBtn = closeButton;
    }
    return _closeBtn;
}

-(UIActivityIndicatorView *)loadingView{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:loadingView];
        loadingView.center = self.view.center;
        _loadingView = loadingView;
    }
    return _loadingView;
}

-(YoyoSingerListRecord *)singerListRecord{
    return sdkTool.singerListRecord;
}

@end
