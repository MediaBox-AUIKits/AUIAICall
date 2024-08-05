//
//  UIViewController+AVHelper.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/2.
//

#import "UIViewController+AVHelper.h"
#import "UIView+AVHelper.h"

@implementation UIViewController (AVHelper)

- (void)av_presentFullScreenViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (!viewControllerToPresent) {
        return;
    }
    viewControllerToPresent.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
    viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = YES;
    [self presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)av_displayChildViewController:(UIViewController *)childViewController onView:(UIView *)parentView {
    if(!childViewController)
    {
        NSAssert(0, @"childViewController can not be nil");
        return;
    }
    if(!parentView)
    {
        NSAssert(0, @"parentView can not be nil");
        return;
    }
    
    [self addChildViewController:childViewController];
    [parentView addSubview:childViewController.view];
    
    [childViewController didMoveToParentViewController:self];
    
    [self updateStatusBarAppearanceIfNeedWithChildViewControllerAdded:childViewController];
}

- (void)av_insertChildViewController:(UIViewController *)childViewController onView:(UIView *)parentView index:(NSInteger)index {
    if(!childViewController) {
        NSAssert(0, @"childViewController can not be nil");
        return;
    }
    if(!parentView) {
        NSAssert(0, @"parentView can not be nil");
        return;
    }
    
    [self addChildViewController:childViewController];
    [parentView insertSubview:childViewController.view atIndex:index];
    
    [childViewController didMoveToParentViewController:self];
    
    [self updateStatusBarAppearanceIfNeedWithChildViewControllerAdded:childViewController];
}

- (void)av_displayChildViewController:(UIViewController *)childViewController {
    [self av_displayChildViewController:childViewController onView:self.view];
}

- (void)av_hideChildViewController:(UIViewController *)childViewController {
    [childViewController av_hideFromParentViewController];
}

- (void)av_hideFromParentViewController {
    UIViewController *parentVC = self.parentViewController;
    [self willMoveToParentViewController:nil];
    
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    
    if (parentVC) {
        [parentVC updateStatusBarAppearanceIfNeedWithChildViewControllerAdded:self];
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    if ([self.childViewControllers count]) {
        UIViewController *lastChildViewController = [self.childViewControllers lastObject];
        UIViewController <UIViewControllerAPContainerProtocol> *viewController = (UIViewController <UIViewControllerAPContainerProtocol> *)[self viewControllerConformsToProtocol:@protocol(UIViewControllerAPContainerProtocol) withViewController:lastChildViewController];
        if (viewController
            && [viewController respondsToSelector:@selector(controlStatusBarAppearance)]
            && [viewController controlStatusBarAppearance])
        {
            return viewController;
        }
    }
    return nil;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    if ([self.childViewControllers count]) {
        UIViewController *lastChildViewController = [self.childViewControllers lastObject];
        UIViewController <UIViewControllerAPContainerProtocol> *viewController = (UIViewController <UIViewControllerAPContainerProtocol> *)[self viewControllerConformsToProtocol:@protocol(UIViewControllerAPContainerProtocol) withViewController:lastChildViewController];
        if (viewController
            && [viewController respondsToSelector:@selector(controlStatusBarAppearance)]
            && [viewController controlStatusBarAppearance])
        {
            return viewController;
        }
    }
    return nil;
}

- (void)updateStatusBarAppearanceIfNeedWithChildViewControllerAdded:(UIViewController *)childViewController
{
    UIViewController <UIViewControllerAPContainerProtocol> *viewController = (UIViewController <UIViewControllerAPContainerProtocol> *)[self viewControllerConformsToProtocol:@protocol(UIViewControllerAPContainerProtocol) withViewController:childViewController];
    if (viewController && [viewController respondsToSelector:@selector(controlStatusBarAppearance)])
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (UIViewController *)viewControllerConformsToProtocol:(Protocol *)aProtocol withViewController:(UIViewController *)viewController {
    if (!(viewController && aProtocol))
    {
        return nil;
    }
    
    if ([viewController conformsToProtocol:aProtocol])
    {
        return viewController;
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UIViewController *topViewController = [(UINavigationController *)viewController topViewController];
        if ([topViewController conformsToProtocol:aProtocol])
        {
            return topViewController;
        }
    }
    
    return nil;
}

+ (UIViewController *) av_topViewController {
    UIWindow *window = UIView.av_keyWindow;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = UIApplication.sharedApplication.windows;
        for (UIWindow *tmp in windows) {
            if (tmp.windowLevel == UIWindowLevelNormal) {
                window = tmp;
                break;
            }
        }
    }
    NSAssert(window.windowLevel == UIWindowLevelNormal, @"Can not found showing window");
    
    UIViewController *topViewController = window.rootViewController;
    while (topViewController) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)topViewController;
            topViewController = nav.visibleViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            return topViewController;
        }
    }
    return nil;
}

+ (void)av_setIdleTimerDisabled:(BOOL)disbaled {
    
    static NSInteger g_count = 0;
    if (disbaled) {
        g_count++;
    }
    else {
        g_count--;
        if (g_count < 0) {
            g_count = 0;
        }
    }

    UIApplication.sharedApplication.idleTimerDisabled = g_count > 0;
    NSLog(@"idleTimerDisabled:%@", g_count > 0 ? @"YES" : @"NO");
}

@end
