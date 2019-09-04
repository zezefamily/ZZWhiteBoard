//
//  NSDictionary+Safe.m
//  RuiYiEducation
//
//  Created by 精锐少儿在线 on 2018/3/15.
//  Copyright © 2018年 精锐少儿在线. All rights reserved.
//

#define VALUE_FOR_KEY(key, func1, func2)  {\
if (![self isKindOfClass:[NSDictionary class]]||!key) {\
return (0.0f);\
}\
id _ret = [self objectForKey:key];\
if ([_ret isKindOfClass:[NSNumber class]]) {\
return ([(NSNumber *)_ret func1]);\
} else if ([_ret isKindOfClass:[NSString class]]) {\
return ([(NSString *)_ret func2]);\
}\
}



#define JR_IS_KIND_OF(obj, cls) [(obj) isKindOfClass:[cls class]]

#if DEBUG

#define JR_LOG(...) NSLog(__VA_ARGS__)

#define JR_ASSERT(obj)               assert((obj)) //断言实例对象

#define JR_ASSERT_CLASS(obj, cls)  JR_ASSERT((obj) && JR_IS_KIND_OF(obj,cls))//断言实例有值和类型，断言只在debug下有效，为了是开发者在debug下就发现问题


#else

#define JR_LOG(...)

#define JR_ASSERT(obj)

#define JR_ASSERT_CLASS(obj, cls)

#endif





#import "NSDictionary+Safe.h"

@implementation NSDictionary (Safe)

- (nullable id)safe_objectForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    if (JR_IS_KIND_OF(self, NSDictionary) && key) {
        return [self objectForKey:key];
    }
    return nil;
}

- (nullable NSString *)safe_stringForKey:(id)key
{
    //为什么要每个里面都加断言呢，原因是如果只在上一个safe_objectForKey里面加断言不能马上知道到底是哪个方法调用的，在每个里面加断言可以离开知道是调用的哪个方法
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSString *ret=nil;
    
    id object = [self safe_objectForKey:key];
    
    if (JR_IS_KIND_OF(object, NSString))
    {
        ret = (NSString *)object;
    }
    else if (JR_IS_KIND_OF(object, NSNumber))
    {
        ret = [object stringValue];
    }
    else if (JR_IS_KIND_OF(object, NSURL))
    {
        ret = [(NSURL *)object absoluteString];
    }
    else
    {
        ret = [object description];
    }
    
    return (ret);
}

- (nullable NSArray *)safe_arrayForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSArray *ret = nil;
    
    id object = [self safe_objectForKey:key];
    if (object && JR_IS_KIND_OF(object, NSArray))
    {
        ret = object;
    }
    
    return (ret);
}

- (nullable NSDictionary *)safe_dictionaryForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSDictionary *ret = nil;
    
    id object = [self safe_objectForKey:key];
    if (object && JR_IS_KIND_OF(object, NSDictionary))
    {
        ret = object;
    }
    
    return (ret);
}

- (nullable NSNumber *)safe_numberForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSNumber *ret = nil;
    
    id object= [self safe_objectForKey:key];
    if (object&&JR_IS_KIND_OF(object, NSNumber))
    {
        ret = object;
    }
    
    return (ret);
}

- (nullable NSData *)safe_dataForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSData *ret = nil;
    id object= [self safe_objectForKey:key];
    if (object&&JR_IS_KIND_OF(object, NSData))
    {
        ret = object;
    }
    
    return (ret);
}

- (NSInteger)safe_integerForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    VALUE_FOR_KEY(key, integerValue,integerValue);
    return (0);
}

- (int)safe_intForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    VALUE_FOR_KEY(key, intValue, intValue);
    return (0);
}

- (long)safe_longForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    VALUE_FOR_KEY(key, longValue, integerValue);
    return (0);
}

- (long long)safe_longLongForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    VALUE_FOR_KEY(key, longLongValue,longLongValue);
    return (0);
}

- (double)safe_doubleForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    VALUE_FOR_KEY(key, doubleValue,doubleValue);
    return (0.0f);
}

- (float)safe_floatForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    VALUE_FOR_KEY(key, floatValue,floatValue);
    return (0.0f);
}

- (BOOL)safe_boolForKey:(id)key
{
    JR_ASSERT(key);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    VALUE_FOR_KEY(key, boolValue,boolValue);
    return (NO);
}

- (NSString*_Nullable)safe_stringForKeyPath:(NSString *)keyPath
{
    JR_ASSERT_CLASS(keyPath,NSString);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSString *ret = nil;
    id object = [self safe_objectForKeyPath:keyPath];
    
    if (JR_IS_KIND_OF(object, NSString))
    {
        ret = (NSString *)object;
    }
    else if (JR_IS_KIND_OF(object, NSNumber))
    {
        ret = [object stringValue];
    }
    else if (JR_IS_KIND_OF(object, NSURL))
    {
        ret = [(NSURL *)object absoluteString];
    }
    else
    {
        ret = [object description];
    }
    
    return ret;
}

- (id)safe_objectForKeyPath:(NSString *)keyPath
{
    JR_ASSERT_CLASS(keyPath,NSString);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    if (JR_IS_KIND_OF(keyPath, NSString)&& keyPath.length>0 && JR_IS_KIND_OF(self, NSDictionary)) {
        
        NSDictionary *dic = self;
        
        NSString *keyPathtemp = [keyPath stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *arr = [keyPathtemp componentsSeparatedByString:@"."];
        
        for (int i = 0; i<arr.count; i++) {
            NSString *str = arr[i];
            @try {
                dic = [dic safe_objectForKey:str];
            } @catch (NSException *exception) {
                JR_LOG(@"safe_objectForKeyPath error:%@", exception);
            } @finally {
            }
        }
        return dic;
    }
    else
    {
        JR_LOG(@"keyPath  is not NSString ,or self is not NSDictionary");
        return nil;
    }
}


// add anObject
- (nullable NSDictionary *)safe_dictionaryBySetObject:(id)anObject forKey:(id)aKey
{
    JR_ASSERT_CLASS(aKey,NSString);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSDictionary *ret = self;
    
    if (!ret) {
        ret = [NSDictionary new];
    }
    
    NSMutableDictionary *mDict = [ret mutableCopy];
    [mDict safe_setObject:anObject forKey:aKey];
    return ([mDict copy]);
    
    return self;
}

- (nullable NSDictionary *)safe_dictionaryAddEntriesFromDictionary:(nullable NSDictionary *)otherDictionary
{
    JR_ASSERT_CLASS(otherDictionary,NSDictionary);
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSDictionary *ret = self;
    
    if (!ret) {
        ret = [NSDictionary new];
    }
    
    NSMutableDictionary *dic = [ret mutableCopy];
    [dic safe_addEntriesFromDictionary:otherDictionary];
    return ([dic copy]);
    
    return self;
}

- (nullable NSData *)toJSONData
{
    JR_ASSERT_CLASS(self,NSDictionary);
    
    NSData *ret = nil;
    NSError *err = nil;
    
    if (JR_IS_KIND_OF(self, NSDictionary) && self.allKeys.count>0) {
        ret = [NSJSONSerialization dataWithJSONObject:self
                                              options:0
                                                error:&err];
        if (err)
        {
            JR_LOG(@"Dictionary to JsonData Error:%@",err);
            ret = nil;
        }
    }
    return (ret);
}

-(NSString *)toJSONString_NSUTF8StringEncoding
{
    return [self toJSONStringWithEncoding:NSUTF8StringEncoding];
}

-(NSString *)toJSONStringWithEncoding:(NSStringEncoding)encoding
{
    NSString *ret = nil;
    NSData *jsonData = [self toJSONData];
    
    if (jsonData) {
        ret = [jsonData safe_getJSONStringWithEncoding:encoding];
    }
    return ret;
}


@end



#pragma mark - NSMutableDictionary + Safe
#define KeyType id
#define ObjectType id

@implementation NSMutableDictionary (Safe)

- (BOOL)safe_setObject:(nullable ObjectType)anObject forKey:(nullable KeyType)aKey;
{
    JR_ASSERT_CLASS(self,NSMutableDictionary);
    JR_ASSERT(aKey);
    
    BOOL ret = NO;
    
    if (JR_IS_KIND_OF(self, NSMutableDictionary) && aKey)
    {
        @synchronized (self) {
            if (anObject) {
                [self setObject:anObject forKey:aKey];
                ret = YES;
            }
            //如果anObject设置为nil代表移除该键值对
            else if([self safe_objectForKey:aKey])
            {
                [self removeObjectForKey:aKey];
            }
        }
    }
    return (ret);
}

- (BOOL)safe_setString:(nullable NSString *)anObject forKey:(nullable KeyType)aKey;
{
    JR_ASSERT_CLASS(self,NSMutableDictionary);
    JR_ASSERT_CLASS(anObject, NSString);
    JR_ASSERT(aKey);
    
    if (JR_IS_KIND_OF(anObject, NSString)) {
        
        return [self safe_setObject:anObject forKey:aKey];
    }
    else if(JR_IS_KIND_OF(anObject, NSNumber))
    {
        return [self safe_setObject:[(NSNumber*)anObject stringValue] forKey:aKey];
    }
    else
    {
        return [self safe_setObject:nil forKey:aKey];
    }
}

- (BOOL)safe_addEntriesFromDictionary:(nullable NSDictionary *)otherDictionary
{
    JR_ASSERT_CLASS(self,NSMutableDictionary);
    JR_ASSERT_CLASS(otherDictionary,NSDictionary);
    
    BOOL ret = NO;
    
    if (JR_IS_KIND_OF(self, NSMutableDictionary) && JR_IS_KIND_OF(otherDictionary, NSDictionary) && otherDictionary.allKeys.count>0) {
        @synchronized (self) {
            [self addEntriesFromDictionary:otherDictionary];
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)safe_setDictionary:(NSDictionary *)otherDictionary
{
    JR_ASSERT_CLASS(self,NSMutableDictionary);
    JR_ASSERT_CLASS(otherDictionary,NSDictionary);
    
    BOOL ret = NO;

    if (JR_IS_KIND_OF(self, NSMutableDictionary) && JR_IS_KIND_OF(otherDictionary, NSDictionary) && otherDictionary.allKeys.count>0) {
        @synchronized (self) {
            [self setDictionary:otherDictionary];
            ret = YES;
        }
    }
    
    return ret;
}


- (BOOL)safe_removeObjectForKey:(nullable KeyType)aKey
{
    JR_ASSERT_CLASS(self,NSMutableDictionary);
    JR_ASSERT(aKey);
    
    BOOL ret = NO;
    
    if(JR_IS_KIND_OF(self, NSMutableDictionary) && aKey && [self safe_objectForKey:aKey])
    {
        @synchronized (self) {
            [self removeObjectForKey:aKey];
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)safe_removeAllObjects
{
    JR_ASSERT_CLASS(self,NSMutableDictionary);
    
    BOOL ret = NO;
    
    if(JR_IS_KIND_OF(self, NSMutableDictionary) && self.allKeys.count>0)
    {
        @synchronized (self) {
            [self removeAllObjects];
            ret = YES;
        }
    }
    
    return ret;
}

@end



