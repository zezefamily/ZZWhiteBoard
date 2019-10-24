//
//  ZZPaintModel.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/10/23.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoardDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZZPaintModel : NSObject

@property (nonatomic,assign) ZZDrawBoardPaintType paintType;

@property (nonatomic,assign) ZZDrawBoardPointType touchType;

@property (nonatomic,assign) CGPoint defaultPoint;

@property (nonatomic,assign) CGPoint startPoint;

@property (nonatomic,assign) CGPoint endPoint;

@property (nonatomic,assign) CGFloat radius;

@end

NS_ASSUME_NONNULL_END
