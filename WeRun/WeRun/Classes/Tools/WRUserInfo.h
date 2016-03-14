//
//  WRUserInfo.h
//  WeRun
//
//  Created by 梦想起飞 on 16/2/25.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
@interface WRUserInfo : NSObject
singleton_interface(WRUserInfo)
//在整个程序中只需要一个userName和userPasswd，所以用单例模式
@property(nonatomic,copy)NSString *userName;
@property(nonatomic,copy)NSString *userPasswd;


//注册的用户名和密码
@property(nonatomic,copy)NSString *userRegisterName;
@property(nonatomic,copy)NSString *userRegisterPasswd;

//为了区分登录还是注册
@property(nonatomic,assign,getter=isRegisterType) BOOL registerType;

//获取当前对象对应的jidStr
@property(nonatomic,copy)NSString *jidStr;

//区分是不是新浪登录
@property(nonatomic,assign,getter=isSinaLogin/*这是标记是不是新浪登录*/)BOOL sinaLogin;
@end
