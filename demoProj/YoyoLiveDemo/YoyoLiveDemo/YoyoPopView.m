//
//  YoyoPopView.m
//  YoyoLiveDemo
//
//  Created by fanqile on 16/10/17.
//  Copyright © 2016年 xcyo. All rights reserved.
//

#import "YoyoPopView.h"
//屏幕宽度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define COLOR_RGBA(r, g, b, a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha: a/255.f]
#define COLOR_MAIN_ORANGE COLOR_RGB(255, 132, 0)
#define WEAK_SELF __weak typeof(self) weakSelf = self

@interface YoyoPopView ()

@property (nonatomic, strong) OnClickConfigureBlock configureCallBack;
@property (nonatomic, strong) OnClickCancelBlock onCancelBlock;

/**
 *  存储texFile中的站位字符串
 */
@property(nonatomic, strong) NSMutableArray *inputViewArr;
/**
 *  布局是上一个inputView
 */
@property (nonatomic, strong) UIView *lastView;
/**
 *  UITextFild的容器
 */
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSArray *nameArr;

@property (nonatomic, strong) UITextView *textView;

@end
@implementation YoyoPopView

#pragma mark -Life Cycle

+ (instancetype) YoyoPopView {
    YoyoPopView *popView = [[YoyoPopView alloc] init];
    return popView;
}

- (instancetype) init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    }
    return self;
}
-(void) initYoyoPopViewWithTestFilePlaceNameArr:(NSArray*)NameArr title:(NSString*)title OnClickConfigureBlock:(OnClickConfigureBlock)configureCallBack{
    [self initYoyoPopViewWithTestFilePlaceNameArr:NameArr title:title OnClickConfigureBlock:configureCallBack onCancel:nil];
}

-(void) initYoyoPopViewWithTestFilePlaceNameArr:(NSArray*)NameArr title:(NSString*)title OnClickConfigureBlock:(OnClickConfigureBlock)configureCallBack onCancel:(OnClickCancelBlock) onCancel{
    self.configureCallBack = configureCallBack;
    self.onCancelBlock = onCancel;
    
    self.nameArr = NameArr;
    
    for (NSString *NameStr in NameArr) {
        [self addTestTextFile:NameStr];
    }
    [self addTestTextFile:@"确认"];
    [self addTestTextFile:@"取消"];
    
    UIView *contentView = [[UIView alloc] init];
    [self addSubview:contentView];
    contentView.backgroundColor = [UIColor grayColor];
    self.contentView = contentView;
    CGFloat inputViewH = 70;
    CGFloat buttonH = 50;
    CGFloat titleLabelContentH = 80;
    CGFloat contentViewX = 10;
    CGFloat contentViewY = 100;
    CGFloat contentViewW = SCREEN_WIDTH - 2 * contentViewX;
    CGFloat contentViewH = NameArr.count * inputViewH + titleLabelContentH + 2 *buttonH;
    contentView.frame = CGRectMake(contentViewX, contentViewY, contentViewW, contentViewH);
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [contentView addSubview:titleLabel];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:30];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    CGFloat titleLabelW = contentViewW;
    CGFloat titleLabelH = 60;
    CGFloat titleLabelY = 20;
    CGFloat titleLabelX = (contentViewW - titleLabelW) * 0.5;
    titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    WEAK_SELF;
    CGFloat marginTop = 10;
    [self.inputViewArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *inputView = [[UIView alloc] init];
        [contentView addSubview:inputView];
        if (idx == 0) {
            inputView.frame = CGRectMake(0, marginTop + titleLabelContentH, contentViewW, (inputViewH - 2 * marginTop));
            weakSelf.lastView = inputView;
            [weakSelf addSubViewsTo:inputView name:obj];
        } else {
            inputView.frame = CGRectMake(0, CGRectGetMaxY(weakSelf.lastView.frame) + marginTop, contentViewW, (buttonH - marginTop));
            weakSelf.lastView = inputView;
            if (idx < weakSelf.inputViewArr.count - 2) {
                [weakSelf addSubViewsTo:inputView name:obj];
            } else {
                [weakSelf addMakeSureButton:inputView name:obj];
            }
        }
    }];
    
}

/**
 *  弹框label
 *
 *  @param tipStr 提示字符串
 */
+ (void) createTipLabel:(NSString*)tipStr {
    UILabel *label = [[UILabel alloc] init];
    label.text = tipStr;
    label.font = [UIFont systemFontOfSize:30];
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor whiteColor];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    CGRect tipStrRect = [tipStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:30.0]} context:nil];
    CGFloat labelW = tipStrRect.size.width + 20;
    CGFloat labelH = tipStrRect.size.height + 20;
    CGFloat labelX = (SCREEN_WIDTH - labelW) * 0.5;
    CGFloat labelY = (SCREEN_HEIGHT - labelH) * 0.5;
    label.frame = CGRectMake(labelX, labelY, labelW, labelH);
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:label];
    
    [UIView animateWithDuration:2 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

/**
 *  点击空白退出编辑状态
 */
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self makeAllTextFileEndEdit];
    [self.textView setEditable:YES];
}

#pragma mark Event Response
/**
 *  button点击事件
 *
 *  @param button button
 */
-(void) onClickMarkSure:(UIButton*)button {
    if ([button.titleLabel.text isEqualToString:@"取消"]) {
        [self removeFromSuperview];
        [self.inputViewArr removeAllObjects];
        if (self.onCancelBlock) {
            self.onCancelBlock();
        }
        return;
    }
    
    NSMutableDictionary *callBackParams = [NSMutableDictionary dictionary];
    
    for (NSString *placeName in self.nameArr) {
        callBackParams[placeName] = [self getTextFieldContentFrom:placeName];
    }
    if (self.configureCallBack) {
        self.configureCallBack(callBackParams);
    }
    [self.inputViewArr removeAllObjects];
}

#pragma mark - Privite Method
/**
 *  向数组中添加textFile数据
 *
 *  @param content textFile内容
 */
-(void) addTestTextFile:(NSString*)content {
    [self.inputViewArr addObject:content];
}
/**
 *  创建inpuview子控件
 *
 *  @param inputView inputview
 *  @param name      textFiled的placeholder
 */
-(void) addSubViewsTo:(UIView*)inputView name:(NSString*)name{
    UITextField *textField = [[UITextField alloc] init];
    [inputView addSubview:textField];
    textField.userInteractionEnabled = YES;
    textField.placeholder = name;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    CGFloat textFieldH = 44;
    CGFloat textFildX = 10;
    CGFloat textFildW = inputView.frame.size.width - 2 * textFildX;
    textField.frame = CGRectMake(textFildX, 0, textFildW, textFieldH);
}
/**
 *  创建确定和取消button
 *
 *  @param inputView inputView
 *  @param name      button的title
 */
-(void) addMakeSureButton:(UIView*)inputView name:(NSString*)name{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [inputView addSubview:button];
    [button setTitle:name forState:UIControlStateNormal];
    CGFloat buttonX = 10;
    CGFloat buttonY = 0;
    CGFloat buttonW = inputView.frame.size.width - 2 * buttonX;
    CGFloat buttonH = inputView.frame.size.height;
    button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    button.layer.cornerRadius = 2;
    button.backgroundColor = [UIColor colorWithRed:(255 / 255.0) green:(217 / 255.0) blue:(0 / 255.0) alpha:1];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(onClickMarkSure:) forControlEvents:UIControlEventTouchUpInside];
}
/**
 *  遍历结束textFile编辑状态
 */
- (void) makeAllTextFileEndEdit {
    for (UIView *inpuView in self.contentView.subviews) {
        for (id textField in inpuView.subviews) {
            if ([textField isKindOfClass:[UITextField class]]) {
                [textField endEditing:YES];
            }
        }
    }
    
    [self.inputViewArr removeAllObjects];
}
/**
 *  遍历获取相应textFile的输入内容
 *
 *  @param textFieldPlaceName placeholder
 *
 *  @return textFile输入内容
 */
- (NSString*) getTextFieldContentFrom:(NSString*)placeholder {
    for (UIView *inpuView in self.contentView.subviews) {
        for (id textField in inpuView.subviews) {
            if ([textField isKindOfClass:[UITextField class]]) {
                UITextField *textFileCopy = (UITextField*)textField;
                if ([textFileCopy.placeholder isEqualToString:placeholder]) {
                    return textFileCopy.text;
                }
            }
        }
    }
    return nil;
}

#pragma mark -Setter OrGetter

- (NSMutableArray *) inputViewArr {
    if (!_inputViewArr) {
        _inputViewArr = [NSMutableArray array];
    }
    return _inputViewArr;
}
@end
