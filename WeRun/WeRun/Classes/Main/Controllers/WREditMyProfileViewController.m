//
//  WREditMyProfileViewController.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/1.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WREditMyProfileViewController.h"
#import "WRXMPPTool.h"
#import "UIImageView+WRRoungImage.h"

@interface WREditMyProfileViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *nikeNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
- (IBAction)editBtnClick:(id)sender;

@end

@implementation WREditMyProfileViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.myProfile.photo) {
        self.headImageView.image = [UIImage imageWithData:self.myProfile.photo];
    }else{
        self.headImageView.image = [UIImage imageNamed:@"YY"];
    }
    //把下面一段话放到UIImageView+WRRoungImage.m里
//    self.headImageView.layer.masksToBounds = YES;// 隐藏边界
//    self.headImageView.layer.cornerRadius = self.headImageView.bounds.size.width*0.5;// 将图层的边框设置为圆脚
//    self.headImageView.layer.borderWidth = 1;// 给图层添加一个有色边框
//    self.headImageView.layer.borderColor = [[UIColor whiteColor]CGColor];
    [self.headImageView setRoundlayer];//导入圆形图片
    // 打开用户交互
    self.headImageView.userInteractionEnabled = YES;
    //增加手势
    [self.headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageTap)]];
    
    self.nikeNameField.text = self.myProfile.nickname;
    self.emailField.text = self.myProfile.mailer;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark  -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
   
    if (buttonIndex == 2) {
        NSLog(@"取消");
        
    }else if(buttonIndex == 1){
        NSLog(@"相册");
   UIImagePickerController *pc = [[UIImagePickerController alloc]init];
        pc.allowsEditing = YES;
        pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//相册
        pc.delegate = self;
        [self presentModalViewController:pc animated:YES];
        
    }else{
        NSLog(@"相机");
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])/*这里如果是真机就不用判定，模拟器就需要判断，没有摄像头就不开启方法*/ {
            UIImagePickerController *pc = [[UIImagePickerController alloc]init];
            pc.allowsEditing = YES;
            pc.sourceType = UIImagePickerControllerSourceTypeCamera;//相机
            pc.delegate = self;
            [self presentModalViewController:pc animated:YES];
        }
    }
}
//选择图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(nonnull NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headImageView.image = image;//关键的一句话
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)headImageTap{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机" otherButtonTitles:@"相册", nil];
    [sheet showInView:self.view];
    
}
- (IBAction)editBtnClick:(id)sender {
    self.myProfile.nickname = self.nikeNameField.text;
    self.myProfile.mailer = self.emailField.text;
    UIImage *image = self.headImageView.image;//原先这里是写死的图片现在改了
    self.myProfile.photo = UIImagePNGRepresentation(image);
    //使用xmppvCard更新数据
    [[WRXMPPTool sharedWRXMPPTool].xmppvCard updateMyvCardTemp:self.myProfile];
    //让此界面消失，跳回上一个界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
@end
