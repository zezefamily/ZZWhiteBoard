//
//  ZZDrawBoard.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "ZZDrawBoard.h"
#import "ZZCADisplayLinkHolder.h"
#import "ZZLinesManager.h"
#import "ZZPaintPath.h"
@interface ZZDrawBoard ()<ZZCADisplayLinkHolderDelegate>
{
    BOOL _isDrawingFinish;
    ZZPaintModel *_currentPaintModel;
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGFloat _radius;
}
@property (nonatomic,assign) ZZDrawBoardPointType drawState;
@property (nonatomic,strong) UIImage *realImage;
@property (nonatomic,strong) ZZPaintPath *currentPath;
@property (nonatomic, strong) ZZCADisplayLinkHolder  *displayLinkHolder;     // 渲染的计时器
@property (nonatomic,strong) CAShapeLayer *myRealLayer;  // 本地实时层
@property (nonatomic,strong) NSMutableArray *bufferLines;  // 当前page所有线条
@property(nonatomic, strong) NSArray *colorArr;
@end
@implementation ZZDrawBoard
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self == [super initWithFrame:frame]){
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        _colorArr = [[NSArray alloc] init];
        _colorArr = @[@(0x000000), @(0xd1021c), @(0xfddc01), @(0x7dd21f), @(0x228bf7), @(0x9b0df5)];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        self.strokeColor = [UIColor blackColor];
        self.strokeWidth = 3.0f;
        ((CAShapeLayer *)self.layer).masksToBounds = YES;
        _displayLinkHolder = [ZZCADisplayLinkHolder new];
        [_displayLinkHolder setFrameInterval:1];
        [_displayLinkHolder startCADisplayLinkWithDelegate:self];
        self.paintType = ZZDrawBoardPaintTypeLine;
        //自己的实时绘制层
        _myRealLayer = [CAShapeLayer layer];
        _myRealLayer.backgroundColor = [UIColor clearColor].CGColor;
        _myRealLayer.fillColor = [UIColor clearColor].CGColor;
        _myRealLayer.lineCap = kCALineCapRound;
        _myRealLayer.lineJoin = kCALineJoinRound;
        _myRealLayer.lineWidth = self.strokeWidth;
        [self.layer addSublayer:_myRealLayer];
        _myRealLayer.hidden = YES;
        self.bufferLines = [NSMutableArray array];
        
        _currentPaintModel = [[ZZPaintModel alloc]init];
    }
    return self;
}
#pragma mark - NTESCADisplayLinkHolderDelegate
- (void)onDisplayLinkFire:(ZZCADisplayLinkHolder *)holder duration:(NSTimeInterval)duration displayLink:(CADisplayLink *)displayLink
{
    if(self.dataSource && [_dataSource drawBoardNeedUpdate]){
        ZZLinesManager *lineManager = [_dataSource drawBoardZZLinesManager];
        ZZWhiteboardLinesMode drawMode = [_dataSource drawBoardCurrentMode];
        NSMutableArray *drawLines;
        if(drawMode == 0){
            XXLog(@"当前为：：：白板模式");
            drawLines = [lineManager.allLines objectForKey:@"whiteboard"];
        }else if (drawMode == 1){
            XXLog(@"当前为：：：ppt模式");
            NSMutableDictionary *pptLines = [lineManager.allLines objectForKey:@"ppt"];
            NSString *pageKey = [NSString stringWithFormat:@"%ld",(long)[_dataSource drawBoardCurrentPage]];
            drawLines = [pptLines objectForKey:pageKey];
        }else{
            NSMutableDictionary *pptLines = [lineManager.allLines objectForKey:@"ispring"];
            NSString *pageKey = [NSString stringWithFormat:@"%ld",(long)[_dataSource drawBoardCurrentPage]];
            drawLines = [pptLines objectForKey:pageKey];
        }
        [self reDrawWithLines:drawLines];
    }
}

#pragma mark - 重新绘制当前Page的所有线条
- (void)reDrawWithLines:(NSMutableArray <ZZDrawModel *>*)linesModelArray
{
    _isDrawingFinish = NO;
    if([self.dataSource respondsToSelector:@selector(isDrawingFinish:)]){
        [self.dataSource isDrawingFinish:_isDrawingFinish];
    }
    [self clearAllSubLayers];
    for(int i = 0;i<linesModelArray.count;i++){
        ZZDrawModel *draw = [linesModelArray objectAtIndex:i];
        ZZPaintPath *path = [self getLinePathWithModel:draw];
        path.lineColor = [self getStoreColorWithIndex:draw.color];
        if(path){
            [self.bufferLines addObject:path];
        }
    }
    __weak typeof (self) weakSelf = self;
    [self reload_drawingImageWithPath:self.bufferLines completed:^(BOOL finish) {
        if(finish){
            self->_isDrawingFinish = YES;
            if([weakSelf.dataSource respondsToSelector:@selector(isDrawingFinish:)]){
                [weakSelf.dataSource isDrawingFinish:self->_isDrawingFinish];
            }
        }
    }];
}

- (NSArray *)getStartEndPointsWithLineModel:(ZZDrawModel *)lineModel
{
    ZZDrawPointModel *startModel = [ZZDrawPointModel mj_objectWithKeyValues:lineModel.startPoint];
    ZZDrawPointModel *endModel = [ZZDrawPointModel mj_objectWithKeyValues:lineModel.endPoint];
    CGPoint startPoint = CGPointMake(startModel.x * self.frame.size.width, startModel.y *self.frame.size.height);
    CGPoint endPoint = CGPointMake(endModel.x * self.frame.size.width, endModel.y *self.frame.size.height);
    return @[@(startPoint),@(endPoint)];
}
#pragma mark - 获取一个路径  closedCurve rectangle circle text
- (ZZPaintPath *)getLinePathWithModel:(ZZDrawModel *)lineModel
{
    ZZPaintPath *path = nil;
    if([lineModel.type isEqualToString:@"closedCurve"]){ //闭合曲线
        NSArray *points = [self getStartEndPointsWithLineModel:lineModel];
        CGPoint startPoint = [[points safe_objectAtIndex:0]CGPointValue];
        CGPoint endPoint = [[points safe_objectAtIndex:1]CGPointValue];
        CGRect rect = [self getRectWithStartPoint:startPoint endPoint:endPoint];
        path = [ZZPaintPath paintPathWithOvalRect:rect lineWidth:3];
        path.lineColor = [self getStoreColorWithIndex:lineModel.color];
        return path;
    }else if ([lineModel.type isEqualToString:@"rectangle"]){ //矩形
        NSArray *points = [self getStartEndPointsWithLineModel:lineModel];
        CGPoint startPoint = [[points safe_objectAtIndex:0]CGPointValue];
        CGPoint endPoint = [[points safe_objectAtIndex:1]CGPointValue];
        CGRect rect = [self getRectWithStartPoint:startPoint endPoint:endPoint];
        path = [ZZPaintPath bezierPathWithRect:rect];
        path.lineColor = [self getStoreColorWithIndex:lineModel.color];
        return path;
    }else if ([lineModel.type isEqualToString:@"circle"]){ //正圆
        NSArray *points = [self getStartEndPointsWithLineModel:lineModel];
        CGPoint startPoint = [[points safe_objectAtIndex:0]CGPointValue];
        CGPoint endPoint = [[points safe_objectAtIndex:1]CGPointValue];
        CGFloat radius = [self getRadiusWithStartPoint:startPoint endPoint:endPoint];
        path = [ZZPaintPath bezierPathWithArcCenter:startPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        path.lineColor = [self getStoreColorWithIndex:lineModel.color];
    }else if([lineModel.type isEqualToString:@"text"]){ //文本
        path = [ZZPaintPath bezierPath];
        CGPoint textPoint = CGPointMake(lineModel.x * self.frame.size.width, lineModel.y *self.frame.size.height);
        path.lineColor = [self getStoreColorWithIndex:lineModel.color];
        path.textPoint = textPoint;
        path.text = lineModel.text;
        path.paintPathType = 3;
        path.fontsize = lineModel.fontsize;
        XXLog(@"text == %@",path.text);
        return path;
    }else{ //一般曲线
        if(lineModel.trail.count == 0){return nil;}
        NSMutableArray *trail = lineModel.trail;
        for(int i = 0;i<trail.count;i++){
            NSDictionary *dicPoint = [trail objectAtIndex:i];
            ZZDrawPointModel *point = [ZZDrawPointModel mj_objectWithKeyValues:dicPoint];
            CGPoint p = CGPointMake(point.x * self.frame.size.width, point.y * self.frame.size.height);
            if(i == 0){
                path = [ZZPaintPath paintPathWithLineWidth:3 startPoint:p lineColor:[UIColor blackColor]];
            }
            [path addLineToPoint:p];
        }
        if([lineModel.type isEqualToString:@"eraser"]){
            path.isEraser = YES;
        }
    }
    path.lineColor = [self getStoreColorWithIndex:lineModel.color];
    return path;
}
#pragma mark - 根据路径获取一个shapelayer
- (CAShapeLayer *)addLineLayerWithPath:(ZZPaintPath *)path lineColor:(int)colorIndex
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = path.lineWidth;
    layer.path = path.CGPath;
    return layer;
}
#pragma mark - 清理当前视图上的所有subLayer
- (void)clearAllSubLayers
{
    self.realImage = nil;
    self.layer.contents = nil;
    [self.bufferLines removeAllObjects];
}
#pragma mark - 添加一条远程的线
- (void)addRemoteLineWithModel:(ZZDrawModel *)drawModel
{
    ZZPaintPath *path = [self getLinePathWithModel:drawModel];
    [self drawingImageWithPath:path completed:nil];
}

#pragma mark - 重绘
- (void)reload_drawingImageWithPath:(NSMutableArray<ZZPaintPath *> *)paths completed:(void (^)(BOOL finish))completed
{
    @autoreleasepool{
        //1
        UIGraphicsBeginImageContext(self.bounds.size);
        //2
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, self.bounds);
        [[UIColor clearColor]setFill];
        UIRectFill(self.bounds);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        //3
        if(_realImage){
            [_realImage drawInRect:self.bounds];
        }
        //4
        for(int i = 0;i<paths.count;i++){
            ZZPaintPath *path = [paths objectAtIndex:i];
            if(path.paintPathType == 3){
                //文本
                [path.text drawAtPoint:path.textPoint withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:path.fontsize],NSForegroundColorAttributeName:path.lineColor}];
            }else{
                if(path.isEraser == YES){
                    CGContextSetBlendMode(context, kCGBlendModeClear);
                    CGContextSetLineWidth(context, 15.0f);
                }else{
                    CGContextSetBlendMode(context, kCGBlendModeNormal);
                    CGContextSetLineWidth(context, 3.0f);
                }
                CGContextSetStrokeColorWithColor(context, path.lineColor.CGColor);
                CGContextAddPath(context, path.CGPath);
                
            }
            CGContextStrokePath(context);
        }
        //5
        UIImage *previewImage = UIGraphicsGetImageFromCurrentImageContext();
        self.realImage = previewImage;
        UIGraphicsEndImageContext();
        //6
        _realImage = previewImage;
        self.layer.contents = (__bridge id _Nullable)(_realImage.CGImage);
    }
    if(completed){
        completed(YES);
    }
}

#pragma mark - 绘制线条
- (void)drawingImageWithPath:(ZZPaintPath *)path completed:(void (^)(BOOL finish))completed
{
    @autoreleasepool{
        //1
        UIGraphicsBeginImageContext(self.bounds.size);
        //2
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor clearColor]setFill];
        UIRectFill(self.bounds);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        //3
        if(_realImage){
            [_realImage drawInRect:self.bounds];
        }
        //4
        if(path.paintPathType == 3){
            //文本
            [path.text drawAtPoint:path.textPoint withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:path.fontsize],NSForegroundColorAttributeName:path.lineColor}];
        }else{
            //线条
            if(path.isEraser == YES){
                CGContextSetBlendMode(context, kCGBlendModeClear);
                CGContextSetLineWidth(context, 15.0f);
            }else{
                CGContextSetBlendMode(context, kCGBlendModeNormal);
                CGContextSetLineWidth(context, 3.0f);
            }
            CGContextSetStrokeColorWithColor(context, path.lineColor.CGColor);
            CGContextAddPath(context, path.CGPath);
        }
        CGContextStrokePath(context);
        //5
        UIImage *previewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //6
        _realImage = previewImage;
        self.layer.contents = (__bridge id _Nullable)(_realImage.CGImage);
    }
    if(completed){
        completed(YES);
    }
}

- (UIColor *)getStoreColorWithIndex:(int)colorIndex
{
    int colorHex = [_colorArr safe_intAtIndex:colorIndex];
    UIColor *color = [UIColor ZZ_colorWithHex:colorHex];
    return color;
}

- (void)setColorIndex:(int)colorIndex
{
    _colorIndex = colorIndex;
}

- (void)setIsEraser:(BOOL)isEraser
{
    _isEraser = isEraser;
    //    self.brush.isEraser = isEraser;
}

- (void)setStrokeWidth:(CGFloat)strokeWidth
{
    _strokeWidth = strokeWidth;
}

- (void)setPaintType:(ZZDrawBoardPaintType)paintType
{
    _paintType = paintType;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}
- (void)dealloc
{
    [_displayLinkHolder stop];
    XXLog(@"\n--dealloc--");
}

#pragma mark - 本地绘制
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    [self touchBeganWithPoint:p];
    _currentPaintModel.paintType = self.paintType;
    if(self.paintType == ZZDrawBoardPaintTypeLine){
        _currentPaintModel.touchType = ZZDrawBoardPointTypeStart;
        _currentPaintModel.defaultPoint = p;
        if([self.dataSource respondsToSelector:@selector(touchEventWithPaintModel:)]){
            [self.dataSource touchEventWithPaintModel:_currentPaintModel];
        }
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    [self touchMoveWithPoint:p];
    if(self.paintType == ZZDrawBoardPaintTypeLine){
        _currentPaintModel.touchType = ZZDrawBoardPointTypeMove;
        _currentPaintModel.defaultPoint = p;
        if([self.dataSource respondsToSelector:@selector(touchEventWithPaintModel:)]){
            [self.dataSource touchEventWithPaintModel:_currentPaintModel];
        }
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    [self touchEndWithPoint:p];
    if(self.paintType == ZZDrawBoardPaintTypeLine){
        _currentPaintModel.touchType = ZZDrawBoardPointTypeEnd;
        _currentPaintModel.defaultPoint = p;
        if([self.dataSource respondsToSelector:@selector(touchEventWithPaintModel:)]){
            [self.dataSource touchEventWithPaintModel:_currentPaintModel];
        }
    }else{
        _currentPaintModel.touchType = ZZDrawBoardPointTypeEnd;
        _currentPaintModel.startPoint = _startPoint;
        _currentPaintModel.endPoint = _endPoint;
        _currentPaintModel.radius = _radius;
        if([self.dataSource respondsToSelector:@selector(touchEventWithPaintModel:)]){
            [self.dataSource touchEventWithPaintModel:_currentPaintModel];
        }
    }
    //clear
    _startPoint = CGPointMake(0, 0);
    _endPoint = CGPointMake(0, 0);
    _radius = 0;
    _currentPath = nil;
}
- (void)touchBeganWithPoint:(CGPoint)point
{
    _myRealLayer.hidden = NO;
    self.drawState = ZZDrawBoardPointTypeStart;
    UIColor *color = [self getStoreColorWithIndex:self.colorIndex];
    ZZPaintPath *path;
    if(self.paintType == ZZDrawBoardPaintTypeLine){ //线
        path = [ZZPaintPath paintPathWithLineWidth:3 startPoint:point lineColor:color];
        path.lineColor = color;
        [path moveToPoint:point];
        _currentPath = path;
    }else if (self.paintType == ZZDrawBoardPaintTypeRectAngle){ //面
        _startPoint = point;
        path = [ZZPaintPath bezierPathWithRect:[self getRectWithStartPoint:_startPoint endPoint:_startPoint]];
        path.lineColor = color;
        _currentPath = path;
    }else if (self.paintType == ZZDrawBoardPaintTypeCircle){ //圆
        _startPoint = point;
        _radius = [self getRadiusWithStartPoint:_startPoint endPoint:_startPoint];
        path = [ZZPaintPath bezierPathWithArcCenter:_startPoint radius:_radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
        path.lineColor = color;
        _currentPath = path;
    }else if(self.paintType == ZZDrawBoardPaintTypeClosedCurve){ //闭合曲线
        _startPoint = point;
        path = [ZZPaintPath paintPathWithOvalRect:[self getRectWithStartPoint:_startPoint endPoint:_startPoint] lineWidth:3];
        path.lineColor = color;
        _currentPath = path;
    }
    if(self.isEraser){
        path.isEraser = YES;
    }
    _myRealLayer.strokeColor = path.lineColor.CGColor;
    _myRealLayer.path = _currentPath.CGPath;
}
- (void)touchMoveWithPoint:(CGPoint)point
{
    self.drawState = ZZDrawBoardPointTypeMove;
    if(self.paintType == ZZDrawBoardPaintTypeLine){ //线
       [_currentPath addLineToPoint:point];
    }else if (self.paintType == ZZDrawBoardPaintTypeRectAngle){ //面
        _endPoint = point;
        _currentPath = [ZZPaintPath bezierPathWithRect:[self getRectWithStartPoint:_startPoint endPoint:point]];
    }else if (self.paintType == ZZDrawBoardPaintTypeCircle){ //圆
        _endPoint = point;
        _radius = [self getRadiusWithStartPoint:_startPoint endPoint:_endPoint];
        _currentPath = [ZZPaintPath bezierPathWithArcCenter:_startPoint radius:_radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    }else if(self.paintType == ZZDrawBoardPaintTypeClosedCurve){ //闭合曲线
        _endPoint = point;
        _currentPath = [ZZPaintPath paintPathWithOvalRect:[self getRectWithStartPoint:_startPoint endPoint:_endPoint] lineWidth:3];
    }
    _myRealLayer.path = _currentPath.CGPath;
}
- (void)touchEndWithPoint:(CGPoint)point
{
    self.drawState = ZZDrawBoardPointTypeEnd;
    if(self.paintType == ZZDrawBoardPaintTypeLine){ //线
        [_currentPath addLineToPoint:point];
    }else if (self.paintType == ZZDrawBoardPaintTypeRectAngle){ //面
        _endPoint = point;
        _currentPath = [ZZPaintPath bezierPathWithRect:[self getRectWithStartPoint:_startPoint endPoint:point]];
    }else if (self.paintType == ZZDrawBoardPaintTypeCircle){ //圆
        _endPoint = point;
        _radius = [self getRadiusWithStartPoint:_startPoint endPoint:_endPoint];
        _currentPath = [ZZPaintPath bezierPathWithArcCenter:_startPoint radius:_radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    }else if(self.paintType == ZZDrawBoardPaintTypeClosedCurve){ //闭合曲线
        _endPoint = point;
        _currentPath = [ZZPaintPath paintPathWithOvalRect:[self getRectWithStartPoint:_startPoint endPoint:_endPoint] lineWidth:3];
    }
    _myRealLayer.hidden = YES;
    [self drawingImageWithPath:_currentPath completed:nil];
}

#pragma mark - 根据起始点获取Rect
- (CGRect)getRectWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGRect rect;
    rect.origin.x = startPoint.x;
    rect.origin.y = startPoint.y;
    rect.size.width = endPoint.x - startPoint.x;
    rect.size.height = endPoint.y - startPoint.y;
//    XXLog(@"rect.x = %f,y = %f,width = %f,height = %f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    return rect;
}
#pragma mark - 根据起始点获取radius
- (CGFloat)getRadiusWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    //a²+b²=c² float hypotf（float x，float y） fabs()
    CGFloat radius = 0;
    CGFloat a = endPoint.x - startPoint.x;
    CGFloat b = endPoint.y - startPoint.y;
    radius = hypotf(a, b);
//    XXLog(@"\nstartP.x = %f,startP.y = %f\nendP.x = %f,endP.y = %f\nradius == %f",startPoint.x,startPoint.y,endPoint.x,endPoint.y,radius);
    return radius;
}
@end


@implementation ZZPaintModel

@end
