
//
//  ZZToolBar.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "ZZToolBar.h"
@interface ZZToolBar ()
{
    NSMutableArray *_buttons;
    CGRect _frame;
}
@end
@implementation ZZToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self ==  [super initWithFrame:frame]){
        _frame = frame;
        [self loadUI];
    }
    return self;
}
- (void)loadUI
{
    _buttons = [NSMutableArray array];
    NSArray *btns = @[@"线",@"矩形",@"正圆",@"闭合曲线",@"橡皮",@"撤销",@"清空",@"拖拽"];
    for(int i = 0;i<btns.count;i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(15+60*i, 0, 50, _frame.size.height);
        [btn setTitle:btns[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 5000 + i;
        [self addSubview:btn];
        [_buttons addObject:btn];
        if(i == 0){
            btn.selected = YES;
        }
    }
}
- (void)btnClick:(UIButton *)sender
{
    NSInteger tag = sender.tag - 5000;
    if([self.delegate respondsToSelector:@selector(toolButtonDidSelectedWithTag:sender:)]){
        [self.delegate toolButtonDidSelectedWithTag:tag sender:sender];
    }
    if(tag<4){
        for (UIButton *btn in _buttons) {
            if(sender == btn){
                btn.selected = YES;
            }else{
                btn.selected = NO;
            }
        }
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
