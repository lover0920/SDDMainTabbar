//
//  YSDMainTabBarController.h
//  freeStuff
//
//  Created by 孙号斌 on 2017/11/3.
//  Copyright © 2017年 孙号斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LZHomeViewController.h"
#import "LZOutdoorRunViewController.h"
#import "LZIndoorRunViewController.h"
#import "LZUserCenterViewController.h"
#import "LZRunCircleViewController.h"

@interface YSDMainTabBarController : UITabBarController
@property (nonatomic, strong) LZHomeViewController *homeVC;
@property (nonatomic, strong) LZRunCircleViewController *circleVC;
@property (nonatomic, strong) LZUserCenterViewController *userCenterVC;

@end
