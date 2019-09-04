//
//  NSData+Safe.m
//  RuiYiEducation
//
//  Created by 精锐少儿在线 on 2018/3/15.
//  Copyright © 2018年 精锐少儿在线. All rights reserved.
//


#define SP_IS_KIND_OF(obj, cls) [(obj) isKindOfClass:[cls class]]

#if DEBUG

#define SP_LOG(...) NSLog(__VA_ARGS__)

#define SP_ASSERT(obj)               assert((obj)) //断言实例对象

#define SP_ASSERT_CLASS(obj, cls)  SP_ASSERT((obj) && SP_IS_KIND_OF(obj,cls))//断言实例有值和类型


#else

#define SP_LOG(...)

#define SP_ASSERT(obj)

#define SP_ASSERT_CLASS(obj, cls)

#endif


#import "NSData+Safe.h"

@implementation NSData (Safe)

- (NSString *)utf8String {
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    if (string == nil) {
        string = [[NSString alloc] initWithData:[self UTF8Data] encoding:NSUTF8StringEncoding];
    }
    return string;
}

//              https://zh.wikipedia.org/wiki/UTF-8
//              https://www.w3.org/International/questions/qa-forms-utf-8
//
//            $field =~
//                    m/\A(
//            [\x09\x0A\x0D\x20-\x7E]            # ASCII
//            | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
//            |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
//            | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
//            |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
//            |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
//            | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
//            |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
//            )*\z/x;

- (NSData *)UTF8Data {
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:self.length];
    
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = self.bytes;
    
    long dataLength = (long) self.length;
    
    while (index < dataLength) {
        uint8_t len = 0;
        uint8_t firstChar = bytes[index];
        
        // 1个字节
        if ((firstChar & 0x80) == 0 && (firstChar == 0x09 || firstChar == 0x0A || firstChar == 0x0D || (0x20 <= firstChar && firstChar <= 0x7E))) {
            len = 1;
        }
        // 2字节
        else if ((firstChar & 0xE0) == 0xC0 && (0xC2 <= firstChar && firstChar <= 0xDF)) {
            if (index + 1 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                if (0x80 <= secondChar && secondChar <= 0xBF) {
                    len = 2;
                }
            }
        }
        // 3字节
        else if ((firstChar & 0xF0) == 0xE0) {
            if (index + 2 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                
                if (firstChar == 0xE0 && (0xA0 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (((0xE1 <= firstChar && firstChar <= 0xEC) || firstChar == 0xEE || firstChar == 0xEF) && (0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                } else if (firstChar == 0xED && (0x80 <= secondChar && secondChar <= 0x9F) && (0x80 <= thirdChar && thirdChar <= 0xBF)) {
                    len = 3;
                }
            }
        }
        // 4字节
        else if ((firstChar & 0xF8) == 0xF0) {
            if (index + 3 < dataLength) {
                uint8_t secondChar = bytes[index + 1];
                uint8_t thirdChar = bytes[index + 2];
                uint8_t fourthChar = bytes[index + 3];
                
                if (firstChar == 0xF0) {
                    if ((0x90 <= secondChar & secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if ((0xF1 <= firstChar && firstChar <= 0xF3)) {
                    if ((0x80 <= secondChar && secondChar <= 0xBF) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                } else if (firstChar == 0xF3) {
                    if ((0x80 <= secondChar && secondChar <= 0x8F) && (0x80 <= thirdChar && thirdChar <= 0xBF) && (0x80 <= fourthChar && fourthChar <= 0xBF)) {
                        len = 4;
                    }
                }
            }
        }
        // 5个字节
        else if ((firstChar & 0xFC) == 0xF8) {
            len = 0;
        }
        // 6个字节
        else if ((firstChar & 0xFE) == 0xFC) {
            len = 0;
        }
        
        if (len == 0) {
            index++;
            [resData appendData:replacement];
        } else {
            [resData appendBytes:bytes + index length:len];
            index += len;
        }
    }
    
    return resData;
}


-(nullable id)safe_JSONObj
{
    return [self safe_JSONObj_options:NSJSONReadingMutableContainers];
}

-(nullable id)safe_JSONObj_options:(NSJSONReadingOptions)opt
{
    SP_ASSERT_CLASS(self,NSData);
    
    id ret = nil;
    if (SP_IS_KIND_OF(self, NSData) && self.length>0) {
        NSError *error;
        ret = [NSJSONSerialization JSONObjectWithData:self options:opt error:&error];
        
        if (error) {
            ret = nil;
            SP_ASSERT(!error);
            SP_LOG(@"JSON to object error %@",error);
        }
    }
    return ret;
}

- (nullable NSString *)safe_stringJSONObj
{
    id ret = [self safe_JSONObj];
    if (SP_IS_KIND_OF(ret, NSString)) {
        return ret;
    }
    return nil;
}

- (nullable NSArray *)safe_arrayJSONObj
{
    id ret = [self safe_JSONObj];
    if (SP_IS_KIND_OF(ret, NSArray)) {
        return ret;
    }
    return nil;
}

- (nullable NSDictionary *)safe_dictionaryJSONObj
{
    id ret = [self safe_JSONObj];
    if (SP_IS_KIND_OF(ret, NSDictionary)) {
        return ret;
    }
    return nil;
}

- (nullable NSNumber *)safe_numberJSONObj
{
    id ret = [self safe_JSONObj];
    if (SP_IS_KIND_OF(ret, NSNumber)) {
        return ret;
    }
    return nil;
}

+ (NSData*)safe_JSONDataFromObject:(id)obj
{
    SP_ASSERT(obj);
    
    NSData *ret = nil;
    NSError *err = nil;
    if (obj) {
        ret = [NSJSONSerialization dataWithJSONObject:obj
                                              options:0
                                                error:&err];
    }
    if (err)
    {
        SP_LOG(@"Object to JsonData Error:%@",err);
        ret = nil;
    }
    return (ret);
}

-(NSString *)safe_getJSONString_NSUTF8StringEncoding
{
    return [self safe_getJSONStringWithEncoding:NSUTF8StringEncoding];
}

-(NSString *)safe_getJSONStringWithEncoding:(NSStringEncoding)encoding
{
    SP_ASSERT_CLASS(self,NSData);
    
    NSString *ret = nil;
    
    if (SP_IS_KIND_OF(self, NSData) && self.length > 0) {
        ret = [[NSString alloc] initWithData:self encoding:encoding];
    }
    return ret;
}

@end
