//
//  WRRegisterViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/2/26.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRRegisterViewController.h"
#import "WRUserInfo.h"
#import "WRXMPPTool.h"
#import "AFNetworking.h"//AFNetworking的作用是产生web账号
#import "NSString+md5.h"
#import "MBProgressHUD+KR.h"//弹出框
@interface WRRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userRegisterNameField;
@property (weak, nonatomic) IBOutlet UITextField *userRegisterPasswdField;
- (IBAction)registBtnClick:(id)sender;
- (IBAction)backBtnClick:(id)sender;

@end

@implementation WRRegisterViewController


//即将出现的时候
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
#warning TODO:这里一定要会写
    UIImage *imageN = [UIImage imageNamed:@"icon"];
    UIImageView *leftN = [[UIImageView alloc]initWithImage:imageN];
    leftN.frame = CGRectMake(0, 0, 55, 20);
    leftN.contentMode = UIViewContentModeCenter;
    self.userRegisterNameField.leftViewMode = UITextFieldViewModeAlways;
    self.userRegisterNameField.leftView = leftN;
    
    UIImage *imageP = [UIImage imageNamed:@"lock"];
    UIImageView *leftP = [[UIImageView alloc]initWithImage:imageP];
    leftP.frame = CGRectMake(0, 0, 55, 20);
    leftP.contentMode = UIViewContentModeCenter;
    self.userRegisterPasswdField.leftViewMode = UITextFieldViewModeAlways;
    self.userRegisterPasswdField.leftView = leftP;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



- (IBAction)registBtnClick:(id)sender {
    [WRUserInfo sharedWRUserInfo].registerType = YES;
    NSString *rname = self.userRegisterNameField.text;
    NSString *rpasswd = self.userRegisterPasswdField.text;
    //判断用户名和密码不能为空
    if ([rname isEqualToString:@""]||[rpasswd isEqualToString:@""]) {
        [MBProgressHUD showError:@"用户名和密码不能为空"];
        return; 
    }
    [WRUserInfo sharedWRUserInfo].userRegisterName = rname;
    [WRUserInfo sharedWRUserInfo].userRegisterPasswd = rpasswd;
    //调用工具类的方法 完成注册
    __weak typeof (self) vc = self;
    [[WRXMPPTool sharedWRXMPPTool]userLogin:^(WRXMPPResultType type) {
        //处理注册的状态
        [vc handleRegisterType:type];
        
    }];
    
}

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)handleRegisterType:(WRXMPPResultType) type{
    switch (type) {
        case WRXMPPResultTypeRegisterSucce:
            //注册成功还要发起一个web注册，产生web账号
            [self dismissViewControllerAnimated:YES completion:nil];

            [self webRegister];
            
            break;
        case WRXMPPResultTypeRegisterFaild:
            NSLog(@"注册失败");
            break;
        case WRXMPPResultTypeNetError:
            NSLog(@"注册网络错误");
            break;
        default:
            break;
    }
}
//用来产生web账号的注册方法
-(void)webRegister{
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager  manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/register.jsp",WRXMPPHOSTNAME];
    //准备参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [WRUserInfo sharedWRUserInfo].userRegisterName;
    parameters[@"md5password"] = [[WRUserInfo sharedWRUserInfo].userRegisterPasswd md5Str];
    parameters[@"nickname"] = [WRUserInfo sharedWRUserInfo].userRegisterName;
#warning 这里写POST是因为allRunServer服务器用的是POST，如果以后服务器用Get 那下面就不是写POST了
    //是这样理解吗？
    //下面的POST是带文件的POST,不带文件的POST在WRSinaLoginViewController.m里面写了
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
     
        UIImage *headeImage = [UIImage imageNamed:@"YY"];
        NSData *data = UIImagePNGRepresentation(headeImage);
        //这里选appendPartWithFileData是因为传图片的Url需要二进制
        [formData appendPartWithFileData:data name:@"pic"/*这里写什么都可以一般是写“pic”*/ fileName:@"headeImage.png"/*这里写的是网服务器上传完图片以后取得名字*/ mimeType:@"image/jpeg"/*这里是固定写法*/];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //这里说的是请求成功不是注册成功
        NSLog(@"%@",responseObject);//responseObject响应对象
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //这里说的是请求都不成功。
        NSLog(@"请求都不成功%@",error);
    }];
    
}

@end
