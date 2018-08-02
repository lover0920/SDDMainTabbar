//
//  YSDMainTabbar.m
//  freeStuff
//
//  Created by 孙号斌 on 2017/12/29.
//  Copyright © 2017年 孙号斌. All rights reserved.
//

#import "YSDMainTabbar.h"

@interface YSDMainTabbar()
@property (nonatomic, strong) UIButton *centerButton;
@end

@implementation YSDMainTabbar
#pragma mark - 初始化属性
- (UIButton *)centerButton
{
    if (!_centerButton) {
        
        _centerButton = [[UIButton alloc] init];
        _centerButton.adjustsImageWhenHighlighted = NO;
        [_centerButton setBackgroundImage:[UIImage imageNamed:@"tabbar_center"]
                                 forState:UIControlStateNormal];
        [_centerButton addTarget:self
                          action:@selector(clickCenterButton:)
                forControlEvents:UIControlEventTouchDown];
        [self addSubview:_centerButton];
    }
    return _centerButton;
}





#pragma mark - 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //中间按钮的位置
    self.centerButton.frame = CGRectMake(SCREEN_WIDTH-92, -33, CenterButtonWidth, 82);
    
    //图片下移
    for (NSInteger i=0; i<3; i++)
    {
        UITabBarItem *item = [self.items objectAtIndex:i];
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
        
    }
    
    //取消掉文字
    NSMutableDictionary *atts=[NSMutableDictionary dictionary];
    atts[NSFontAttributeName]=[UIFont systemFontOfSize:2];
    atts[NSForegroundColorAttributeName]=[UIColor clearColor];
    
    NSMutableDictionary *selectedAtts=[NSMutableDictionary dictionary];
    selectedAtts[NSFontAttributeName]=atts[NSFontAttributeName];
    selectedAtts[NSForegroundColorAttributeName]=[UIColor clearColor];
    for (UITabBarItem *item in self.items)
    {
        [item setTitleTextAttributes:atts forState:UIControlStateNormal];
        [item setTitleTextAttributes:selectedAtts forState:UIControlStateSelected];
    }
}





#pragma mark - 按钮的点击事件
- (void)clickCenterButton:(UIButton *)button
{
    if (self.tabbarClickCenter)
    {
        self.tabbarClickCenter();
    }
}

#pragma mark - 修改点击点位置
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.isHidden == NO)
    {
        CGPoint newP = [self convertPoint:point toView:self.centerButton];
        if ( [self.centerButton pointInside:newP withEvent:event])
        {
            return self.centerButton;
        }else
        {
            return [super hitTest:point withEvent:event];
        }
    }
    else
    {
        return [super hitTest:point withEvent:event];
    }
}
@end
