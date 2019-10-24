//
//  BoardDefine.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/10/23.
//  Copyright © 2019 泽泽. All rights reserved.
//

#ifndef BoardDefine_h
#define BoardDefine_h

#import <Foundation/Foundation.h>

/**
 绘制类型
 */
typedef NS_ENUM(NSInteger,ZZDrawBoardPaintType){
    ZZDrawBoardPaintTypeLine = 0,            //线 pencil
    ZZDrawBoardPaintTypeRectAngle = 1,       //矩形 rectangle
    ZZDrawBoardPaintTypeCircle = 2,          //圆 circle
    ZZDrawBoardPaintTypeClosedCurve = 3,     //闭合曲线 closedCurve
    ZZDrawBoardPaintTypeText = 4             //文本 text
};

/**
 线数据开始结束标记
 */
typedef NS_ENUM(NSInteger,ZZDrawBoardPointType)
{
    ZZDrawBoardPointTypeStart = 1,
    ZZDrawBoardPointTypeMove = 2,
    ZZDrawBoardPointTypeEnd = 3
};

/**
 当前画板类型
 */
typedef NS_ENUM(NSInteger,ZZWhiteboardLinesMode){
    ZZWhiteboardLinesMode_WhiteBoard = 0,            //白板数据
    ZZWhiteboardLinesMode_PPT = 1,                   //普通PPT数据
    ZZWhiteboardLinesMode_iSpring = 2                //动态PPT数据
};



#endif /* BoardDefine_h */


