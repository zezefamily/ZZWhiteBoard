//
//  NSData+Safe.h
//  RuiYiEducation
//
//  Created by 精锐少儿在线 on 2018/3/15.
//  Copyright © 2018年 精锐少儿在线. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Safe)

/********safe get object From JSONData method***/
//本类是方便JSON数据直接转为对象类型

// get object
- (nullable id)safe_JSONObj;

- (nullable id)safe_JSONObj_options:(NSJSONReadingOptions)opt;

// get string or nil
// 得到的数据是否是字符串，如果是则返回，否则返回空
- (nullable NSString *)safe_stringJSONObj;

// get array or nil
- (nullable NSArray *)safe_arrayJSONObj;

// get dictionary or nil
- (nullable NSDictionary *)safe_dictionaryJSONObj;

// get number or nil
- (nullable NSNumber *)safe_numberJSONObj;

// get JSONdata from oc object
// 对象转为data
+ (nullable NSData *)safe_JSONDataFromObject:(id _Nonnull)obj;

// get string from  data by encoding UTF8
//得到data的UTF8转码后的字符串
-(NSString *_Nullable)safe_getJSONString_NSUTF8StringEncoding;

// get string from  data by encoding
// 得到data转码后的字符串
-(NSString *_Nullable)safe_getJSONStringWithEncoding:(NSStringEncoding)encoding;

- (NSString *)utf8String;

- (NSData *)UTF8Data;
@end
