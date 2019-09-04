//
//  ZZContentModel.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZContentModel : NSObject
@property (nonatomic,copy) NSString *uid;
@end

// 绘制
@interface ZZDrawModel : NSObject
@property (nonatomic,copy) NSString *user_id;
@property (nonatomic,assign) int color;
@property (nonatomic,strong) NSMutableArray *trail;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,assign) NSInteger moveType;
@property (nonatomic,assign) float width;               // 线宽
@property (nonatomic,copy) NSString *widthType;
@property (nonatomic, assign) NSInteger lastLineIndex;     // 上一条次用户的画线在所有画线数组中的索引
@property (nonatomic, assign) NSInteger lineIndex;         // 此画线在所有画线数组中的索引
// 圆/椭圆
@property (nonatomic,assign) float angle;
@property (nonatomic,assign) float rectHeight;
@property (nonatomic,assign) float rectWidth;
@property (nonatomic,assign) float rectX;
@property (nonatomic,assign) float rectY;
//文本
@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) float fontsize;
@end

// 点
@interface ZZDrawPointModel : NSObject
@property (nonatomic,assign) float x;
@property (nonatomic,assign) float y;
@property (nonatomic,assign) int type;
@end

NS_ASSUME_NONNULL_END
