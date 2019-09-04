//
//  ZZPaintPath.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "ZZPaintPath.h"

@implementation ZZPaintPath

+ (instancetype)paintPathWithLineWidth:(CGFloat)width startPoint:(CGPoint)point lineColor:(UIColor *)lineColor
{
    ZZPaintPath *path = [[ZZPaintPath alloc]init];
    path.lineWidth = width;
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path moveToPoint:point];
    return path;
}
+ (instancetype)paintPathWithRect:(CGRect)rect lineWidth:(CGFloat)width
{
    ZZPaintPath *path = [ZZPaintPath bezierPathWithOvalInRect:rect];
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    path.lineWidth = 3;
    return path;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
}

@end
