//
//  ZZLayerDrawBoard.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/10/23.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "ZZLayerDrawBoard.h"
#import "ZZCADisplayLinkHolder.h"
#import "ZZLinesManager.h"
#import "ZZPaintPath.h"

@interface ZZLayerDrawBoard ()<ZZCADisplayLinkHolderDelegate>
{
    BOOL _isDrawingFinish;
    BOOL _isTouchLayer;
    ZZPaintModel *_currentPaintModel;
    CGPoint _startPoint;
    CGPoint _endPoint;
    CGFloat _radius;
    CAShapeLayer *_bgContentLayer;
    CGAffineTransform _currentTransfrom;
    CGPoint _longPrePoint;
}
@property (nonatomic,assign) ZZDrawBoardPointType drawState;
@property (nonatomic,strong) UIImage *realImage;
@property (nonatomic,strong) ZZPaintPath *currentPath;
@property (nonatomic, strong) ZZCADisplayLinkHolder  *displayLinkHolder;     // 渲染的计时器
@property (nonatomic,strong) CAShapeLayer *myRealLayer;  // 本地实时层
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,strong) NSMutableArray *bufferLines;  // 当前page所有线条
@property(nonatomic, strong) NSArray *colorArr;
@property (nonatomic,strong) NSMutableArray *allLayerArray;
@end

@implementation ZZLayerDrawBoard

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
//        self.layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        //拉伸过滤
        self.layer.magnificationFilter = kCAFilterNearest;
        _displayLinkHolder = [ZZCADisplayLinkHolder new];
        [_displayLinkHolder setFrameInterval:1];
        [_displayLinkHolder startCADisplayLinkWithDelegate:self];
        self.paintType = ZZDrawBoardPaintTypeLine;
        if(_bgContentLayer == nil){
            _bgContentLayer = [CAShapeLayer new];
//            _bgContentLayer.backgroundColor = [UIColor whiteColor].CGColor;
//            _bgContentLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            [self.layer addSublayer:_bgContentLayer];
        }
        self.bufferLines = [NSMutableArray array];
        self.allLayerArray = [NSMutableArray array];
        _currentPaintModel = [[ZZPaintModel alloc]init];
        
        _currentTransfrom = CGAffineTransformIdentity;
        
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
////        longPress.minimumPressDuration = 1.0f;
//        [self addGestureRecognizer:longPress];
//        self.userInteractionEnabled = YES;
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
    
    if(_bgContentLayer == nil){
        _bgContentLayer = [CAShapeLayer new];
        [self.layer addSublayer:_bgContentLayer];
    }
    for(int i = 0;i<linesModelArray.count;i++){
        ZZDrawModel *draw = [linesModelArray objectAtIndex:i];
        ZZPaintPath *path = [self getLinePathWithModel:draw];
        path.lineColor = [self getStoreColorWithIndex:draw.color];
        path.lineWidth = 3;
        CAShapeLayer *layer = [self addLineLayerWithPath:path lineColor:draw.color];
        layer.bounds = path.bounds;
        layer.frame = path.bounds;
        [_bgContentLayer addSublayer:layer];
    }
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
    path.usesEvenOddFillRule = YES;
    return path;
}
#pragma mark - 根据路径获取一个shapelayer
- (CAShapeLayer *)addLineLayerWithPath:(ZZPaintPath *)path lineColor:(int)colorIndex
{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.actions = nil;
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.strokeColor = path.lineColor.CGColor;
    layer.lineWidth = 3;
    layer.path = path.CGPath;
    return layer;
}
#pragma mark - 清理当前视图上的所有subLayer
- (void)clearAllSubLayers
{
//    if(self.allLayerArray.count == 0){return;}
//    for (CAShapeLayer *layer in self.allLayerArray) {
//        [layer removeFromSuperlayer];
//    }
//    [self.allLayerArray removeAllObjects];
    _bgContentLayer.sublayers = nil;
    [_bgContentLayer removeFromSuperlayer];
    _bgContentLayer = nil;
    
}
#pragma mark - 添加一条远程的线
- (void)addRemoteLineWithModel:(ZZDrawModel *)drawModel
{
    ZZPaintPath *path = [self getLinePathWithModel:drawModel];
    path.lineColor = [self getStoreColorWithIndex:drawModel.color];
    CAShapeLayer *layer = [self addLineLayerWithPath:path lineColor:drawModel.color];
    [self.allLayerArray addObject:layer];
    [_bgContentLayer addSublayer:layer];
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
    [self touchBeganWithPoint:p touches:touches withEvent:event];
    _currentPaintModel.paintType = self.paintType;
    if(self.paintType == ZZDrawBoardPaintTypeLine){
        _currentPaintModel.touchType = ZZDrawBoardPointTypeStart;
        _currentPaintModel.defaultPoint = p;
        if(!_isTouchLayer){
            if([self.dataSource respondsToSelector:@selector(touchEventWithPaintModel:)]){
                [self.dataSource touchEventWithPaintModel:_currentPaintModel];
            }
        }
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    [self touchMoveWithPoint:p touches:touches withEvent:event];
    if(!_isTouchLayer){
        if(self.paintType == ZZDrawBoardPaintTypeLine){
            _currentPaintModel.touchType = ZZDrawBoardPointTypeMove;
            _currentPaintModel.defaultPoint = p;
            if([self.dataSource respondsToSelector:@selector(touchEventWithPaintModel:)]){
                [self.dataSource touchEventWithPaintModel:_currentPaintModel];
            }
        }
    }
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    [self touchEndWithPoint:p touches:touches withEvent:event];
    
    if(!_isTouchLayer){
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
    }
    //clear
    _startPoint = CGPointMake(0, 0);
    _endPoint = CGPointMake(0, 0);
    _radius = 0;
    _currentPath = nil;
}
- (void)touchBeganWithPoint:(CGPoint)point touches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"curP====%@",NSStringFromCGPoint(point));
    CAShapeLayer *selectLayer = [_bgContentLayer hitTest:point];
    if(selectLayer != nil && selectLayer != _bgContentLayer){
        _isTouchLayer = YES;
        selectLayer.strokeColor = [UIColor greenColor].CGColor;
        _shapeLayer = selectLayer;
        return;
    }
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
    CAShapeLayer *layer = [self addLineLayerWithPath:path lineColor:self.colorIndex];
    [self.allLayerArray addObject:layer];
    [_bgContentLayer addSublayer:layer];
    _shapeLayer = layer;
    
}

//#pragma mark - 长按手势
//- (void)longPress:(UILongPressGestureRecognizer *)longPree
//{
//    XXLog(@"longPress");
//    CGPoint point = [longPree locationInView:self];
//    if(longPree.state == UIGestureRecognizerStateBegan){
//        CAShapeLayer *selectLayer = [_bgContentLayer hitTest:point];
//        if(selectLayer != nil && selectLayer != _bgContentLayer){
//            _isTouchLayer = YES;
//            _longPrePoint = point;
//        }
//    }else if (longPree.state == UIGestureRecognizerStateChanged){
//        CGFloat offsetX = point.x - _longPrePoint.x;
//        CGFloat offsetY = point.y - _longPrePoint.y;
//        _shapeLayer.affineTransform = CGAffineTransformTranslate(_shapeLayer.affineTransform,offsetX,offsetY);
//        _longPrePoint = point;
//    }else if (UIGestureRecognizerStateEnded){
//        _isTouchLayer = NO;
//    }
//}

- (void)touchMoveWithPoint:(CGPoint)point touches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"curP====%@",NSStringFromCGPoint(point));
    if(_isTouchLayer){
        CGPoint prePoint = [[touches anyObject]previousLocationInView:self];
        CGFloat offsetX = point.x - prePoint.x;
        CGFloat offsetY = point.y - prePoint.y;
        _shapeLayer.affineTransform = CGAffineTransformTranslate(_shapeLayer.affineTransform,offsetX,offsetY);
        return;
    }
    self.drawState = ZZDrawBoardPointTypeMove;
    if(self.paintType == ZZDrawBoardPaintTypeLine){ //线
        [_currentPath addLineToPoint:point];
    }else if (self.paintType == ZZDrawBoardPaintTypeRectAngle){ //面
        _endPoint = point;
        _currentPath = [ZZPaintPath bezierPathWithRect:[self getRectWithStartPoint:_startPoint endPoint:point]];
//        _shapeLayer.frame = [self getRectWithStartPoint:_startPoint endPoint:point];
    }else if (self.paintType == ZZDrawBoardPaintTypeCircle){ //圆
        _endPoint = point;
        _radius = [self getRadiusWithStartPoint:_startPoint endPoint:_endPoint];
        _currentPath = [ZZPaintPath bezierPathWithArcCenter:_startPoint radius:_radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    }else if(self.paintType == ZZDrawBoardPaintTypeClosedCurve){ //闭合曲线
        _endPoint = point;
        _currentPath = [ZZPaintPath paintPathWithOvalRect:[self getRectWithStartPoint:_startPoint endPoint:_endPoint] lineWidth:3];
    }
    if(_currentPath.isEraser){
        XXLog(@"橡皮");
        [self drawEraserPath:_currentPath layer:_shapeLayer];
    }else{
        _shapeLayer.path = _currentPath.CGPath;
        _shapeLayer.lineWidth = 3;
    }
}
- (void)touchEndWithPoint:(CGPoint)point touches:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if(_isTouchLayer){
        _isTouchLayer = NO;
        return;
    }
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
    if(_currentPath.isEraser){
        [self drawEraserPath:_currentPath layer:_shapeLayer];
    }else{
        _shapeLayer.path = _currentPath.CGPath;
        _shapeLayer.frame = _currentPath.bounds;
        _shapeLayer.bounds = _currentPath.bounds;
        _shapeLayer.lineWidth = 3;
    }
    
}

#pragma mark - 根据起始点获取Rect
- (CGRect)getRectWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGRect rect;
    rect.origin.x = startPoint.x;
    rect.origin.y = startPoint.y;
    rect.size.width = endPoint.x - startPoint.x;
    rect.size.height = endPoint.y - startPoint.y;
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
    return radius;
}

- (void)drawEraserPath:(ZZPaintPath *)path layer:(CALayer *)eraserLayer
{
    @autoreleasepool {
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
//        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextSetLineWidth(context, 15.0f);
        CGContextSetStrokeColorWithColor(context, path.lineColor.CGColor);
        CGContextAddPath(context, path.CGPath);
        CGContextStrokePath(context);
        //5
        UIImage *previewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //6
        _realImage = previewImage;
        _bgContentLayer.contents = (__bridge id _Nullable)(_realImage.CGImage);
    }
}

@end


