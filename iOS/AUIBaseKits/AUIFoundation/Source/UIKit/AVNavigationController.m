//
//  AVNavigationController.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/21.
//

#import "AVNavigationController.h"
#import "AUIFoundationMacro.h"

@interface AVNavigationController ()
@end

@implementation AVNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.hidden = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.hidden = YES;

    __weak typeof(self) weakSelf = self;
    self.interactivePopGestureRecognizer.delegate = (id)weakSelf;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        //屏蔽调用rootViewController的滑动返回手势，避免右滑返回手势引起卡死问题
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
        if ([self.visibleViewController conformsToProtocol:@protocol(AVUIViewControllerInteractivePopGesture)]) {
            id<AVUIViewControllerInteractivePopGesture> p = (id<AVUIViewControllerInteractivePopGesture>)self.visibleViewController;
            if ([p respondsToSelector:@selector(disableInteractivePopGesture)]) {
                if ([p disableInteractivePopGesture]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [AVTheme preferredStatusBarStyle];
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

-(BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
