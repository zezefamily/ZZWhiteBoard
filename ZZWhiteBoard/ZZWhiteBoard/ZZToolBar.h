//
//  ZZToolBar.h
//  ZZWhiteBoard
//
//  Created by 泽泽 on 2019/9/4.
//  Copyright © 2019 泽泽. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZZToolBarDelegate <NSObject>

- (void)toolButtonDidSelectedWithTag:(NSInteger)tag sender:(UIButton *)sender;

@end

@interface ZZToolBar : UIView

@property (nonatomic,weak) id<ZZToolBarDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
