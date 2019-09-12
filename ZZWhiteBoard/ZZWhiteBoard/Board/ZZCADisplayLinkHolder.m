//
//  ZZCADisplayLinkHolder.m
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import "ZZCADisplayLinkHolder.h"

@implementation ZZCADisplayLinkHolder
{
    CADisplayLink *_displayLink;
}
- (instancetype)init
{
    if (self = [super init]) {
        _frameInterval = 1;
    }
    return self;
}

- (void)dealloc
{
    [self stop];
    _delegate = nil;
}

- (void)startCADisplayLinkWithDelegate:(id<ZZCADisplayLinkHolderDelegate>)delegate
{
    _delegate = delegate;
    [self stop];
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
    if(@available(iOS 10.0,*)){
        [_displayLink setPreferredFramesPerSecond:10];
    }else{
        [_displayLink setFrameInterval:_frameInterval];
    }
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop
{
    if (_displayLink){
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void)onDisplayLink: (CADisplayLink *) displayLink
{
    if (_delegate && [_delegate respondsToSelector:@selector(onDisplayLinkFire:duration:displayLink:)]){
        [_delegate onDisplayLinkFire:self
                            duration:displayLink.duration
                         displayLink:displayLink];
    }
}
@end
