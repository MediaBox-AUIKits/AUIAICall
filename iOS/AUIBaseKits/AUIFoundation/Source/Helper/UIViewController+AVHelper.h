//
//  UIViewController+AVHelper.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UIViewControllerAPContainerProtocol<NSObject>
@optional
- (BOOL)controlStatusBarAppearance;
@end

@interface UIViewController (AVHelper)

- (void)av_presentFullScreenViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion;

- (void)av_insertChildViewController:(UIViewController *)childViewController onView:(UIView *)parentView index:(NSInteger)index;
- (void)av_displayChildViewController:(UIViewController *)childViewController onView:(UIView *)parentView;
- (void)av_displayChildViewController:(UIViewController *)childViewController;
- (void)av_hideChildViewController:(UIViewController *)childViewController;
- (void)av_hideFromParentViewController;

+ (UIViewController *)av_topViewController;

+ (void)av_setIdleTimerDisabled:(BOOL)disbaled;

@end

NS_ASSUME_NONNULL_END
