//
//  NSString+ITTAdditions.h
//
//  Created by Jack on 11-9-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (ITTAdditions)

- (BOOL)isStartWithString:(NSString*)start;
- (BOOL)isEndWithString:(NSString*)end;

- (NSInteger)numberOfLinesWithFont:(UIFont*)font withLineWidth:(NSInteger)lineWidth;

- (CGFloat)heightWithFont:(UIFont*)font withLineWidth:(NSInteger)lineWidth;

- (NSString*)md5;
- (NSString*)encodeUrl;

+ (NSString*)stringWithFileInMainBundle:(NSString*)fileName ofType:(NSString*)ext;

//-----------------------------------------------------------------------------------
// 安全相关的字符串操作集合，包括
// 1) 3DES加密解密
// 2) Base64编码解码
//-----------------------------------------------------------------------------------

//md5加密
+ (NSString *)encryptPassword:(NSString *)str;

/*!
 * 使用3DES算法对字符串进行加密，加密后使用base64编码
 * 3DES算法要求密钥是24字节长，这里要求一个24个字符的字符串做为参数
 */
- (NSString *)encryptWithKey:(NSString*)key;

/*!
 * 先解码base64，然后使用3DES算法解密
 * 3DES算法要求密钥是24字节长，这里要求一个24个字符的字符串做为参数
 */
- (NSString *)decryptBase64WithKey:(NSString*)key;

/*!
 * 返回一个字符串的base64编码结果
 */
- (NSString *)base64String;

/*!
 * 返回一个二进制数据的base64编码结果
 */
+ (NSString *)encodeBase64WithData:(NSData *)objData;

/*!
 * 将一个base64编码字符串解码成二进制数据
 */
+ (NSData *)decodeBase64WithString:(NSString *)strBase64;

@end

