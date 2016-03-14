//
//  WRSportRecordTableViewCell.h
//  WeRun
//
//  Created by 梦想起飞 on 16/3/10.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WRSportRecord.h"

@interface WRSportRecordTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sportRecordDate;
@property (weak, nonatomic) IBOutlet UIImageView *sportRecordTypeImageView;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordTimeLen;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordDistance;
@property (weak, nonatomic) IBOutlet UILabel *sportRecordHeat;
//下面的结构不合理但好用 直接用model层来显示
-(void)setSportRecordData:(WRSportRecord *)sportData;


@end
