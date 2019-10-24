//
//  ZZLayerDrawBoard.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/10/23.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZZLinesManager.h"
#import "BoardDefine.h"
#import "ZZPaintModel.h"
NS_ASSUME_NONNULL_BEGIN

@class ZZLinesManager;
@class ZZPaintModel;
@protocol ZZDrawBoardDataSource <NSObject>

- (ZZLinesManager *)drawBoardZZLinesManager;

- (BOOL)drawBoardNeedUpdate;

//- (void)touchEventWithType:(ZZDrawBoardPointType)eventType point:(CGPoint)point;

- (void)touchEventWithPaintModel:(ZZPaintModel *)paintModel;

@optional

- (NSInteger)drawBoardCurrentMode;

- (NSInteger)drawBoardCurrentPage;

- (void)isDrawingFinish:(BOOL)finshed;

@end

@interface ZZLayerDrawBoard : UIView

@property (nonatomic,weak) id<ZZDrawBoardDataSource> dataSource;

@property (nonatomic,strong) UIColor *strokeColor;

@property (nonatomic,assign) CGFloat strokeWidth;

@property (nonatomic,assign) BOOL isEraser;

@property (nonatomic,assign) int colorIndex;

@property (nonatomic,assign) ZZDrawBoardPaintType paintType;
//添加一条远程的线
- (void)addRemoteLineWithModel:(ZZDrawModel *)drawModel;

@end

NS_ASSUME_NONNULL_END
