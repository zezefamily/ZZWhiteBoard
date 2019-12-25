//
//  ZZDrawBoard.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ZZLinesManager.h"
#import "BoardDefine.h"
#import "ZZPaintModel.h"
//pencil rectangle circle closedCurve text
//typedef NS_ENUM(NSInteger,ZZDrawBoardPaintType){
//    ZZDrawBoardPaintTypeLine = 0,            //线 pencil
//    ZZDrawBoardPaintTypeRectAngle = 1,       //矩形 rectangle
//    ZZDrawBoardPaintTypeCircle = 2,          //圆 circle
//    ZZDrawBoardPaintTypeClosedCurve = 3,     //闭合曲线 closedCurve
//    ZZDrawBoardPaintTypeText = 4             //文本 text
//};

NS_ASSUME_NONNULL_BEGIN

@class ZZLinesManager;
@class ZZPaintModel;
@class ZZPaintPath;
@protocol ZZDrawBoardDataSource <NSObject>

- (ZZLinesManager *)drawBoardZZLinesManager;

- (BOOL)drawBoardNeedUpdate;

//- (void)touchEventWithType:(ZZDrawBoardPointType)eventType point:(CGPoint)point;

- (void)touchEventWithPaintModel:(ZZPaintModel *)paintModel path:(ZZPaintPath * __nullable)path;

@optional

- (NSInteger)drawBoardCurrentMode;

- (NSInteger)drawBoardCurrentPage;

- (void)isDrawingFinish:(BOOL)finshed;

@end

@interface ZZDrawBoard : UIImageView

@property (nonatomic,weak) id<ZZDrawBoardDataSource> dataSource;

@property (nonatomic,strong) UIColor *strokeColor;

@property (nonatomic,assign) CGFloat strokeWidth;

@property (nonatomic,assign) BOOL isEraser;

@property (nonatomic,assign) BOOL isDrag;

@property (nonatomic,assign) int colorIndex;

@property (nonatomic,assign) ZZDrawBoardPaintType paintType;
//添加一条远程的线
- (void)addRemoteLineWithModel:(ZZDrawModel *)drawModel;
@end

NS_ASSUME_NONNULL_END
