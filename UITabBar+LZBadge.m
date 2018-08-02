//
//  UITabBar+LZBadge.m
//  LizhiRun
//
//  Created by 孙号斌 on 2018/7/27.
//  Copyright © 2018年 SX. All rights reserved.
//

#import "UITabBar+LZBadge.h"
#define TabbarItemNums 4.0

@implementation UITabBar (LZBadge)
//显示红点
- (void)showBadgeOnItemIndex:(int)index
{
    [self removeBadgeOnItemIndex:index];
    //新建小红点
    UIView *bview = [[UIView alloc]init];
    bview.tag = 888+index;
    bview.layer.cornerRadius = 4;
    bview.clipsToBounds = YES;
    bview.backgroundColor = [UIColor redColor];
    CGRect tabFram = self.frame;
    
    float percentX = (index+0.56)/TabbarItemNums;
    CGFloat x = ceilf(percentX*tabFram.size.width);
    CGFloat y = 10;
    bview.frame = CGRectMake(x, y, 8, 8);
    [self addSubview:bview];
    [self bringSubviewToFront:bview];
}
//隐藏红点
-(void)hideBadgeOnItemIndex:(int)index
{
    [self removeBadgeOnItemIndex:index];
}
//移除控件
- (void)removeBadgeOnItemIndex:(int)index
{
    for (UIView*subView in self.subviews)
    {
        if (subView.tag == 888+index)
        {
            [subView removeFromSuperview];
        }
    }
}

@end
