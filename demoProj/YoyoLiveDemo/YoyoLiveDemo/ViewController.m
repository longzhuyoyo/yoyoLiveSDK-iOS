//
//  ViewController.m
//  YoyoLiveDemo
//
//  Created by kaso on 16/10/16.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "ViewController.h"
#import "SingerCell.h"
#import "YoyoPopView.h"
#import "AFServer.h"
#import "YoyoSdkTool.h"
#import "YoyoSwitchListViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SINGER_CELL_WIDTH ((SCREEN_WIDTH - 30) / 2)
#define SINGER_CELL_HEIGHT (SINGER_CELL_WIDTH * 114 / 147)
#define StringIsEmpty(string) ((string) == nil || (string).length == 0)

@interface ViewController ()< UICollectionViewDelegate, UICollectionViewDataSource,YoyoSdkToolDelegate>
/**
 *  歌手列表
 */
@property (nonatomic, strong) YoyoSingerListRecord *singerListRecord;
/**
 *  collectionView
 */
@property (nonatomic, weak) UICollectionView *collectionView;
/**
 *  标题
 */
@property (nonatomic, weak) UILabel *titleLabel;
/**
 *  keyWindow
 */
@property (nonatomic, strong) UIWindow *window;
/**
 *  用户昵称
 */
@property (nonatomic, strong) NSString *userName;
/**
 *  兑换弹框
 */
@property (nonatomic, weak) YoyoPopView *exchangeView;
/**
 *  是否点击兑换按钮
 */
@property (nonatomic, unsafe_unretained) BOOL pendingExchange;
/**
 *  开关列表页button
 */
@property (nonatomic, strong) UIButton *switchListButton;
/**
 *  登录页面
 */
@property (nonatomic, weak) YoyoPopView *loginView;
@end

@implementation ViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 初始化子控件
    [self initSubViews];
}

/**
 *  如果sdk工具类的回调block在多个控制器使用需要卸载viewwillappear里,如果在viewdidload中只在控制器创建的时候会覆盖代理,在回到某个控制器时会出现覆盖
 *
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [YoyoSdkTool shareInstance].delegate = self;
}
- (void) initSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    [self titleLabel];
    [self switchListButton];
    [self collectionView];
    [YoyoPopView startLoadingViewWithSuperView:self.view];
}

#pragma mark - YoyoSdkToolDelegate
- (void) yoyoSdkToolShowLoginView {
    [self showLoginView];
}

- (void) yoyoSdkToolShowExchangeView {
    [self showExchangeView];
}

- (void) yoyoSdkToolCallBackSingerListDataWithSingerRecord:(YoyoSingerListRecord*)singerListRecord {
    self.singerListRecord = singerListRecord;
    [self.collectionView reloadData];
    [YoyoPopView endLoadingView];
}

- (void) yoyoSdkToolCallBackShareData:(id)data{
    [self shareData:data];
}

- (void) yoyoSdkToolCallBackErrorData:(id)errorData {
    NSLog(@"statusStr = %@",errorData);
}

- (void) yoyoSdkToolCallBackWhenLoginSuccess {
    [YoyoPopView createTipLabel:@"SDK登录成功!"];
    [self.loginView removeFromSuperview];
    if (self.pendingExchange) {
        [self showExchangeView];
    }
}

- (void) yoyoSdkToolCallBackWhenExchangerSuccess {
    [YoyoPopView createTipLabel:@"SDK兑换成功!"];
    [self.exchangeView removeFromSuperview];
}
#pragma mark - colletionDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.singerListRecord.list.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SingerCell *singerCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SingerCell" forIndexPath:indexPath];
    [singerCell setData:self.singerListRecord.list[indexPath.item]];
    return singerCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YoyoSingerDetailRecord *singerRecord = self.singerListRecord.list[indexPath.item];
    [YoyoSdkTool yoyoSdkToolEnterRoomWithRoomID:singerRecord.roomId];
}

#pragma mark - Privite Method
/**
 *  登录处理
 */
- (YoyoPopView*) showLoginView {
    YoyoPopView *popView = [[YoyoPopView alloc] init];
    popView.frame = self.view.bounds;
    __weak typeof(self) weakSelf = self;
    [popView initYoyoPopViewWithTestFilePlaceNameArr:@[@"用户名",@"密码"] title:@"登录" OnClickConfigureBlock:^(NSDictionary *textFileContent) {
        NSString *url = @"http://ready.xcyo.com/test/app-login";
        [AFServer HttpPost:url params:@{@"name":textFileContent[@"用户名"],@"pwd":textFileContent[@"密码"]} success:^(NSDictionary *response) {
            if ([response[@"s"] integerValue] == 10000) {
                NSString *openID = response[@"d"][@"user"][@"openId"];
                NSString *token = response[@"d"][@"user"][@"token"];
                weakSelf.userName = response[@"d"][@"user"][@"name"];
                if (StringIsEmpty(openID) || StringIsEmpty(token)) {
                    return ;
                }
                [YoyoSdkTool yoyoSdkToolLoginWithOpenID:openID token:token];
            } else {
                [YoyoPopView createTipLabel:@"SDK登录失败!"];
            }
        } error:^(id response) {
            NSLog(@"error = %@",response);
            [YoyoPopView createTipLabel:@"SDK登录失败!"];
        }];
    } onCancel:^{
        weakSelf.pendingExchange = NO;
    }];
    [self.window addSubview:popView];
    
    self.loginView = popView;
    return popView;
}

/**
 *  兑换处理
 */
- (void) showExchangeView {
    if (!self.userName) {
        [self showLoginView];
        [YoyoPopView createTipLabel:@"请先登录SDK"];
        self.pendingExchange = YES;
        return;
    }
    self.pendingExchange = NO;
    YoyoPopView *popView = [[YoyoPopView alloc] init];
    popView.frame = self.view.bounds;
    __weak ViewController *weakSelf = self;
    [popView initYoyoPopViewWithTestFilePlaceNameArr:@[@"金额"] title:@"兑换" OnClickConfigureBlock:^(NSDictionary *textFileContent) {
        NSString *url = @"http://ready.xcyo.com/test/app-exchange";
        [AFServer HttpPost:url params:@{@"name":weakSelf.userName,@"amount":textFileContent[@"金额"]} success:^(NSDictionary *response) {
            if ([response[@"s"] integerValue] == 10000) {
                NSString *orderID = response[@"d"][@"transactionId"];
                NSString *token = response[@"d"][@"user"][@"token"];
                NSInteger amount = [response[@"d"][@"amount"]integerValue];
                if (StringIsEmpty(orderID) || StringIsEmpty(token) || amount <= 0) {
                    [YoyoPopView createTipLabel:@"输入字符不合法!"];
                    return ;
                }
                [YoyoSdkTool yoyoSdkToolExchangeWithMount:amount orderId:orderID token:token];
            } else {
                [YoyoPopView createTipLabel:@"SDK兑换失败!"];
            }
        } error:^(id response) {
            NSLog(@"error = %@",response);
            [YoyoPopView createTipLabel:@"SDK兑换失败!"];
        }];
    }];
    [self.window addSubview:popView];
    
    self.exchangeView = popView;
}

/**
 *  分享处理
 *
 *  @param data 分享数据
 */
- (void) shareData:(id)data {
    YoyoShareType shareType = (YoyoShareType)[data[@"type"] integerValue];
    NSLog(@"data = %@",data);
    switch (shareType) {
        case YoyoShareTypeQqFriend:
            [YoyoPopView createTipLabel:@"qq"];
            break;
        case YoyoShareTypeQZone:
            [YoyoPopView createTipLabel:@"qq空间"];
            break;
        case YoyoShareTypeWX:
            [YoyoPopView createTipLabel:@"微信"];
            break;
        case YoyoShareTypeWXTimeLine:
            [YoyoPopView createTipLabel:@"朋友圈"];
            break;
        case YoyoShareTypeXinLang:
            [YoyoPopView createTipLabel:@"新浪"];
            break;
        case YoyoShareTypePasteBoard:
            [YoyoPopView createTipLabel:@"剪切板"];
            break;
        default:
            break;
    }
}

- (void) jumpToSwitchListViewControler {
    YoyoSwitchListViewController *switchVC = [[YoyoSwitchListViewController alloc] init];
    switchVC.viewController = self;
    [self presentViewController:switchVC animated:YES completion:nil];
}

#pragma mark - setter Or Getter
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 38, 0, 0)];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.text = @"观众列表";
        [titleLabel sizeToFit];
        [self.view addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UIButton *)switchListButton {
    if (!_switchListButton) {
        UIButton *switchListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat switchListButtonW = 150;
        CGFloat switchListButtonH = 60;
        CGFloat switchListButtonX = SCREEN_WIDTH - switchListButtonW;
        CGFloat switchListButtonY = 15;
        switchListButton.frame = CGRectMake(switchListButtonX, switchListButtonY, switchListButtonW, switchListButtonH);
        switchListButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [switchListButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [switchListButton setTitle:@"SDK其他功能" forState:UIControlStateNormal];
        [switchListButton addTarget:self action:@selector(jumpToSwitchListViewControler) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:switchListButton];
        _switchListButton = switchListButton;
    }
    return _switchListButton;
}
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(SINGER_CELL_WIDTH, SINGER_CELL_HEIGHT);
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.minimumLineSpacing = 10;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerNib:[UINib nibWithNibName:@"SingerCell" bundle:nil] forCellWithReuseIdentifier:@"SingerCell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.view addSubview:collectionView];
    }
    return _collectionView;
}

-(UIWindow *) window{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (keyWindow) {
        _window = keyWindow;
    }
    return _window;
}
@end
