//
//  WREditMyProfileViewController.h
//  WeRun
//
//  Created by 梦想起飞 on 16/3/1.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"XMPPvCardTemp.h"


@interface WREditMyProfileViewController : UIViewController
//用来存储用户个人信息
@property (nonatomic,strong)XMPPvCardTemp *myProfile;

@end
