//
//  YSDMainTabbar.h
//  freeStuff
//
//  Created by 孙号斌 on 2017/12/29.
//  Copyright © 2017年 孙号斌. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CenterButtonWidth       92.0f

@interface YSDMainTabbar : UITabBar
@property (nonatomic, copy) void(^tabbarClickCenter)(void);
@end
