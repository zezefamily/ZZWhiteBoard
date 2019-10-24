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
#import "ZZToolBar.h"
#import "ZZLayerDrawBoard.h"
@interface ViewController ()<ZZLinesManagerDelegate,ZZDrawBoardDataSource,ZZToolBarDelegate>
{
    UIImageView *_bgImageView;
    ZZDrawModel *_configModel;  // 全局配置项
    NSMutableArray *_trails;    // 普通线数据 全局收集池(集合)
    NSDictionary *_lastPoint;   // 记录末尾的点
    ZZToolBar *_toolBar;        // 工具条
}
@property (nonatomic,strong) ZZLayerDrawBoard *drawBoard;     // 画板
@property (nonatomic,strong) ZZLinesManager *linesManager;   // 画板数据管理器

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
    _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, 800, 600)];
    _bgImageView.image = [UIImage imageNamed:@"bgImage"];
    [self.view addSubview:_bgImageView];
    
    self.user_id = @"1234";
    self.view.backgroundColor = [UIColor lightGrayColor];
    _configModel = [[ZZDrawModel alloc]init];
    _configModel.type = @"pencil";
    _configModel.color = 0;
    _trails = [NSMutableArray array];
    self.drawBoard = [[ZZLayerDrawBoard alloc]initWithFrame:CGRectMake(0, 20, 800, 600)];
    self.drawBoard.dataSource = self;
//    self.drawBoard.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.drawBoard];
    self.linesManager = [[ZZLinesManager alloc]init];
    _toolBar = [[ZZToolBar alloc]initWithFrame:CGRectMake(0, self.drawBoard.frame.size.height+20, self.drawBoard.frame.size.width, 40)];
    _toolBar.delegate = self;
    [self.view addSubview:_toolBar];
}
#pragma mark - ZZToolBarDelegate
- (void)toolButtonDidSelectedWithTag:(NSInteger)tag sender:(UIButton *)sender
{
    [self.drawBoard setIsEraser:NO];
    _configModel.type = @"";
    switch (tag) {
        case 0:
        {
            [self.drawBoard setPaintType:ZZDrawBoardPaintTypeLine];
        }
            break;
        case 1:
        {
            [self.drawBoard setPaintType:ZZDrawBoardPaintTypeRectAngle];
        }
            break;
        case 2:
        {
            [self.drawBoard setPaintType:ZZDrawBoardPaintTypeCircle];
        }
            break;
        case 3:
        {
            [self.drawBoard setPaintType:ZZDrawBoardPaintTypeClosedCurve];
        }
            break;
        case 4:
        {
            [self.drawBoard setPaintType:ZZDrawBoardPaintTypeLine];
            [self.drawBoard setIsEraser:YES];
            _configModel.type = @"eraser";
        }
            break;
        case 5:
        {
            [self.linesManager cancelLastLine:self.user_id mode:ZZWhiteboardLinesMode_WhiteBoard page:0 completed:^(NSInteger index, NSInteger length, NSString * _Nonnull locations) {
            }];
        }
            break;
        case 6:
        {
            [self.linesManager clearAlllinesWithMode:ZZWhiteboardLinesMode_WhiteBoard page:0 completed:^(NSInteger index, NSInteger length, NSString * _Nonnull locations) {
            }];
        }
            break;
        default:
            break;
    }
}
#pragma mark - ZZDrawBoardDataSource
- (ZZLinesManager *)drawBoardZZLinesManager
{
    XXLog(@"drawBoardZZLinesManager.....");
    self.linesManager.needUpdate = NO;
    return self.linesManager;
}
- (BOOL)drawBoardNeedUpdate
{
    return self.linesManager.needUpdate;
}
- (NSInteger)drawBoardCurrentMode
{
    return ZZWhiteboardLinesMode_WhiteBoard;
}
- (NSInteger)drawBoardCurrentPage
{
    return 0;
}
- (void)touchEventWithPaintModel:(ZZPaintModel *)paintModel
{
    if(paintModel.paintType == ZZDrawBoardPaintTypeLine){
        ZZDrawPointModel *sendPoint = [ZZDrawPointModel new];
        sendPoint.x = (paintModel.defaultPoint.x) / self.drawBoard.frame.size.width;
        sendPoint.y = (paintModel.defaultPoint.y) / self.drawBoard.frame.size.height;
        sendPoint.type = paintModel.touchType;
        [self sendPoint:sendPoint lineConfig:_configModel];
    }else{
        //pencil rectangle circle closedCurve text
        ZZCommonModel * commonModel = [ZZCommonModel instanceModel];
        commonModel.command = @"trail";
        commonModel.domain_id = 1;
        commonModel.domain = @"draw";
        commonModel.user_id = self.user_id;
        commonModel.content = @{@"color":[NSNumber numberWithInt:_configModel.color],
                                @"trail":@[],
                                @"type":@[@"pencil",@"rectangle",@"circle",@"closedCurve",@"text"][paintModel.paintType],
                                @"width":@"3",
                                @"widthType":@"1",
                                @"user_id":self.user_id,
                                @"startPoint":@{@"x":[NSNumber numberWithFloat:(paintModel.startPoint.x/self.drawBoard.frame.size.width)],
                                                @"y":[NSNumber numberWithFloat:(paintModel.startPoint.y/self.drawBoard.frame.size.height)]},
                                @"endPoint":@{@"x":[NSNumber numberWithFloat:(paintModel.endPoint.x/self.drawBoard.frame.size.width)],
                                              @"y":[NSNumber numberWithFloat:(paintModel.endPoint.y/self.drawBoard.frame.size.height)]
                                              }
                                };
//        XXLog(@"\ncontent == \n%@",commonModel.content);
        //本地存储
        ZZDrawModel *model = [ZZDrawModel mj_objectWithKeyValues:commonModel.content];
        model.user_id = self.user_id;
        model.moveType = 1;
        [self.linesManager addLineWithModel:model uid:model.user_id mode:ZZWhiteboardLinesMode_WhiteBoard page:0];
    }
}
#pragma mark - 普通线数据采集（start move end）
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
                            @"type":_configModel.type,
                            @"width":@"3",
                            @"widthType":@"1",
                            @"user_id":self.user_id
                            };
    //本地存储
    ZZDrawModel *model = [ZZDrawModel mj_objectWithKeyValues:commonModel.content];
    model.user_id = self.user_id;
    model.moveType = type;
    [self.linesManager addLineWithModel:model uid:model.user_id mode:ZZWhiteboardLinesMode_WhiteBoard page:0];
    //发送到远端
    //TODO...
}
/*
 //测试个东西
 SEL sel = @selector(testWithString:);
 IMP imp = [self methodForSelector:sel];
 if(imp == nil)return;
 void (*func)(id,SEL,NSString*) = (void *)imp;
 func(self,sel,@"测试文本");
*/
//- (void)testWithString:(NSString *)name
//{
//    XXLog(@"name ==== %@, cmd == %@",name,NSStringFromSelector(_cmd));
//}
//
//void func(id _class,SEL _cmd,NSString *_name) {
//    XXLog(@"name ==== %@",_name);
//}

@end
