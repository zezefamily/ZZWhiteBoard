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
//        [self reDrawWithLines:drawLines];
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

#pragma mark - 获取一个路径
- (ZZPaintPath *)getLinePathWithModel:(ZZDrawModel *)lineModel
{
    ZZPaintPath *path = nil;
    if([lineModel.type isEqualToString:@"ellipse"]){
        //闭合曲线
        CGRect rect = CGRectMake(lineModel.rectX *self.frame.size.width, lineModel.rectY *self.frame.size.height, lineModel.rectWidth*self.frame.size.width, lineModel.rectHeight*self.frame.size.height);
        path = [ZZPaintPath paintPathWithRect:rect lineWidth:3];
        path.lineColor = [self getStoreColorWithIndex:lineModel.color];
        return path;
    }
    if([lineModel.type isEqualToString:@"text"]){
        //绘制文本
        path = [ZZPaintPath bezierPath];
        CGPoint textPoint = CGPointMake(lineModel.x * self.frame.size.width, lineModel.y *self.frame.size.height);
        path.lineColor = [self getStoreColorWithIndex:lineModel.color];
        path.textPoint = textPoint;
        path.text = lineModel.text;
        path.paintPathType = 3;
        path.fontsize = lineModel.fontsize;
        XXLog(@"text == %@",path.text);
        return path;
    }else{
        //一般线条、多边形
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
    if([self.dataSource respondsToSelector:@selector(touchEventWithType:point:)]){
        [self.dataSource touchEventWithType:ZZDrawBoardPointTypeStart point:p];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    [self touchMoveWithPoint:p];
    if([self.dataSource respondsToSelector:@selector(touchEventWithType:point:)]){
        [self.dataSource touchEventWithType:ZZDrawBoardPointTypeStart point:p];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint p = [[touches anyObject]locationInView:self];
    [self touchEndWithPoint:p];
    if([self.dataSource respondsToSelector:@selector(touchEventWithType:point:)]){
        [self.dataSource touchEventWithType:ZZDrawBoardPointTypeStart point:p];
    }
}

- (void)touchBeganWithPoint:(CGPoint)point
{
    _myRealLayer.hidden = NO;
    self.drawState = ZZDrawBoardPointTypeStart;
    UIColor *color = [self getStoreColorWithIndex:self.colorIndex];
    ZZPaintPath *path = [ZZPaintPath paintPathWithLineWidth:3 startPoint:point lineColor:color];
    path.lineColor = color;
    _myRealLayer.strokeColor = path.lineColor.CGColor;
    [path moveToPoint:point];
    _currentPath = path;
    _myRealLayer.path = _currentPath.CGPath;
}
- (void)touchMoveWithPoint:(CGPoint)point
{
    self.drawState = ZZDrawBoardPointTypeMove;
    [_currentPath addLineToPoint:point];
    _myRealLayer.path = _currentPath.CGPath;
}
- (void)touchEndWithPoint:(CGPoint)point
{
    self.drawState = ZZDrawBoardPointTypeEnd;
    [_currentPath addLineToPoint:point];
    _myRealLayer.hidden = YES;
    [self drawingImageWithPath:_currentPath completed:nil];
}


@end
