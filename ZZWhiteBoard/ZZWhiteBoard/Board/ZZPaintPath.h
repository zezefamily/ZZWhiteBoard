//
//  ZZPaintPath.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZZPaintPath : UIBezierPath

@property (nonatomic,assign) int colorIndex;

@property (nonatomic,strong) UIColor *paintColor;

@property (nonatomic,strong) UIColor *lineColor;

@property (nonatomic,assign) CGColorRef colorRef;

@property (nonatomic,assign) BOOL isEraser;

@property (nonatomic,assign) CGPoint textPoint;

@property (nonatomic,copy) NSString *text;

@property (nonatomic,assign) float fontsize;   //字号

@property (nonatomic,assign) NSInteger paintPathType;

+ (instancetype)paintPathWithLineWidth:(CGFloat)width startPoint:(CGPoint)point lineColor:(UIColor *)lineColor;

+ (instancetype)paintPathWithOvalRect:(CGRect)rect lineWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
