//
//  ZZCADisplayLinkHolder.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZZCADisplayLinkHolder;
@protocol ZZCADisplayLinkHolderDelegate <NSObject>
- (void)onDisplayLinkFire:(ZZCADisplayLinkHolder *)holder
                 duration:(NSTimeInterval)duration
              displayLink:(CADisplayLink *)displayLink;
@end

@interface ZZCADisplayLinkHolder : NSObject

@property (nonatomic,weak  ) id<ZZCADisplayLinkHolderDelegate> delegate;

@property (nonatomic,assign) NSInteger frameInterval;

- (void)startCADisplayLinkWithDelegate: (id<ZZCADisplayLinkHolderDelegate>)delegate;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
