//
//  WRMyProfileViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/1.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRMyProfileViewController.h"
#import "XMPPvCardTemp.h"//vCard
#import "WRXMPPTool.h"
#import "WRUserInfo.h"
#import "WREditMyProfileViewController.h"
#import "UIImageView+WRRoungImage.h"

@interface WRMyProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;
- (IBAction)backBtnClick:(id)sender;
- (IBAction)logoutBtnClick:(id)sender;//退出登录

@end

@implementation WRMyProfileViewController

//显示个人信息
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //拿到个人电子信息模型
    XMPPvCardTemp *vCardTemp = [WRXMPPTool sharedWRXMPPTool].xmppvCard.myvCardTemp;
    if(vCardTemp.photo){
        self.headImageView.image = [UIImage imageWithData:vCardTemp.photo];
        
    }else{
        self.headImageView.image = [UIImage imageNamed:@"YY"];
    }
    [self.headImageView setRoundlayer];//导入圆形图片
    self.userNameLabel.text = [WRUserInfo sharedWRUserInfo].userName;
    self.nikeNameLabel.text = vCardTemp.nickname;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//UIStoryboardSegue页面跳转
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //这里写id是因为这里有多个传参目标不能确定传参的目标到底是谁.还有个作用是留着做扩展用
    id destVc =  segue.destinationViewController;
    //开始判定,如果这里不判定可能后面程序会崩溃
    if([destVc isKindOfClass:[WREditMyProfileViewController class]]){
        //强转
        WREditMyProfileViewController *editVc = (WREditMyProfileViewController *)destVc;//WREditMyProfileViewController 这里必须加* 否则出错
        editVc.myProfile = [WRXMPPTool sharedWRXMPPTool].xmppvCard.myvCardTemp;
        

    }
    
}

- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)logoutBtnClick:(id)sender {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[WRXMPPTool sharedWRXMPPTool].xmppStream sendElement:presence];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
    
}

@end
