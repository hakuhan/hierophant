//
//  ViewController.m
//  校外导师管理系统
//
//  Created by 柏涵 on 16/2/22.
//  Copyright © 2016年 柏涵. All rights reserved.
//

#import "ViewController.h"
#import "RegistView.h"
#import "HierophantApply.h"
#import "StudentViewController.h"
#import "HieroViewController.h"
#import "LoginController.h"
#import <AFNetworking.h>
#import "Student.h"
#import "ConnectURL.h"

@interface ViewController (){
    UIButton *_login;
    UIButton *_regist;
    UIButton *_employ;
    NSMutableString *_name;
    NSMutableString *_password;
}

@property(nonatomic)StudentViewController *stuVC;

@end
#define MIDX CGRectGetMidX(self.view.bounds)
#define MAXY CGRectGetMaxY(self.view.bounds)
#define IMAGEMAXY CGRectGetMaxY(_image.frame)

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeAppearance];
}

//初始化
- (void)initializeAppearance {
    self.view.backgroundColor = [UIColor whiteColor];
    
    //图片
    UIImageView *_image = [[UIImageView alloc] init];
    _image.center = CGPointMake(CGRectGetMidX(self.view.frame), 124);
    _image.bounds = CGRectMake(0, 0, 200, 200);
    [_image setImage:[UIImage imageNamed:@"logo"]];
    [self.view addSubview:_image];
    
    //登陆按钮
    _login = [UIButton buttonWithType:UIButtonTypeCustom];
    _login.tag = 11;
    [_login setTitle:@"登陆" forState:UIControlStateNormal];
    [_login setBackgroundColor:[UIColor redColor]];
    _login.center = CGPointMake(MIDX, IMAGEMAXY+(MAXY-IMAGEMAXY)/3);
    _login.bounds = CGRectMake(0, 0, 100, 37);
    _login.layer.cornerRadius = 10;
    //点击事件
    [_login addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_login];
    
    //注册按钮
    _regist = [UIButton buttonWithType:UIButtonTypeCustom];
    _regist.tag = 12;
    _regist.center = CGPointMake(MIDX, CGRectGetMaxY(_login.frame)+(MAXY-CGRectGetMaxY(_login.frame))/4);
    _regist.bounds = CGRectMake(0, 0, 100, 37);
    _regist.layer.cornerRadius = 10;
    [_regist setTitle:@"学生注册" forState:UIControlStateNormal];
    [_regist setBackgroundColor:[UIColor greenColor]];
    [_regist addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_regist];
    
    //应聘导师按钮
    _employ = [UIButton buttonWithType:UIButtonTypeCustom];
    _employ.tag = 13;
    _employ.center = CGPointMake(MIDX, CGRectGetMaxY(_regist.frame)+(MAXY-CGRectGetMaxY(_login.frame))/4);
    _employ.bounds = CGRectMake(0, 0, 100, 37);
    [_employ setTitle:@"导师申请" forState:UIControlStateNormal];
    _employ.layer.cornerRadius = 10;
    [_employ setBackgroundColor:[UIColor blackColor]];
    [_employ addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_employ];
}

//点击事件
- (void)buttonPressed:(UIButton *)sender {
    //登陆弹窗
    if (sender.tag == 11) {
        UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:@"请登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [loginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"用户名";
        }];
        [loginAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"密码";
            textField.secureTextEntry = YES;
        }];
        [loginAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            //释放观察者
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        }]];
        
        __weak typeof(self)weakSelf = self;
        [loginAlert addAction:[UIAlertAction actionWithTitle:@"登陆" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([loginAlert.textFields.firstObject.text isEqualToString:@""] || [loginAlert.textFields.lastObject.text isEqualToString:@""]) {
                [weakSelf addAlert:(NSMutableString *)@"不能为空" message:(NSMutableString *)@"用户名和密码不能为空"];
            } else {
                //登陆过程
                _name = (NSMutableString *)loginAlert.textFields.firstObject.text;
                _password = (NSMutableString *)loginAlert.textFields.lastObject.text;
//              [weakSelf toLogin];
                
                //本地登录
                LoginController *loginController = [[LoginController alloc] init];
                int r = [loginController login:_name password:_password];
                if (r == 0) {
                    [self addAlert:(NSMutableString *)@"登录失败" message:nil];
                } if (r == 1) {
                    //教务
                } if (r == 2) {
                    //老师
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    HieroViewController *hieroView = [storyboard instantiateViewControllerWithIdentifier:@"HieroTabBar"];
                    [self presentViewController:hieroView animated:YES completion:nil];
                } if (r == 3) {
                    //学生
                    StudentViewController *studentView = [[StudentViewController alloc] init];
                    studentView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [self presentViewController:studentView animated:YES completion:nil];
                }
            }
        }]];
        
        [self presentViewController:loginAlert animated:YES completion:nil];
        //注册界面
    } else if (sender.tag == 12) {
        //添加监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(success) name:@"success" object:nil];
        RegistView *registView = [[RegistView alloc] init];
        registView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:registView animated:YES completion:nil];
    } else {
        //导师申请界面
        HierophantApply *hierophant = [[HierophantApply alloc] init];
        hierophant.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:hierophant animated:YES completion:nil];
    }
}

-(void)toLogin {
    __block int r = 0;
    // 启动系统风火轮
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //初始化manager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //获取url
    NSString *url = [ConnectURL shareURL];
    //初始化对象
    Student *stu = [[Student alloc] init];
    stu.name = _name;
    stu.password = _password;
    //将对象转换为json
    NSDictionary *dic = stu.toDictionary;
    //发送post请求
    [manager POST:url parameters:dic progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 隐藏系统风火轮
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (responseObject) {
            //登录结果
            r = (int)[[responseObject objectForKey:@"result"] integerValue];
            if (r == 0) {
                [self addAlert:(NSMutableString *)@"登录失败" message:nil];
            } if (r == 1) {
                //教务
            } if (r == 2) {
                //老师
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                HieroViewController *hieroView = [storyboard instantiateViewControllerWithIdentifier:@"HieroTabBar"];
                [self presentViewController:hieroView animated:YES completion:nil];
            } if (r == 3) {
                //学生
                StudentViewController *studentView = [[StudentViewController alloc] init];
                studentView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:studentView animated:YES completion:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 隐藏系统风火轮
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"获取失败");
    }];
//    return r;
    //判断用户类型
//    int loginType = [loginController login:name password:password];
    
}

-(void)success {
    [self addAlert:(NSMutableString *)@"注册成功" message:(NSMutableString *)@"现在可以登陆了"];
}

-(void)addAlert:(NSMutableString *)title message:(NSMutableString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"success" object:nil];
}

@end
