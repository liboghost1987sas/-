//
//  WRFriendCell.h
//  WeRun
//
//  Created by 梦想起飞 on 16/3/2.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WRFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendStatusLabel;

@end
