//
//  ViewController.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//
#define ZZSendCmdMaxSize 20

#import "ViewController.h"
#import "ZZDrawBoard.h"
#import "ZZLinesManager.h"
@interface ViewController ()<ZZLinesManagerDelegate,ZZDrawBoardDataSource>
{
    ZZDrawModel *_configModel;
    NSMutableArray *_trails;
    NSDictionary *_lastPoint;
}
@property (nonatomic,strong) ZZDrawBoard *drawBoard;
@property (nonatomic,strong) ZZLinesManager *linesManager;

@property (nonatomic,copy) NSString *user_id;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadUI];
}
- (void)loadUI
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    _configModel = [[ZZDrawModel alloc]init];
    _configModel.type = @"pencil";
    _configModel.color = 4;
    _trails = [NSMutableArray array];
    self.drawBoard = [[ZZDrawBoard alloc]initWithFrame:CGRectMake(0, 20, 800, 600)];
    self.linesManager = [[ZZLinesManager alloc]init];
    [self.view addSubview:self.drawBoard];
}

#pragma mark - ZZDrawBoardDataSource
- (ZZLinesManager *)drawBoardZZLinesManager
{
    self.linesManager.needUpdate = NO;
    return self.linesManager;
}
- (BOOL)drawBoardNeedUpdate
{
    return self.linesManager.needUpdate;
}
- (void)touchEventWithType:(ZZDrawBoardPointType)eventType point:(CGPoint)point
{
    ZZDrawPointModel *sendPoint = [ZZDrawPointModel new];
    sendPoint.x = (point.x) / self.drawBoard.frame.size.width;
    sendPoint.y = (point.y) / self.drawBoard.frame.size.height;
    sendPoint.type = eventType;
    [self sendPoint:sendPoint lineConfig:_configModel];
}

- (void)sendPoint:(ZZDrawPointModel *)point lineConfig:(ZZDrawModel *)lineConfig
{
    if(point.type == ZZDrawBoardPointTypeStart){
        [_trails removeAllObjects];
        [_trails addObject:@{@"x":[NSNumber numberWithFloat:point.x],@"y":[NSNumber numberWithFloat:point.y]}];
        NSMutableArray *trailBuffer = [NSMutableArray arrayWithArray:_trails];
        [self publicDrawMessageSendWithBuffer:trailBuffer type:point.type lineConfig:lineConfig];
    }
    if(point.type == ZZDrawBoardPointTypeMove){
        [_trails addObject:@{@"x":[NSNumber numberWithFloat:point.x],@"y":[NSNumber numberWithFloat:point.y]}];
        if(_trails.count >= ZZSendCmdMaxSize){
            NSMutableArray *trailBuffer = [NSMutableArray arrayWithArray:_trails];
            if(_lastPoint){
                [trailBuffer insertObject:_lastPoint atIndex:0];
            }
            _lastPoint = (NSDictionary *)[_trails lastObject];
            [_trails removeAllObjects];
            [self publicDrawMessageSendWithBuffer:trailBuffer type:point.type lineConfig:lineConfig];
        }
    }
    if(point.type == ZZDrawBoardPointTypeEnd){
        [_trails addObject:@{@"x":[NSNumber numberWithFloat:point.x],@"y":[NSNumber numberWithFloat:point.y]}];
        NSMutableArray *trailBuffer = [NSMutableArray arrayWithArray:_trails];
        if(_lastPoint){
            [trailBuffer insertObject:_lastPoint atIndex:0];
        }
        _lastPoint = nil;
        [_trails removeAllObjects];
        [self publicDrawMessageSendWithBuffer:trailBuffer type:point.type lineConfig:lineConfig];
    }
}
- (void)publicDrawMessageSendWithBuffer:(NSArray *)trailBuffer type:(ZZDrawBoardPointType)type lineConfig:(ZZDrawModel *)lineConfig
{
    ZZCommonModel * commonModel = [ZZCommonModel instanceModel];
    commonModel.command = @"trail";
    commonModel.domain_id = type;
    commonModel.domain = @"draw";
    commonModel.user_id = self.user_id;
    commonModel.content = @{@"color":[NSNumber numberWithInt:lineConfig.color],
                            @"trail":trailBuffer,
                            @"type":@"pencil",
                            @"width":@"3",
                            @"widthType":@"1",
                            @"user_id":self.user_id
                            };
    //本地存储
    ZZDrawModel *model = [ZZDrawModel mj_objectWithKeyValues:commonModel.content];
    model.user_id = self.user_id;
    model.moveType = type;
    [self.linesManager addLineWithModel:model uid:model.user_id mode:ZZWhiteboardLinesMode_WhiteBoard page:0];
    //    if(self.isBreaking == NO){
    //发送到远端
//    NSString *jsonString = [[commonModel mj_JSONObject] mj_JSONString];
//    //    [_server jxh_sendMessage:jsonString toUser:@""];
//    //更新到共享对象
//    NSString *key = (_whiteBoardMode == 0)?@"board":[NSString stringWithFormat:@"ppt:%ld",_whiteBoardPage];
//    //    XXLog(@"Share_key == %@",key);
//    [_server updateShareInfoWithBody:@{@1:key,@2:jsonString,@3:@"n",@4:@"upd"}];
    //    }
}
@end
