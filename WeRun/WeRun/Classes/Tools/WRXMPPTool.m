
//
//  WRXMPPTool.m
//  WeRun
//
//  Created by 梦想起飞 on 16/2/25.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRXMPPTool.h"
#import "WRUserInfo.h"
//后面是开启底层，如果不想用可以不开
#import "DDlog.h"
#import "DDTTYLogger.h"

@interface WRXMPPTool()<XMPPStreamDelegate>{
    WRResultBlock _resultBlock;
}
@end
@implementation WRXMPPTool
singleton_implementation(WRXMPPTool)
/**设置xmpp流*/
-(void)setXMPP{
    self.xmppStream = [[XMPPStream alloc]init];
    //设置代理
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //开启底层发送数据的日志，xmpp的底层是XML数据
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //给头像电子名片模块和头像模块赋值
    self.xmppvCardStore = [XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCard = [[XMPPvCardTempModule alloc]initWithvCardStorage:self.xmppvCardStore];
    self.xmppvCardAvar = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:self.xmppvCard];
    
    //给好友列表模块对象和存储对象赋值
    self.xmppRoserStore = [XMPPRosterCoreDataStorage sharedInstance];
    self.xmppRoser = [[XMPPRoster alloc]initWithRosterStorage:self.xmppRoserStore];
    
    //给消息模块和对应的存储赋值
    self.xmppMsgArchStore = [XMPPMessageArchivingCoreDataStorage  sharedInstance];
    self.xmppMsgArch = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:self.xmppMsgArchStore];
    
    //激活电子名片模块和头像模块
    [self.xmppvCard activate:self.xmppStream];
    [self.xmppvCardAvar activate:self.xmppStream];
    [self.xmppRoser activate:self.xmppStream];
    //激活好友列表
    [self.xmppRoser activate:self.xmppStream];
    //激活消息模块
    [self.xmppMsgArch activate:self.xmppStream];
    
}
//连接到服务器
-(void)connectHost{
    if (!self.xmppStream) {
        [self setXMPP];
        
    }
    //给XMPPStream做一些属性的赋值
    self.xmppStream.hostName = WRXMPPHOSTNAME;
    self.xmppStream.hostPort = WRXMPPPORT;
    //构建一个JID（用户名@域名）
    //判断是登录名还是注册名
    NSString *uname = nil;
    if ([WRUserInfo sharedWRUserInfo].isRegisterType) {
#warning 这里的userRegisterName和userName绝对不能写错，写错就整个逻辑不对了！！！
        
        uname = [WRUserInfo sharedWRUserInfo].userRegisterName;
    }else{
        uname = [WRUserInfo sharedWRUserInfo].userName;
        
    }
    
    
    XMPPJID *myJid = [XMPPJID jidWithUser:uname domain:WRXMPPDOMAIN resource:@"iphone"/*这里写什么都可以只是标记*/];
    self.xmppStream.myJID = myJid;
    //连接到服务器
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"1%@",error);
        
    }
}
//连接成功发送密码
-(void)sendPasswdToHost{
    //发送密码
    NSString *pwd = nil;
    NSError *error = nil;
    if ([WRUserInfo sharedWRUserInfo].isRegisterType) {
        //这是注册密码
#warning 这里的userRegisterPasswd和userPasswd绝对不能写错，写错就整个逻辑不对了！！！
        pwd = [WRUserInfo sharedWRUserInfo].userRegisterPasswd;
        [self.xmppStream registerWithPassword:pwd error:&error];
        
    }else{
        pwd = [WRUserInfo sharedWRUserInfo].userPasswd;
        //这个用密码进行授权
        [self.xmppStream authenticateWithPassword:pwd error:&error];
    }
    
    if (error) {
        NSLog(@"%@",error);
    }
}
//授权成功之后发送密码
-(void)sendOnLine{
    //出席对象，默认代表在线
    XMPPPresence *presence = [XMPPPresence presence];
    [self.xmppStream sendElement:presence];
    
}

#pragma mark -- XMPPStreamDelegate
//注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    if (_resultBlock) {
        _resultBlock(WRXMPPResultTypeRegisterSucce);
    }
}
//注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
     if (_resultBlock && error) {
         _resultBlock(WRXMPPResultTypeRegisterFaild);
     }
}
//连接服务器成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    
    //发送密码
    [self sendPasswdToHost];
}
//连接到服务器失败
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    //下面的是block用的
    if (error && _resultBlock) {
        _resultBlock(WRXMPPResultTypeNetError);
        NSLog(@"2%@",error);
        
    }

//    if([self.deledate respondsToSelector:@selector(WrNetError)]){
//            [self.deledate WrNetError];
//        }
}
//授权成功的方法
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    _resultBlock(WRXMPPResultTypeLoginSucce);
    
    //授权成功就调用代理的成功方法
    //先判断成功了没有，再来调用是否会成功
//    if([self.deledate respondsToSelector:@selector(WrLoginSucce)]){
//        [self.deledate WrLoginSucce];
//        
//    }
    //发送在线消息
    [self sendOnLine];
    
}
//授权失败的方法
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"3%@",error);
    if (error && _resultBlock) {
        _resultBlock(WRXMPPResultTypeLoginFaild);
        
    }
    //授权失败就调用的失败的方法
//    if([self.deledate respondsToSelector:@selector(WrLoginFaild)]){
//        [self.deledate WrLoginFaild];
//        
//    }
}



//用户调用这个方法即可
-(void)userLogin:(WRResultBlock)block;{
    _resultBlock = block;
    //无论之前有没有登录都断开一次
    [self.xmppStream disconnect];
    [self connectHost];
    
}

//用户注册调用的方法，要看到注册的状态 传入一个block即可
-(void)userregister:(WRResultBlock)block{
    _resultBlock = block;
    
    //无论之前xmppStream有没有连接都断开一次
    [self.xmppStream disconnect];
    [self connectHost];
}
@end
