//
//  WRSinaLoginViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/2/29.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#define  APPKEY       @"2061593926"
#define  REDIRECT_URI @"https://www.hao123.com/"
#define  APPSECRET    @"619cdd97b43359029123e0e73d0629a5"


#import "WRSinaLoginViewController.h"
#import "AFNetworking.h"
#import "WRUserInfo.h"
#import "WRXMPPTool.h"
#import "NSString+md5.h"

@interface WRSinaLoginViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backBtnClick:(id)sender;

@end

@implementation WRSinaLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //按照新浪官方的要求请求Url
    //client_id	true	string	申请应用时分配的AppKey。
    //redirect_uri	true	string	授权回调地址，站外应用需与设置的回调地址一致，站内应用需填写canvas page的地址。
    NSString *url = [NSString stringWithFormat:@"https://api.weibo.com/oauth2/authorize?client_id=%@&redirect_uri=%@",APPKEY,REDIRECT_URI];
    self.webView.delegate = self;
    NSURL *rurl = [NSURL URLWithString:url];
    [self.webView loadRequest:[NSURLRequest requestWithURL:rurl]];
}
//web返回信息
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //这里就可以获得返回url，因为新浪官方文档写的不对，这里返回的url一定是对的
    NSLog(@"返回url%@",request.URL.absoluteString);
    NSString *urlPath = request.URL.absoluteString;
    //把url ?code= 后面的字符串截取下来换另一个令牌
    //这里会、返回很多的url但我只需要一个特定的返回url
    NSRange range = [urlPath rangeOfString:[NSString stringWithFormat:@"%@?code=",REDIRECT_URI]];
    NSString *code = nil;
    //如果range.length>0证明已经找到了特定的返回url
    if (range.length>0) {
        code = [urlPath substringFromIndex:range.length];//开始截取返回的字符串令牌
        NSLog(@"测试返回的url令牌%@",code);
        //使用code换取access_token
        //新写入一个换取access_token的方法
        [self accessTokenWithCode:code];
        //这里不需要返回REDIRECT_URI @"https://www.hao123.com/"，所以写return NO
        return NO;
        
    }
    return YES;
    
}
//访问令牌代码
- (void) accessTokenWithCode:(NSString*)code{
    //导入AFN发请求获得access_token
    NSString *url = @"https://api.weibo.com/oauth2/access_token";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    //dictionary参数是从微博文档http://open.weibo.com/wiki/OAuth2/access_token获取的
    dictionary[@"client_id"] = APPKEY;
    dictionary[@"client_secret"] = APPSECRET;
    dictionary[@"grant_type"] = @"authorization_code";
    dictionary[@"code"] = code;
    dictionary[@"redirect_uri"] = REDIRECT_URI;
    //下面的POST是不带文件的POST,带文件的POST在WRRegisterViewController.m里面写了
    [manager POST:url parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        //把获取的信息转化成程序内部账号
        //把uid作为本项目用户名
        [WRUserInfo sharedWRUserInfo].userRegisterName = responseObject[@"uid"];
        //把access_token作为本项目密码
        [WRUserInfo sharedWRUserInfo].userRegisterPasswd = responseObject[@"access_token"];
        
        [WRUserInfo sharedWRUserInfo].registerType = YES;//让程序知道现在到底是登录还是注册
        
        __weak typeof (self) vc = self;
        [[WRXMPPTool sharedWRXMPPTool] userLogin:^(WRXMPPResultType type) {
            [self handleRegisterResultType:type];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (error) {
            NSLog(@"sina网络错误%@",error);
        }
    }];
}
//处理注册的逻辑
-(void)handleRegisterResultType:(WRXMPPResultType) type{
    switch (type) {
        case WRXMPPResultTypeRegisterSucce:
            //如果需要web账号也应该注册一个
            //注册成功后就登录
            [self webRegister];
            
            break;
        case WRXMPPResultTypeRegisterFaild:
        {
            //web账号注册，无论注册是否成功都登录
            [WRUserInfo sharedWRUserInfo].userName = [WRUserInfo sharedWRUserInfo].userRegisterName;
            [WRUserInfo sharedWRUserInfo].userPasswd = [WRUserInfo sharedWRUserInfo].userRegisterPasswd;
            [WRUserInfo sharedWRUserInfo].registerType = NO;
            __weak typeof (self) vc = self;
            [[WRXMPPTool sharedWRXMPPTool]userLogin:^(WRXMPPResultType type) {
                //把注册好的账号赋值给登录账号！！
                [vc handleLoginResultType:type];
            }];
         }
            break;
        case WRXMPPResultTypeNetError:
            NSLog(@"新浪微博注册网络错误");
            break;

        default:
            break;
    }
}
//处理登录的返回
- (void) handleLoginResultType:(WRXMPPResultType) type{
    switch (type) {
        case WRXMPPResultTypeLoginSucce:{
            //sina方式登录如果成功就做标记
            [WRUserInfo sharedWRUserInfo].sinaLogin = YES;
            UIStoryboard *stroyborad =
            [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [UIApplication sharedApplication].keyWindow.rootViewController = stroyborad.instantiateInitialViewController;
        }
            break;
        case WRXMPPResultTypeLoginFaild:
            NSLog(@"新浪微博登录错误");
            break;
        case WRXMPPResultTypeNetError:
            NSLog(@"新浪微博登录网络错误");
            break;
        default:
            break;
    }
}
//把新浪微博的账号和allRun关联（从WRRegisterViewController.m拷贝过来的）
-(void)webRegister{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager  manager];
    NSString *url = [NSString stringWithFormat:@"http://%@:8080/allRunServer/register.jsp",WRXMPPHOSTNAME];
    //准备参数
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"username"] = [WRUserInfo sharedWRUserInfo].userRegisterName;
    parameters[@"md5password"] = [[WRUserInfo sharedWRUserInfo].userRegisterPasswd md5Str];
    parameters[@"nickname"] = [WRUserInfo sharedWRUserInfo].userRegisterName;
#warning 这里写POST是因为allRunServer服务器用的是POST，如果以后服务器用Get 那下面就不是写POST
    //下面的POST是带文件的POST,不带文件的POST在WRSinaLoginViewController.m里面写了
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        UIImage *headeImage = [UIImage imageNamed:@"YY"];
        NSData *data = UIImagePNGRepresentation(headeImage);
        //这里选appendPartWithFileData是因为传图片的Url需要二进制
        [formData appendPartWithFileData:data name:@"pic"/*这里写什么都可以一般是写“pic”*/ fileName:@"headeImage.png"/*这里写的是网服务器上传完图片以后取得名字*/ mimeType:@"image/jpeg"/*这里是固定写法*/];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //这里说的是请求成功不是注册成功
        NSLog(@"请求成功但注册不成功%@",responseObject);//responseObject响应对象
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //这里说的是请求都不成功。
        NSLog(@"请求都不成功%@",error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
