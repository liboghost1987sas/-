//
//  WRUserInfo.m
//  WeRun
//
//  Created by 梦想起飞 on 16/2/25.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "WRUserInfo.h"

@implementation WRUserInfo
singleton_implementation(WRUserInfo)
-(NSString *)jidStr{
    return [NSString stringWithFormat:@"%@@%@",self.userName,WRXMPPDOMAIN];
    
}
@end
