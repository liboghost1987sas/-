//
//  WRChatViewController.h
//  WeRun
//
//  Created by 梦想起飞 on 16/3/4.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"

@interface WRChatViewController : UIViewController
//要聊天对象的标识
@property(nonatomic,strong)XMPPJID *friendJid;

@end
