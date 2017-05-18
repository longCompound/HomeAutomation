//
//  util_functions.h
//  iSkinCare
//
//  Created by iXcoder on 13-6-4.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifndef iSkinCare_util_functions_h

#define iSkinCare_util_functions_h


#include <stdio.h>

/*!
 *@brief        检查邮件格式
 *@function     checkMailFormat
 *@param        para        -- 要检测字段
 *@param        flag        -- 返回结果(指针)
 *@return       (void)
 */
static void checkMailFormat(NSString *para, BOOL *flag)
{
    if (para || [para length] <= 1 ) {
        *flag = NO;
    }
    NSString *regexp = @"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@",regexp];
    BOOL f = [predicate evaluateWithObject:para];
    *flag = f;
}

/*!
 *@brief        根据传入字段查找const.plist中的值
 *@function     getConstantValue
 *@param        root        -- 第一个参数
 *@param        ...         -- 可变参数
 *@return       (id)
 */
static id getConstantValue(NSString *root, ...)
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"const" ofType:@"plist"];
//    NSAssert(filePath != nil, @"Can't find file named 'const.plist'");
    
    NSDictionary *fileContent = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableArray *arguements = [[NSMutableArray alloc] initWithObjects:root, nil];
    va_list argues;
    va_start(argues, root);
    id eachObject = nil;
    while ((eachObject = va_arg(argues, id))) {
        if (eachObject!=nil) {
               [arguements addObject:eachObject];
        }else{
            break;
        }
     
    }
    va_end(argues);
    
    if (arguements == nil || [arguements count] == 0) {
        NSLog(@"未指定参数， 返回全部数据");
        return fileContent;
    }
    int index = 0;
    //id rtnValue = nil;
    NSArray *keys = [fileContent allKeys];
    id value = fileContent;
    NSMutableString *seq = [NSMutableString string];
    while (index < [arguements count]) {
        NSString *currentKey = [arguements objectAtIndex:index];
        [seq appendFormat:@"->%@", currentKey];
       // NSUInteger position = [keys indexOfObject:currentKey];
        if (index == NSNotFound) {
            NSLog(@"未能找到对应%@的值", currentKey);
            return nil;
        } else {
            value = [value objectForKey:currentKey];
            if ([value isKindOfClass:[NSString class]]) {
                NSLog(@"查找顺序%@", seq);
                return value;
            }
            keys = [value allKeys];
        }
        index++;
    }
    NSLog(@"查找顺序%@", seq);
    return value;
}


/*!
 *@brief        获取网络地址路径
 *@function     getNetworkPath
 *@param        para        -- 写入urls.plist(root/res/urls.plist)中的参数
 *@return       (NSString)  -- 网络地址路径
 */
static NSString *getNetworkPath(NSString *shortName)
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"urls" ofType:@"plist"];
    if (!filePath) {
        NSLog(@"未找到文件路径.");
        return @"";
    }
    NSDictionary *content = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *host = [content objectForKey:@"host"];
    NSString *relativePath = [[content objectForKey:shortName] objectForKey:@"path"];
    NSString *path = [NSString stringWithFormat:@"%@%@", host, relativePath];
    return path;
}


/*!
 *@brief        检测手机号码格式
 *@function     isMobileNumber
 *@param        mobileNum       -- 要检测字符串
 *@return       (BOOL)          -- 是否手机号码
 */
static BOOL isMobileNumber(NSString *mobileNum)
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


static char base[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
/*

static char* base64_encode(const char* data, int data_len);
static char *base64_decode(const char* data, int data_len);
static char find_pos(char ch);
//*/
//int main(int argc, char* argv[])
//{
//    char *t = "那个abcd你好吗，哈哈，ANMOL";
//    int i = 0;
//    int j = strlen(t);
//    char *enc = base64_encode(t, j);
//    int len = strlen(enc);
//    char *dec = base64_decode(enc, len);
//    printf("\noriginal: %s\n", t);
//    printf("\nencoded : %s\n", enc);
//    printf("\ndecoded : %s\n", dec);
//    free(enc);
//    free(dec);
//    return 0;
//}
/* */

//*

/*!
 *@brief        base64加密
 *@function     base64_encode
 *@param        data        -- 要加密数据
 *@param        data_len    -- 要加密长度
 *@return       (char *)    -- base64 string
 */
static char *base64_encode(const char* data, int data_len)
{
    //int data_len = strlen(data);
    int prepare = 0;
    int ret_len;
    int temp = 0;
    char *ret = NULL;
    char *f = NULL;
    int tmp = 0;
    char changed[4];
    int i = 0;
    ret_len = data_len / 3;
    temp = data_len % 3;
    if (temp > 0)
    {
        ret_len += 1;
    }
    ret_len = ret_len*4 + 1;
    ret = (char *)malloc(ret_len);
    
    if ( ret == NULL)
    {
        printf("No enough memory.\n");
        exit(0);
    }
    memset(ret, 0, ret_len);
    f = ret;
    while (tmp < data_len)
    {
        temp = 0;
        prepare = 0;
        memset(changed, '\0', 4);
        while (temp < 3)
        {
            //printf("tmp = %d\n", tmp);
            if (tmp >= data_len)
            {
                break;
            }
            prepare = ((prepare << 8) | (data[tmp] & 0xFF));
            tmp++;
            temp++;
        }
        prepare = (prepare<<((3-temp)*8));
        //printf("before for : temp = %d, prepare = %d\n", temp, prepare);
        for (i = 0; i < 4 ;i++ )
        {
            if (temp < i)
            {
                changed[i] = 0x40;
            }
            else
            {
                changed[i] = (prepare>>((3-i)*6)) & 0x3F;
            }
            *f = base[changed[i]];
            //printf("%.2X", changed[i]);
            f++;
        }
    }
    *f = '\0';
    
    return ret;
    
}
//
static char find_pos(char ch)
{
    char *ptr = (char*)strrchr(base, ch);//the last position (the only) in base[]
    return (ptr - base);
}
//

/*!
 *@brief        base64解密
 *@function     base64_decode
 *@param        data        -- 要解密数据
 *@param        data_len    -- 要解密长度
 *@return       (char *)    -- base64 string
 */
static char *base64_decode(const char *data, int data_len)
{
    int ret_len = (data_len / 4) * 3;
    int equal_count = 0;
    char *ret = NULL;
    char *f = NULL;
    int tmp = 0;
    int temp = 0;
    char need[3];
    int prepare = 0;
    int i = 0;
    if (*(data + data_len - 1) == '=')
    {
        equal_count += 1;
    }
    if (*(data + data_len - 2) == '=')
    {
        equal_count += 1;
    }
    if (*(data + data_len - 3) == '=')
    {//seems impossible
        equal_count += 1;
    }
    switch (equal_count)
    {
        case 0:
            ret_len += 4;//3 + 1 [1 for NULL]
            break;
        case 1:
            ret_len += 4;//Ceil((6*3)/8)+1
            break;
        case 2:
            ret_len += 3;//Ceil((6*2)/8)+1
            break;
        case 3:
            ret_len += 2;//Ceil((6*1)/8)+1
            break;
    }
    ret = (char *)malloc(ret_len);
    if (ret == NULL)
    {
        printf("No enough memory.\n");
        exit(0);
    }
    memset(ret, 0, ret_len);
    f = ret;
    while (tmp < (data_len - equal_count))
    {
        temp = 0;
        prepare = 0;
        memset(need, 0, 4);
        while (temp < 4)
        {
            if (tmp >= (data_len - equal_count))
            {
                break;
            }
            prepare = (prepare << 6) | (find_pos(data[tmp]));
            temp++;
            tmp++;
        }
        prepare = prepare << ((4-temp) * 6);
        for (i=0; i<3 ;i++ )
        {
            if (i == temp)
            {
                break;
            }
            *f = (char)((prepare>>((2-i)*8)) & 0xFF);
            f++;
        }
    } 
    *f = '\0'; 
    return ret; 
}
//*/

#endif
