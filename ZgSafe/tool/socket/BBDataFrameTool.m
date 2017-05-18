//
//  BBDataFrameTool.m
//  SocketTrial
//
//  Created by iXcoder on 13-11-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBDataFrameTool.h"

#define FRAME_LENGTH    12

@interface BBDataFrameTool()
// 平台代码转换
+ (NSData *)highLowByteAt:(NSInteger)ints from:(NSInteger)platform;
// 计算校验码
+ (Byte)getCheckCode:(NSData *)data;

@end

@implementation BBDataFrameTool

// 计算校验码
+ (Byte)getCheckCode:(NSData *)data
{
    
    Byte checkCode = 0x00;
    for (int i = 4; i < [data length]; i++) {
        Byte byte = 0x00;
        [data getBytes:&byte range:NSMakeRange(i, 1)];
        checkCode ^= byte;
    }
//    BBLog(@"%d", checkCode);
    return checkCode;
}

/*!
 *@brief        平台代码转换高低字节
 *@function     highLowByteAt:from:
 *@param        ints        --
 *@param        platform    -- 平台代码
 *@return       (NSData)
 */
+ (NSData *)highLowByteAt:(NSInteger)ints from:(NSInteger)platform
{
    NSMutableData *data = [NSMutableData dataWithCapacity:2];
    Byte high = (platform & 0xFF00) >> 8;
    Byte low = platform & 0xFF;
    [data appendBytes:&high length:1];
    [data appendBytes:&low length:1];
    return data;
}

/**
 * 创建数据包
 * */
+ (NSData *)encodeDataFrame:(BBDataFrame *)df {
    
    NSMutableData *data = [NSMutableData data];
    /***********package header************/
    Byte byte0 = 36;
    [data appendBytes:&byte0 length:1];
    Byte byte1 = 90;
    [data appendBytes:&byte1 length:1];
    Byte byte2 = 71;
    [data appendBytes:&byte2 length:1];
    Byte byte3 = 38;
    [data appendBytes:&byte3 length:1];
    /***********package header************/
    
    // 平台代码
    [data appendData:[BBDataFrameTool highLowByteAt:4 from:df.platform]];
    
    // 版本号
    Byte version = (Byte)df.version;
    [data appendBytes:&version length:1];
    
    // 主功能命令字
    Byte mainCmd = (Byte)df.MainCmd;
    [data appendBytes:&mainCmd length:1];
    
    // 子功能命令字
    Byte subCmd = (Byte)df.SubCmd;
    [data appendBytes:&subCmd length:1];
    
    // 数据长度
    NSUInteger data_len = 0;
    //NSData *realData = df.data;
//    BBLog(@"real data:%@", realData);
    
    if (df.data != nil ) {
        data_len = [df.data length];
    }
    [data appendData:[BBDataFrameTool highLowByteAt:9 from:data_len]];
    // 数据内容
    if (data_len > 0) {
        [data appendData:df.data];
    }
    
    // 校验码
    Byte checkCode = [BBDataFrameTool getCheckCode:data];
    [data appendBytes:&checkCode length:1];
    return data;
}

/*!
 *@brief
 *@function     decodeDataToFrame:
 *@param        <#param1#>
 *@param        <#param2#>
 *@return       <#return#>
 */
+ (BBDataFrame *)decodeDataToFrame:(NSData *)data
{
    BBDataFrame *df = [[BBDataFrame alloc] init];
    Byte *bytes = (Byte *)[data bytes];
    Byte p[2];
    p[0] = bytes[4];
    p[1] = bytes[5];
    // 平台编号
    df.platform = [BBDataFrameTool highLowByteToInt:p];
    // 版本标志
    df.version = bytes[6];
    // 主命令
    df.MainCmd = bytes[7];
    // 子命令
    df.SubCmd = bytes[8];
    
    // 数据长度
    Byte length[2];
    length[0] = bytes[9];
    length[1] = bytes[10];
    NSUInteger len = [BBDataFrameTool highLowByteToInt:length];
    //实际数据
//    NSData *realData = [data subdataWithRange:NSMakeRange(0, len + 11)];
    Byte customData[len];
    for (int i = 11; i < len + 11; i++) {
        customData[i - 11] = bytes[i];
    }
    df.data = [NSData dataWithBytes:customData length:len];
    // 校验码
//    Byte checkCode = bytes[10 + len + 1];
    return [df autorelease];
}

+ (NSInteger)highLowByteToInt:(Byte[2])b
{
//    printf("high:%d, low:%d", b[0], b[1]);
    NSInteger res = (b[0]<<8) & 0xFF00;
    res += b[1]&0x00FF;
    return res;
}

///**
// * 解析数据包 Version:1
// * */
//private static void getByteToFrame_Version_1(byte[] Buff, Frame f) {
//    byte CheckSum = 0;
//    int intDataLen=0;
//    byte[] aryData=null;
//    //取数据长度之最后一位当做长度
//    intDataLen=HighLowToInt(Buff[9], Buff[10]);
//    // 校验码校验
//    CheckSum = Buff[intDataLen+11];
//    //System.out.println(getCheckSum(Buff,intDataLen+11));
//    if (CheckSum == getCheckSum(Buff,intDataLen +11)) {
//        // 平台代码
//        f.Platform = HighLowToInt(Buff[4], Buff[5]);
//        
//        // 版本号
//        f.Version = Buff[6] & 0xFF;
//        
//        // 主功能命令字
//        f.MainCmd = Buff[7];
//        
//        // 子功能命令字
//        f.SubCmd = Buff[8] & 0xFF;
//        
//        // 数据长度
//        intDataLen=HighLowToInt(Buff[9], Buff[10]);
//        
//        if ( intDataLen > 0) {
//			aryData=new byte[intDataLen];
//			
//			System.arraycopy(Buff, 11, aryData, 0, intDataLen);
//			
//			f.aryData=aryData;
//			
//			f.strData=getFrameData(f.aryData);
//        }
//    }
//    else {
//        System.out.println("check sum error!" + intDataLen  );
//    }
//}
//public static String decodeFrameData(byte[] buff) {
//    String strData = "";
//    
//    if(buff!=null){
//        try {
//            strData=new String(buff,"UTF-8");
//        } catch (UnsupportedEncodingException e) {
//            // TODO Auto-generated catch block
//            e.printStackTrace();
//        }
//    }
//    
//    return strData;
//}
//public static String getFrameData(byte[] buff) {
//    return decodeFrameData(buff);
//}
//private static byte getCheckSum(byte[] Buff) {
//    
//    
//    return getCheckSum(Buff ,Buff.length-1);
//}
//private static byte getCheckSum(byte[] Buff,int len) {
//    byte b = 0;
//    
//    for (int i = 4; i < len; i++) {
//        b ^= (0xff&Buff[i]);
//    }
//    
//    return b;
//}
//
///**
// * 数字型转换高低位
// * */
//private static void IntToHighLowByte(byte[] aryData, int intS, int intData) {
//    int hValue = (intData & 0xFF00) >> 8;
//    int lValue = intData & 0xFF;
//    
//    aryData[intS] = (byte) hValue;
//    aryData[intS + 1] = (byte) lValue;
//}
//
///**
// * 高低位转换成数字型
// * */
//public static int HighLowToInt(byte hb, byte lb) {
//    int intH = hb & 0xFF;
//    int intL = lb & 0xFF;
//    
//    String strBinary = DecToBinary(intH, 8)+ DecToBinary(intL, 8);
//    
//    return Integer.valueOf(strBinary, 2);
//}
//
///**
// * 十进制转二进制
// * **/
//public static String DecToBinary(int intDec) {
//    return Integer.toBinaryString(intDec);
//}
//
///**
// * 十进制转二进制
// * **/
//public static String DecToBinary(int intDec, int intLen) {
//    String strBinary = "";
//    String strZ = "";
//    int intStrLen = 0;
//    
//    strBinary = Integer.toBinaryString(intDec);
//    
//    intStrLen = intLen - strBinary.length();
//    
//    if (intStrLen > 0) {
//        for (int i = 0; i < intStrLen; i++) {
//            strZ += "0";
//        }
//        
//        strBinary = strZ + strBinary;
//    }
//    
//    return strBinary;
//}
//public static int parseInt(byte[] data) {
//    return Integer.parseInt(getFrameData(data));
//}
//public static ArrayList<byte[]> split(byte[] src,char sp) {
//    return split(src,(byte)sp);
//}
//public static ArrayList<byte[]> split(byte[] src,byte sp) {
//    ArrayList<byte[]> result = new ArrayList<byte[]>();
//    int p = 0;
//    for ( int i = 0 ; i < src.length; i++) {
//        if(src[i] == sp) {
//            if(p < i) {
//                byte[] temp = new byte[i-p];
//                System.arraycopy(src, p, temp, 0, i-p);
//                result.add(temp);
//            }
//		    else {
//			    //空数据，连接两个\t
//			    result.add(new byte[0]);
//		    }
//            p = i+1;
//        }
//    }
//    if (p < src.length) {
//        byte[] temp = new byte[src.length-p];
//        System.arraycopy(src, p, temp, 0, src.length-p);
//        result.add(temp);
//    }
//    return result;
//}
//
//public static void logln(String str) {
//    System.out.println(str);
//}
//public static void logln() {
//    System.out.println();
//}
//public static void log(String str) {
//    System.out.print(str);
//}
//public static void output(ArrayList<byte[]> datas) {
//    System.out.println(datas.size());
//    for ( byte[] b : datas  ) {
//        logln(new String(b));
//    }
//    System.out.println("-----");
//}
//public static void hexoutput(byte[] datas) {
//    
//    for ( byte b : datas  ) {
//        log(String.format("%02x ", b&0xff));
//    }
//    
//}


@end
