//
//  NSString+md5.m
//  WeRun
//
//  Created by 梦想起飞 on 16/2/28.
//  Copyright © 2016年 梦想起飞. All rights reserved.
//

#import "NSString+md5.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (md5)
-(NSString *)md5Str{
    //C语言底层
    unsigned char mdc[16];
    //这里写16是因为
    //1字节(b)=8比特(bit)
    //1Byte = 4bit 4bit可以表示一个16进位
    const char *mypasswd = [self UTF8String];
    CC_MD5(mypasswd, (CC_LONG)strlen(mypasswd), mdc);
    NSMutableString *md5String =[NSMutableString string];
    for (int i = 0; i < 16 ; i++ ) {
        [md5String appendFormat:@"%02x",mdc[i]];
    }
    return md5String;
    
}
-(NSString *)md5StrXor{
    //C语言底层
    unsigned char mdc[16];
    //这里写16是因为
    //1字节(b)=8比特(bit)
    //1Byte = 4bit 4bit可以表示一个16进位
    const char *mypasswd = [self UTF8String];
    CC_MD5(mypasswd, (CC_LONG)strlen(mypasswd), mdc);
    NSMutableString *md5String =[NSMutableString string];
    [md5String appendFormat:@"%02x",mdc[0]];
    for (int i = 1; i < 16 ; i++ ) {
        [md5String appendFormat:@"%02x",mdc[i]^mdc[0]];
    }
    return md5String;
}
@end
