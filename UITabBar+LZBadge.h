//
//  UITabBar+LZBadge.h
//  LizhiRun
//
//  Created by 孙号斌 on 2018/7/27.
//  Copyright © 2018年 SX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (LZBadge)
- (void)showBadgeOnItemIndex:(int)index;
- (void)hideBadgeOnItemIndex:(int)index;
@end
