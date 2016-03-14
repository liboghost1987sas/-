//
//  UIImageView+WRRoungImage.m
//  WeRun
//
//  Created by 梦想起飞 on 16/3/2.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "UIImageView+WRRoungImage.h"

@implementation UIImageView (WRRoungImage)
//把头像图片换成圆形
-(void)setRoundlayer{
        self.layer.masksToBounds = YES;// 隐藏边界
        self.layer.cornerRadius = self.bounds.size.width*0.5;// 将图层的边框设置为圆脚
        self.layer.borderWidth = 1;// 给图层添加一个有色边框
        self.layer.borderColor = [[UIColor whiteColor]CGColor];

}
@end
