//
//  ZZNotificationCenter.h
//  LottieUseDemo
//
//  Created by 泽泽 on 2019/5/6.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZNotification.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZZNotificationCenter : NSObject

+ (ZZNotificationCenter *)defaultCenter;

- (void)zz_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSString *)aName object:(nullable id)anObject;

- (void)zz_postNotification:(ZZNotification *)notification;
- (void)zz_postNotificationName:(NSString *)aName object:(nullable id)anObject;
- (void)zz_postNotificationName:(NSString *)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

- (void)zz_removeObserver:(id)observer;
- (void)zz_removeObserver:(id)observer name:(nullable NSString *)aName object:(nullable id)anObject;


@end

NS_ASSUME_NONNULL_END
