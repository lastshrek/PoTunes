//
//  PCNavigationController.m
//  TicketExchange
//
//  Created by Purchas on 14/11/28.
//  Copyright (c) 2014年 Purchas. All rights reserved.
//

#import "PCNavigationController.h"

@interface PCNavigationController ()

@end

@implementation PCNavigationController
+ (void)initialize {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    /** 1.设置导航栏样式 */
    UINavigationBar * navBar = [UINavigationBar appearance];
    navBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidden = self.view.hidden;
}

/** 重写这个方法，能拦截所有的push操作 */
/** 重写push方法，让每一个navigation的hidesBottomBarWhenPushed都是YES */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
