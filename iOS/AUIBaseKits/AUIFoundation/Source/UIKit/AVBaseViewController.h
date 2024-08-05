//
//  AVBaseViewController.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import <UIKit/UIKit.h>
#import "AVNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVBaseViewController : UIViewController<AVUIViewControllerInteractivePopGesture>

@property (nonatomic, strong, readonly) UIView *headerView;
@property (nonatomic, strong, readonly) UIView *headerLineView;
@property (nonatomic, strong, readonly) UILabel *titleView;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (nonatomic, strong, readonly) UIButton *backButton;
@property (nonatomic, strong, readonly) UIButton *menuButton;

@property (nonatomic, assign) BOOL hiddenBackButton;
@property (nonatomic, assign) BOOL hiddenMenuButton;

- (void)goBack;

@end

NS_ASSUME_NONNULL_END
