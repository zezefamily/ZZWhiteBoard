//
//  ZZNotification.h
//  LottieUseDemo
//
//  Created by 泽泽 on 2019/5/6.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZNotification : NSObject
@property (nonatomic,strong) id observer;
@property (nonatomic,assign) SEL aSelector;
@property (nonatomic,copy) NSString *aName;
@property (nonatomic,strong) id anObject;
@property (nonatomic,strong) NSDictionary *userInfo;
@end

NS_ASSUME_NONNULL_END


/*
 - (void)zz_addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject
 */
