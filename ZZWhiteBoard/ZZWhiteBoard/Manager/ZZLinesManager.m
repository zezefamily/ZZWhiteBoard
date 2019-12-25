//
//  ZZLinesManager.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#define ZZWhiteboardDictionaryKey @"whiteboard"
#define ZZPPTDictionaryKey @"ppt"
#define ZZiSpringDictionaryKey @"ispring"

#import "ZZLinesManager.h"

@interface ZZLinesManager ()
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign) ZZWhiteboardLinesMode linesMode;

@end
@implementation ZZLinesManager

- (instancetype)init
{
    if(self == [super init]){
        _drawingFinish = YES;
    }
    return self;
}
- (NSMutableDictionary *)allLines
{
    if(!_allLines){
        _allLines = [NSMutableDictionary dictionary];
        [_allLines setObject:[NSMutableArray array] forKey:ZZWhiteboardDictionaryKey];
        [_allLines setObject:[NSMutableDictionary dictionary] forKey:ZZPPTDictionaryKey];
        [_allLines setObject:[NSMutableDictionary dictionary] forKey:ZZiSpringDictionaryKey];
    }
    return _allLines;
}

//添加线到当前mode下currentPage上
- (void)addLineWithModel:(ZZDrawModel *)line uid:(NSString *)uid mode:(ZZWhiteboardLinesMode)mode page:(NSInteger)currentPage
{
    _linesMode = mode;
    _currentPage = currentPage;
    if(mode == ZZWhiteboardLinesMode_WhiteBoard){
        //添加普通白板数据
        NSMutableArray *linesArr = [self.allLines safe_objectForKey:ZZWhiteboardDictionaryKey];
        [linesArr addObject:line];
    }else if (mode == ZZWhiteboardLinesMode_PPT){
        //添加普通PPT数据到当前页
        NSMutableDictionary *pptLines = [self.allLines safe_objectForKey:ZZPPTDictionaryKey];
        NSString *pageKey = [NSString stringWithFormat:@"%ld",currentPage];
        NSMutableArray *pageLines = [pptLines safe_objectForKey:pageKey];
        if(pageLines == nil){
            pageLines  = [NSMutableArray array];
            [pptLines setObject:pageLines forKey:pageKey];
        }
        [pageLines addObject:line];
    }else if (mode == ZZWhiteboardLinesMode_iSpring){
        //添加动态PPT数据到当前页
        NSMutableDictionary *iSpringLines = [self.allLines safe_objectForKey:ZZiSpringDictionaryKey];
        NSString *pageKey = [NSString stringWithFormat:@"%ld",(long)currentPage];
        NSMutableArray *pageLines = [iSpringLines safe_objectForKey:pageKey];
        if(pageLines == nil){
            pageLines  = [NSMutableArray array];
            [iSpringLines setObject:pageLines forKey:pageKey];
        }
        [pageLines addObject:line];
    }
    XXLog(@"allLine == %@",self.allLines);
}
- (void)addLineWithArray:(NSMutableArray <ZZDrawModel *>*)lines uid:(NSString *)uid mode:(ZZWhiteboardLinesMode)mode page:(NSInteger)currentPage completed:(LinesAddHandler)handler
{
    _linesMode = mode;
    _currentPage = currentPage;
    if(mode == ZZWhiteboardLinesMode_WhiteBoard){
        //添加普通白板数据
        NSMutableArray *linesArr = [self.allLines safe_objectForKey:ZZWhiteboardDictionaryKey];
        [linesArr addObjectsFromArray:lines];
    }else if (mode == ZZWhiteboardLinesMode_PPT){
        //添加普通PPT数据到当前页
        NSMutableDictionary *pptLines = [self.allLines safe_objectForKey:ZZPPTDictionaryKey];
        NSString *pageKey = [NSString stringWithFormat:@"%ld",currentPage];
        NSMutableArray *pageLines = [pptLines safe_objectForKey:pageKey];
        if(pageLines == nil){
            pageLines  = [NSMutableArray array];
            [pptLines setObject:pageLines forKey:pageKey];
        }
        [pageLines addObjectsFromArray:lines];
    }else if (mode == ZZWhiteboardLinesMode_iSpring){
        //添加动态PPT数据到当前页
        NSMutableDictionary *iSpringLines = [self.allLines safe_objectForKey:ZZiSpringDictionaryKey];
        NSString *pageKey = [NSString stringWithFormat:@"%ld",(long)currentPage];
        NSMutableArray *pageLines = [iSpringLines safe_objectForKey:pageKey];
        if(pageLines == nil){
            pageLines  = [NSMutableArray array];
            [iSpringLines setObject:pageLines forKey:pageKey];
        }
        [pageLines addObjectsFromArray:lines];
    }
    if(handler){
        handler(YES);
    }
    
    //    XXLog(@"allLines == %@",self.allLines);
}


//撤销当前mode下currentPage的线
- (void)cancelLastLine:(NSString *)uid mode:(ZZWhiteboardLinesMode)lineMode page:(NSInteger)currentPage completed:(LinesChangedHandler)handler
{
    _linesMode = lineMode;
    _currentPage = currentPage;
    switch (lineMode) {
        case ZZWhiteboardLinesMode_WhiteBoard:
        {
            NSMutableArray *whiteLines = [self.allLines objectForKey:ZZWhiteboardDictionaryKey];
            if(whiteLines.count == 0){
                return;
            }
            if(_drawingFinish == NO){
                [self removeLastLineWithUser:uid linesArray:whiteLines completed:^(NSInteger index, NSInteger length, NSString *locations) {
                    if(handler){
                        handler(index,length,locations);
                    }
                }];
                return;
            }else{
                [self removeLastLineWithUser:uid linesArray:whiteLines completed:^(NSInteger index, NSInteger length, NSString *locations) {
                    if(handler){
                        handler(index,length,locations);
                    }
                }];
            }
            //绘制
            _needUpdate = YES;
        }
            break;
        case ZZWhiteboardLinesMode_PPT: case ZZWhiteboardLinesMode_iSpring:
        {
            NSMutableArray *pagelines = [self getPageLinesWithPage:currentPage mode:lineMode];
            [self removeLastLineWithUser:uid linesArray:pagelines completed:^(NSInteger index, NSInteger length, NSString *locations) {
                if(handler){
                    handler(index,length,locations);
                }
            }];
            _needUpdate = YES;
        }
            break;
        default:
            break;
    }
    
    XXLog(@"self.allLines == %@",self.allLines);
}

//清空当前mode下currentPage的线
- (void)clearAlllinesWithMode:(ZZWhiteboardLinesMode)lineMode page:(NSInteger)currentPage completed:(LinesChangedHandler)handler
{
    _linesMode = lineMode;
    _currentPage = currentPage;
    switch (lineMode) {
        case ZZWhiteboardLinesMode_WhiteBoard:
        {
            NSMutableArray *whiteLines = [self.allLines objectForKey:ZZWhiteboardDictionaryKey];
            if(handler){
                handler(0,whiteLines.count,nil);
            }
            [whiteLines removeAllObjects];
            
        }
            break;
        case ZZWhiteboardLinesMode_PPT: case ZZWhiteboardLinesMode_iSpring:
        {
            NSMutableArray *pagelines = [self getPageLinesWithPage:currentPage mode:lineMode];
            if(handler){
                handler(0,pagelines.count,nil);
            }
            [pagelines removeAllObjects];
        }
            break;
        default:
            break;
    }
    _needUpdate = YES;
}

- (ZZDrawModel *)getLastLineWithUser:(NSString *)user mode:(ZZWhiteboardLinesMode)mode page:(NSInteger)currentPage
{
    ZZDrawModel *_line;
    NSMutableArray *linesArray;
    if(mode == ZZWhiteboardLinesMode_WhiteBoard){
        linesArray = [self.allLines safe_objectForKey:ZZWhiteboardDictionaryKey];
    }else{
        linesArray = [self getPageLinesWithPage:currentPage mode:mode];
    }
    _line = [self getLastLineWithUser:user linesArray:linesArray];
    return _line;
}


- (void)removeLastLineWithUser:(NSString *)user linesArray:(NSMutableArray *)linesArray completed:(LinesChangedHandler)completed
{
    NSMutableArray *currentLinesArray = linesArray;
    NSString *indexLoctions = @"";
    NSInteger deleteLength = 0;
    if(linesArray.count != 0){
        for (ZZDrawModel *line in [linesArray reverseObjectEnumerator]) {
            if([line.user_id isEqualToString:user]){
                if(line.moveType == 1){
                    deleteLength+=1;
                    NSInteger index = [currentLinesArray indexOfObject:line];
                    indexLoctions = [indexLoctions stringByAppendingString:[NSString stringWithFormat:@"%ld,",index]];
                    [linesArray removeObject:line];
                    break;
                }else{
                    deleteLength+=1;
                    NSInteger index = [currentLinesArray indexOfObject:line];
                    indexLoctions = [indexLoctions stringByAppendingString:[NSString stringWithFormat:@"%ld,",index]];
                    [linesArray removeObject:line];
                }
            }
        }
    }
    if(completed){
        completed(linesArray.count,deleteLength,indexLoctions);
    }
}

- (void)changeWhiteBoardMode:(ZZWhiteboardLinesMode)lineMode page:(NSInteger)page
{
    _linesMode = lineMode;
    _currentPage = page;
    _needUpdate = YES;
}

- (NSArray *)getDrawModelWithPoint:(CGPoint)point mode:(ZZWhiteboardLinesMode)mode page:(NSInteger)currentPage
{
    NSMutableArray *linesArray;
    if(mode == ZZWhiteboardLinesMode_WhiteBoard){
        linesArray = [self.allLines objectForKey:ZZWhiteboardDictionaryKey];
    }else{
        linesArray = [self getPageLinesWithPage:currentPage mode:mode];
    }
    if(linesArray.count == 0){
        return nil;
    }
    //1.倒序遍历下 找到包含point的path
    NSArray *reverseArr = [[linesArray reverseObjectEnumerator]allObjects];
    NSArray *tasks = nil;
    ZZDrawModel *targetObj = nil;
    for(int idx = 0;idx<reverseArr.count;idx++){
        ZZDrawModel *obj = [reverseArr safe_objectAtIndex:idx];
        if(![obj.type isEqualToString:@"pencil"]){
            BOOL isHave = [obj.path containsPoint:point];
            if(isHave){
                targetObj = obj;
                break;
            }
        }
    }
    if(targetObj == nil){
        XXLog(@"未找到目标对象");
//        _needUpdate = YES;
        return nil;
    }
    //2.找到目标对象在正序里面的位置index
    NSInteger index = [linesArray indexOfObject:targetObj];
    //3.从缓存记录里面删除目标对象
    tasks = @[targetObj,@(index)];
    [linesArray removeObject:[tasks safe_getFirstObject]];
    _needUpdate = YES;
    XXLog(@"getDrawModelWithPoint_allLine == %@",self.allLines);
    return tasks;

}
//0x60000202d290
#pragma mark - 获取用户在当前page线条数据里的最后一条线
- (ZZDrawModel *)getLastLineWithUser:(NSString *)user linesArray:(NSMutableArray *)linesArray
{
    ZZDrawModel *_line;
    if(linesArray.count != 0){
        for (ZZDrawModel *line in [linesArray reverseObjectEnumerator]) {
            if([line.user_id isEqualToString:user]){
                _line = line;
                break;
            }
        }
    }
    return _line;
}
#pragma mark - 获取PPT(静态/动态)某页的所有线条数据
- (NSMutableArray *)getPageLinesWithPage:(NSInteger)page mode:(ZZWhiteboardLinesMode)mode
{
    NSMutableArray *pageLines;
    NSString *pagekey = [NSString stringWithFormat:@"%ld",(long)page];
    if(mode == ZZWhiteboardLinesMode_PPT){
        NSMutableDictionary *pptLines = [self.allLines safe_objectForKey:ZZPPTDictionaryKey];
        pageLines = [pptLines safe_objectForKey:pagekey];
    }else if (ZZWhiteboardLinesMode_iSpring){
        NSMutableDictionary *ispringLines = [self.allLines safe_objectForKey:ZZiSpringDictionaryKey];
        pageLines = [ispringLines safe_objectForKey:pagekey];
    }
    return pageLines;
}

@end
