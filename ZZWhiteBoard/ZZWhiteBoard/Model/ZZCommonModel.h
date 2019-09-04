//
//  ZZCommonModel.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZZViewPointType){
    ZZViewPointTypeStart    = 0,
    ZZViewPointTypeMove     = 1,
    ZZViewPointTypeEnd      = 2,
};

@interface ZZCommonModel : NSObject
+ (ZZCommonModel *)instanceModel;
@property (nonatomic,copy) NSString *domain;   //指令名称
@property (nonatomic,assign) int domain_id;     //指令id
@property (nonatomic,copy) NSString *command;  //指令操作
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,strong) NSDictionary *content;  //具体参数扩展
@end

NS_ASSUME_NONNULL_END
