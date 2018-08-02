//
//  YSDMainTabBarController.m
//  freeStuff
//
//  Created by 孙号斌 on 2017/11/3.
//  Copyright © 2017年 孙号斌. All rights reserved.
//

#import "YSDMainTabBarController.h"
#import "YSDMainTabbar.h"
#import "YSDBasicNavigationController.h"
#import "LZBadgeModel.h"
#import "LZRCIMManage.h"
#import "UITabBar+LZBadge.h"

#import "LZRunModelSelectView.h"
#import "YSDDialogView.h"

@interface YSDMainTabBarController ()
@property (nonatomic, strong) YSDMainTabbar *myTabbar;

@property (nonatomic, assign) BOOL noTask;
@property (nonatomic, assign) NSInteger taskTimeType;       //0 全天，     1 晨跑
@property (nonatomic, assign) NSInteger taskRunTimeType;    //0 20分钟，   1 40分钟
@end

@implementation YSDMainTabBarController

#pragma mark - 生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorWhite;
    
    [self createViewControllers];
    [self setupTabbar];
    [self requestMessageCount];
    //监听自定义消息
    [NSNoti addObserver:self
               selector:@selector(taskStatusChanged:)
                   name:kJPushCustomNoti
                 object:nil];
    [NSNoti addObserver:self
               selector:@selector(haveNewIMMessage)
                   name:kImNewMessage
                 object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self haveRunData];
}
#pragma mark - 初始化
- (void)setupTabbar
{
    //tabbar
    _myTabbar = [[YSDMainTabbar alloc] init];
    WS(weakSelf);
    _myTabbar.tabbarClickCenter = ^{
        [weakSelf requestStartRun];
    };
    [self setValue:_myTabbar forKeyPath:@"tabBar"];
    
    //背景
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -32, SCREEN_WIDTH, 81+CGFloatSafety)];
    imageView.image = [[UIImage imageNamed:@"tabbarbg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(35, 4, 20, 86) resizingMode:UIImageResizingModeTile];
    imageView.userInteractionEnabled = YES;
    [self.tabBar addSubview:imageView];
    
    self.tabBar.backgroundImage = [[UIImage alloc]init];
    self.tabBar.shadowImage = [[UIImage alloc]init];
}
- (void)createViewControllers
{
    _homeVC = [[LZHomeViewController alloc]init];
    _circleVC = [[LZRunCircleViewController alloc] init];
    _userCenterVC = [[LZUserCenterViewController alloc]init];
    
    
    [self setupChildVC:_homeVC
                 title:@"首页"
             imageName:@"tabbar_run_nor"
     selectedImageName:@"tabbar_run_pre"];
    
    [self setupChildVC:_circleVC
                 title:@"跑圈动态"
             imageName:@"tabbar_circle_nor"
     selectedImageName:@"tabbar_circle_pre"];
    
    [self setupChildVC:_userCenterVC
                 title:@"我的"
             imageName:@"tabbar_profile_nor"
     selectedImageName:@"tabbar_profile_pre"];
    
    [self setupChildVC:[[UIViewController alloc] init]
                 title:nil
             imageName:nil
     selectedImageName:nil];
}
- (void)setupChildVC:(UIViewController *)childVC
               title:(NSString *)title
           imageName:(NSString *)imageName
   selectedImageName:(NSString *)selectedImageName
{
    childVC.title = title;
    childVC.tabBarItem.image = [UIImage imageNamed:imageName];
    childVC.tabBarItem.selectedImage = [UIImage imageNamed:selectedImageName];
    YSDBasicNavigationController *nav = [[YSDBasicNavigationController alloc]initWithRootViewController:childVC];
    [self addChildViewController:nav];
}

#pragma mark - 消息数
//初始化消息数
- (void)requestMessageCount
{
    WS(weakSelf);
    [YSDApi homeMessageCountWithSuccess:^(NSDictionary *responseObject) {
        [weakSelf requestMessageCountSuccess:[responseObject objectForKey:@"data"]];
    }];
}
- (void)requestMessageCountSuccess:(NSDictionary *)responseDic
{
    //解析
    if (responseDic)
    {
        [LZBadgeModel instance].systemCount = [[responseDic objectForKey:@"systemMessageCount"] integerValue];
        [LZBadgeModel instance].dynamicCount = [[responseDic objectForKey:@"dynamicMessageCount"] integerValue];
        [LZBadgeModel instance].friendCount = [[responseDic objectForKey:@"friendMessageCount"] integerValue];
        [LZBadgeModel instance].followedCount = [[responseDic objectForKey:@"followedMessageCount"] integerValue];
        [LZBadgeModel instance].invitedCount = [[responseDic objectForKey:@"invitedMessageCount"] integerValue];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //首页
        NSInteger homeCount = [LZBadgeModel instance].RCIMCount + [LZBadgeModel instance].systemCount;
        if (homeCount==0)
            [self.tabBar hideBadgeOnItemIndex:0];
        else
            [self.tabBar showBadgeOnItemIndex:0];
        
        //跑圈
        if ([LZBadgeModel instance].dynamicCount==0)
            [self.tabBar hideBadgeOnItemIndex:1];
        else
            [self.tabBar showBadgeOnItemIndex:1];
        
        //个人中心
        NSInteger myCount = [LZBadgeModel instance].friendCount +
                            [LZBadgeModel instance].followedCount +
                            [LZBadgeModel instance].invitedCount;
        if (myCount==0)
            [self.tabBar hideBadgeOnItemIndex:2];
        else
            [self.tabBar showBadgeOnItemIndex:2];

    });
}
//通知
- (void)taskStatusChanged:(NSNotification *)noti
{
    
    NSSLog(@"%@",noti);
    
    NSDictionary *extras = [noti.userInfo objectForKey:@"extras"];
    NSInteger type = [[extras objectForKey:@"type"] integerValue];
    if (type==21)
    {
        [self requestMessageCountSuccess:extras];
    }
}
- (void)haveNewIMMessage
{
    [self requestMessageCountSuccess:nil];
}


#pragma mark - 判断是否有未完成的任务
- (void)haveRunData
{
    LZRunDataModel *runModel = [SDStoreUtils readKeyedUnarchiverFile:kRunningData];
    if (runModel != nil)
    {
        if (runModel.saveDay != [[NSDate date] day]) {
            [self deleteRunningData];
            return;
        }
        NSInteger index = runModel.runType==1 ? 1 : 0;
        YSDDialogView *dialog = [[YSDDialogView alloc] initWithTitle:@"是否继续跑步" message:nil cancle:@"继续" otherBtn:@"不继续"];
        WS(weakSelf);
        dialog.cancleButtonBlock = ^{
            [weakSelf toRunViewController:index];
        };
        dialog.otherButtonBlock = ^{
            [weakSelf deleteRunningData];
        };
    }
}

- (void)deleteRunningData
{
    [SDStoreUtils deleteKeyedArchiverFile:kRunningData];
}

#pragma mark - 网络请求
- (void)requestStartRun
{
    if (EmptyStr([YSDAppStatus currentTaskID]))
    {
        _noTask = YES;
    }
    
    WS(weakSelf);
    [MBProgressHUD showActivityInWindow:@""];
    [YSDApi homeStartTaskSuccess:^(NSDictionary *responseObject) {
        [weakSelf requestStartRunSuccess:responseObject];
    }];
}
- (void)requestStartRunSuccess:(NSDictionary *)responseDic
{
    NSDictionary *dic = [responseDic objectForKey:@"data"];
    
    NSString *key = [NSString stringWithFormat:@"TaskID%@",[YSDAppStatus userID]];
    NSInteger taskType = [[dic objectForKey:@"taskType"] integerValue];
    NSInteger taskStatus = [[dic objectForKey:@"taskStatus"] integerValue];
    NSString *taskID = [dic objectForKey:@"taskID"];
    NSString *groupID = [dic objectForKey:@"groupID"];
    _taskRunTimeType = [[dic objectForKey:@"taskRunTimeType"] integerValue];
    _taskTimeType = [[dic objectForKey:@"taskTimeType"] integerValue];
    [SDStoreUtils saveKeychainValue:taskID key:key];
    
    if (taskStatus < 2)//未开始
    {
        if (taskType==1)//单人
        {
            YSDDialogView *dialog = [[YSDDialogView alloc] initWithTitle:@"开始跑步后无法添加新的监督者，您确定要开始吗？" message:nil cancle:@"是" otherBtn:@"否"];
            WS(weakSelf);
            dialog.cancleButtonBlock = ^{
                [weakSelf requestStartSingleTask:taskID];
            };
        }
        else//组队
        {
            YSDDialogView *dialog = [[YSDDialogView alloc] initWithTitle:@"是否开始跑步？" message:@"开始跑步后不能再添加队友" cancle:@"是" otherBtn:@"否"];
            WS(weakSelf);
            dialog.cancleButtonBlock = ^{
                [weakSelf requestStartGroupTask:groupID];
            };
        }
    }
    else
    {
        if (_noTask)
        {
            [NSNoti postNotificationName:kRefreshHomeCurrentTask object:nil];
        }
        [self toPostVC];
    }
}

- (void)requestStartSingleTask:(NSString *)taskID
{
    WS(weakSelf);
    [MBProgressHUD showActivityInWindow:nil];
    [YSDApi homeStartSingleTaskWithTaskID:taskID success:^(NSDictionary *responseObject) {
        [weakSelf toPostVC];
        [NSNoti postNotificationName:kRefreshHomeCurrentTask object:nil];
    } failed:nil error:nil];
}
- (void)requestStartGroupTask:(NSString *)groupID
{
    WS(weakSelf);
    [MBProgressHUD showActivityInWindow:nil];
    [YSDApi homeStartGroupTaskWithGroupID:groupID success:^(NSDictionary *responseObject) {
        [weakSelf toPostVC];
        [NSNoti postNotificationName:kRefreshHomeCurrentTask object:nil];
    } failed:nil error:nil];
}

#pragma mark - 进入Post页面
- (void)toPostVC
{
    /*************** 判断时间段 ***************/
    NSString *toHour = self.taskRunTimeType == 0 ? @"8:40" : @"8:20";
    
    if (self.taskTimeType==1 && ![NSDate isBetweenFromHour:@"4:00" toHour:toHour])
    {
        YSDDialogView *dialog = [[YSDDialogView alloc] initWithTitle:@"不在晨跑打卡时间段" message:@"晨跑打卡须在早4~9点间完成，其他时段无法打卡" otherBtn:@"确定"];
        return;
    }
    
    
    LZRunModelSelectView *selectView = [[LZRunModelSelectView alloc] init];
    WS(weakSelf);
    selectView.selectedRunModeBlock = ^(NSInteger index) {
        [weakSelf toRunViewController:index];
    };
    
}
- (void)toRunViewController:(NSInteger)index
{
    if (index == 0)//室外
    {
        LZOutdoorRunViewController *outdoorVC = [[LZOutdoorRunViewController alloc] init];
        outdoorVC.taskRunTimeType = _taskRunTimeType;
        outdoorVC.taskTimeType = _taskTimeType;
        
        YSDBasicNavigationController *nav = [[YSDBasicNavigationController alloc]initWithRootViewController:outdoorVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else//室内
    {
        LZIndoorRunViewController *indoorVC = [[LZIndoorRunViewController alloc] init];
        indoorVC.taskRunTimeType = _taskRunTimeType;
        indoorVC.taskTimeType = _taskTimeType;
        
        YSDBasicNavigationController *nav = [[YSDBasicNavigationController alloc]initWithRootViewController:indoorVC];
        
        [self presentViewController:nav animated:YES completion:nil];
    }
}


- (void)dealloc
{
    [NSNoti removeObserver:self];
}








#pragma mark - 私有方法
- (UIImage *)imageLeftRightStretch:(UIImage *)image
                     containerSize:(CGSize)imageViewSize
{
    CGSize imageSize = image.size;
    CGSize bgSize = CGSizeMake(floorf(imageViewSize.width), floorf(imageViewSize.height));
    
    UIImage *tempImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(35, 4, 20, 86) resizingMode:UIImageResizingModeTile];
    CGFloat tempWidth = (bgSize.width - imageSize.width)/2 + imageSize.width;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tempWidth, bgSize.height), NO, [UIScreen mainScreen].scale);

    [tempImage drawInRect:CGRectMake(0, 0, tempWidth, bgSize.height)];

    UIImage *firstStrechImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *secondStrechImage = [firstStrechImage resizableImageWithCapInsets:UIEdgeInsetsMake(40, tempWidth-30, 20, 20) resizingMode:UIImageResizingModeTile];
    
    return tempImage;
}


@end
