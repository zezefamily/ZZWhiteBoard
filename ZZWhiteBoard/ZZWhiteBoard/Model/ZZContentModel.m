//
//  ZZContentModel.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "ZZContentModel.h"

@implementation ZZContentModel

@end

@implementation ZZDrawModel
- (NSMutableArray *)trail
{
    if(!_trail){
        _trail = [NSMutableArray array];
    }
    return _trail;
}
//- (NSString *)description
//{
//    return [NSString stringWithFormat:@"trail == %@,type == %@",self.trail,self.type];
//}
@end

@implementation ZZDrawPointModel
@end
