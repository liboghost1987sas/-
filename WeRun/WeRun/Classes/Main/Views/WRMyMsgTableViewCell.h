//
//  WRMyMsgTableViewCell.h
//  WeRun
//
//  Created by 梦想起飞 on 16/3/5.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WRMyMsgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *textMsgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageMsgView;

@end
