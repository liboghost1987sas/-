//
//  WRXMPPTool.h
//  WeRun
//
//  Created by 梦想起飞 on 16/2/25.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"
#import "XMPPMessageArchiving.h"//消息归档
#import "XMPPMessageArchivingCoreDataStorage.h"

//定义枚举 代表登录的状态
typedef enum{
    WRXMPPResultTypeLoginSucce,
    WRXMPPResultTypeLoginFaild,
    
    WRXMPPResultTypeNetError,
    
    WRXMPPResultTypeRegisterSucce,
    WRXMPPResultTypeRegisterFaild
}WRXMPPResultType;
//定义block
typedef void(^WRResultBlock)(WRXMPPResultType type);

//定义一个实现登录的协议
//@protocol WRLoginProtocol <NSObject>
//-(void)WrLoginSucce;
//-(void)WrLoginFaild;
//-(void)WrNetError;
//@end
@interface WRXMPPTool : NSObject
singleton_interface(WRXMPPTool)

//负责和服务器交互的主对象
@property(nonatomic,strong)XMPPStream *xmppStream;
//@property(nonatomic,weak) id <WRLoginProtocol> deledate;//这里写weak是因为登录完成后要释放控制器

//增加电子名片模块
@property(nonatomic,strong)XMPPvCardTempModule *xmppvCard;
//增加头像模块
@property(nonatomic,strong)XMPPvCardAvatarModule *xmppvCardAvar;
//对电子名片数据管理的对象
@property(nonatomic,strong)XMPPvCardCoreDataStorage *xmppvCardStore;

//增加好友列表和对应的存储
@property(nonatomic,strong) XMPPRoster *xmppRoser;
@property(nonatomic,strong) XMPPRosterCoreDataStorage *xmppRoserStore;

//增加消息模块和对应的存储
/** 增加消息模块 和 对应的存储 */
@property(nonatomic,strong) XMPPMessageArchiving *xmppMsgArch;
@property(nonatomic,strong) XMPPMessageArchivingCoreDataStorage *xmppMsgArchStore;



//设置xmpp流
-(void)setXMPP;
//连接到服务器
-(void)connectHost;
//连接成功发送密码
-(void)sendPasswdToHost;
//授权成功之后发送密码
-(void)sendOnLine;


//用户调用这个方法登录即可
-(void)userLogin:(WRResultBlock)block;

//用户注册调用的方法，要看到注册的状态 传入一个block即可
-(void)userregister:(WRResultBlock)block;

@end
