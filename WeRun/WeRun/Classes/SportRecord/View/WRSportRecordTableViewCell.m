//
//  WRSportRecordTableViewCell.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/10.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRSportRecordTableViewCell.h"
#import "sporttype.h"
@implementation WRSportRecordTableViewCell

-(void)setSportRecordData:(WRSportRecord *)sportData{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[sportData.sportStartTime doubleValue]];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    format.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [format stringFromDate:date];
    self.sportRecordDate.text = dateStr;
    self.sportRecordDistance.text = sportData.sportDistance;
    self.sportRecordHeat.text = sportData.sportHeat;
    self.sportRecordTimeLen.text = sportData.sportTimeLen;
    self.sportRecordTypeImageView.image = [self getSportimageByType:sportData.sportType];
}
//根据运动类型加载对应的图片
-(UIImage *)getSportimageByType:(enum SportType)type{
    UIImage *image = nil;
    
    switch (type) {
        case SportTypeRun:
            image = [UIImage imageNamed:@"select2"];
            break;
        case SportTypeFree:
            image = [UIImage imageNamed:@"select4"];
            break;
        case SportTypeSkiing:
            image = [UIImage imageNamed:@"select3"];
            break;
        case SportTypeBike:
            image = [UIImage imageNamed:@"select1"];
            break;
        default:
            break;
    }
    return image;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
