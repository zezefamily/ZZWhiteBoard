//
//  ZZNotificationCenter.m
//  LottieUseDemo
//
//  Created by 泽泽 on 2019/5/6.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "ZZNotificationCenter.h"
@interface ZZNotificationCenter()
@property (nonatomic,strong) NSMutableArray *observers;
@end
@implementation ZZNotificationCenter

+ (ZZNotificationCenter *)defaultCenter
{
    static ZZNotificationCenter *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc]init];
    });
    return center;
}

- (instancetype)init
{
    if(self == [super init]){
        self.observers = [NSMutableArray array];
    }
    return self;
}

- (void)zz_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSString*)aName object:(nullable id)anObject
{
    ZZNotification *notificaton = [[ZZNotification alloc]init];
    notificaton.observer = observer;
    notificaton.aSelector = aSelector;
    notificaton.aName = aName;
    notificaton.anObject = anObject;
    [self.observers addObject:notificaton];
}

- (void)zz_postNotificationName:(NSString *)aName object:(nullable id)anObject
{
    ZZNotification *currentNotification =  [self getNotificationWithName:aName];
    [self zz_postNotification:currentNotification];
}

- (void)zz_postNotificationName:(NSString *)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo
{
    ZZNotification *currentNotification =  [self getNotificationWithName:aName];
    currentNotification.anObject = anObject;
    currentNotification.userInfo = aUserInfo;
    [self zz_postNotification:currentNotification];
}

- (void)zz_removeObserver:(id)observer
{
    [self.observers removeObject:[self getNotificationWithObserver:observer]];
}

- (void)zz_removeObserver:(id)observer name:(nullable NSString *)aName object:(nullable id)anObject
{
    [self.observers removeObject:[self getNotificationWithObserver:observer]];
}

- (void)zz_postNotification:(ZZNotification *)notification
{
    //方式一：(不够严谨)
//    if(notification.observer != nil){
//        id observer = notification.observer;
//        SEL selector = notification.aSelector;
//       #pragma clang diagnostic push
//       #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [observer performSelector:selector withObject:notification];
//       #pragma clang diagnostic pop
//    }
    //方式二：
    if(!notification.observer){return;}
    SEL sel = notification.aSelector;
    IMP imp = [notification.observer methodForSelector:sel];
    if(imp == nil)return;
    void (*func)(id,SEL,ZZNotification*) = (void *)imp;
    func(notification.observer,sel,notification);
}
- (ZZNotification *)getNotificationWithName:(NSString *)aName
{
    ZZNotification *not = nil;
    for (ZZNotification *notification in self.observers) {
        if([notification.aName isEqualToString:aName]){
            not = notification;
            break;
        }
    }
    return not;
}

- (ZZNotification *)getNotificationWithObserver:(id)observer
{
    ZZNotification *not = nil;
    for (ZZNotification *notification in self.observers) {
        if(notification.observer == observer){
            not = notification;
            break;
        }
    }
    return not;
}

@end
