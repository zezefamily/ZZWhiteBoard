//
//  ZZLinesManager.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//
/*
 {
     whiteboard:[],
     ppt:{
         0:[],
         1:[],
         ....
     },
     ispring:{
         0:[],
         1:[],
         ....
     }
 }
*/
#import <Foundation/Foundation.h>
#import "ZZCommonModel.h"
#import "ZZContentModel.h"
#import "BoardDefine.h"
NS_ASSUME_NONNULL_BEGIN



typedef void (^LinesChangedHandler)(NSInteger index,NSInteger length,NSString *locations);

typedef void (^LinesAddHandler)(BOOL finish);

@protocol ZZLinesManagerDelegate <NSObject>
@optional
- (void)toRequestLinesWithPage:(NSInteger)page mode:(ZZWhiteboardLinesMode)mode;
@end

@interface ZZLinesManager : NSObject

@property (nonatomic,weak) id<ZZLinesManagerDelegate> delegate;

@property (nonatomic,strong) NSMutableDictionary *allLines;

@property (nonatomic, copy) NSString *myUid;

@property (nonatomic,assign) BOOL needUpdate;

@property (nonatomic,assign) BOOL drawingFinish;
//添加线
- (void)addLineWithModel:(ZZDrawModel *)line uid:(NSString *)uid mode:(ZZWhiteboardLinesMode)mode page:(NSInteger)currentPage;
//添加一组线
- (void)addLineWithArray:(NSMutableArray <ZZDrawModel *>*)lines uid:(NSString *)uid mode:(ZZWhiteboardLinesMode)mode page:(NSInteger)currentPage completed:(LinesAddHandler)handler;
//撤销本地画线
- (void)cancelLastLine:(NSString *)uid mode:(ZZWhiteboardLinesMode)lineMode page:(NSInteger)currentPage completed:(LinesChangedHandler)handler;
//清空所有画线
- (void)clearAlllinesWithMode:(ZZWhiteboardLinesMode)lineMode page:(NSInteger)currentPage completed:(LinesChangedHandler)handler;
//数据切换
- (void)changeWhiteBoardMode:(ZZWhiteboardLinesMode)lineMode page:(NSInteger)page;
@end

NS_ASSUME_NONNULL_END
