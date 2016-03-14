//
//  WRLoginAndRegisterViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/2/25.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRLoginAndRegisterViewController.h"
#import "WRUserInfo.h"
#import "WRXMPPTool.h"
#import "MBProgressHUD+KR.h"//弹出框
@interface WRLoginAndRegisterViewController () /*<WRLoginProtocol>*/
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswdField;
- (IBAction)loginBtnClick:(id)sender;

@end

@implementation WRLoginAndRegisterViewController



//登陆成功应该跳转界面
//-(void)WrLoginSucce{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
//    
//}
//-(void)WrLoginFaild{
//    NSLog(@"登录失败");
//}
//-(void)WrNetError{
//    NSLog(@"网络错误");
//}


//即将出现的时候
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#warning TODO:这里一定要会写
    UIImage *imageN = [UIImage imageNamed:@"icon"];
    UIImageView *leftN = [[UIImageView alloc]initWithImage:imageN];
    leftN.frame = CGRectMake(0, 0, 55, 20);
    leftN.contentMode = UIViewContentModeCenter;
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    self.userNameField.leftView = leftN;
    
    UIImage *imageP = [UIImage imageNamed:@"lock"];
    UIImageView *leftP = [[UIImageView alloc]initWithImage:imageP];
    leftP.frame = CGRectMake(0, 0, 55, 20);
    leftP.contentMode = UIViewContentModeCenter;
    self.userPasswdField.leftViewMode = UITextFieldViewModeAlways;
    self.userPasswdField.leftView = leftP;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
//    [WRXMPPTool sharedWRXMPPTool].deledate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



- (IBAction)loginBtnClick:(id)sender {
    [WRUserInfo sharedWRUserInfo].registerType = NO;
    WRUserInfo *userInfo = [WRUserInfo sharedWRUserInfo];
    userInfo.userName = self.userNameField.text;
    userInfo.userPasswd = self.userPasswdField.text;
    // 判断登录名和密码不能为空
    if (self.userNameField.text.length == 0||self.userPasswdField.text.length == 0) {
        [MBProgressHUD showError:@"用户名和密码不能为空"];
        return;
    }
    [MBProgressHUD showMessage:@"正在登陆>>>"];//这里注意如果不手动关闭，MBProgressHUD是永远不会关闭的
    //点击登录按钮 调用工具类的登录方法
#warning 这里看看
#warning 这里记住，是考点！！！
    __weak typeof (self) vc = self;
  //  如果不传block就把下面的代码注释掉
    [[WRXMPPTool sharedWRXMPPTool] userLogin:^(WRXMPPResultType type) {
        /**
         *  这里什么状态做什么事情
         */
        //在block里用self会发生循环引用的问题
        [vc handleLoginResultType:type];//这样写是有问题的
        
    }];
    //如果注释掉了，就和协议没关联了，所以要加代码
    //代理要和WRXMPPTool联系起来
//    [[WRXMPPTool sharedWRXMPPTool] userLogin:nil];
    
    
}
//处理登录的返回状态
-(void)handleLoginResultType:(WRXMPPResultType) type{
    //隐藏提示框
     [MBProgressHUD hideHUD];
    switch (type) {
           
            
        case WRXMPPResultTypeLoginSucce:
        { NSLog(@"登录成功");
            //切换到主界面
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
        }
            break;
        case WRXMPPResultTypeLoginFaild:
            NSLog(@"登录失败");
            break;
        case WRXMPPResultTypeNetError:
            NSLog(@"网络错误");
            break;
        default:
            break;
    }
}
//证明这个控制器销毁或释放
-(void)dealloc{
    NSLog(@"登录控制器%@销毁了",self);
}
@end
