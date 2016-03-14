//
//  WRSportRecord.h
//  WeRun
//
//  Created by 梦想起飞 on 16/3/10.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sporttype.h"

@interface WRSportRecord : NSObject
@property(nonatomic,assign)enum SportType sportType;
@property(nonatomic,strong)NSString *sportTimeLen;//运动时间为什么用NSString不用double，在界面上是Label是nsstring
@property(nonatomic,copy)NSString *sportDistance;
@property(nonatomic,copy)NSString *sportHeat;
@property(nonatomic,copy)NSString *username;
@property(nonatomic,copy)NSString *sportStartTime;
@end
