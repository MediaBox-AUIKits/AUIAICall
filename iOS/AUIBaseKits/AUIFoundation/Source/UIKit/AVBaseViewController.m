//
//  AVBaseViewController.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import "AVBaseViewController.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"

@interface AVBaseViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *headerLineView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *menuButton;

@end

@implementation AVBaseViewController

@synthesize hiddenBackButton = _hiddenBackButton;
@synthesize hiddenMenuButton = _hiddenMenuButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = AUIFoundationColor(@"bg_weak");
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.av_width, 44 + AVSafeTop)];
    [self.view addSubview:headerView];
    self.headerView = headerView;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.av_bottom, self.view.av_width, self.view.av_height - headerView.av_bottom)];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, (self.headerView.av_height - AVSafeTop - 26) / 2.0 + AVSafeTop, 26, 26)];
    backButton.titleLabel.font = AVGetRegularFont(12.0);
    [backButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [backButton setImage:AUIFoundationImage(@"ic_back") forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:backButton];
    self.backButton = backButton;
    self.backButton.hidden = _hiddenBackButton;
    
    UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.headerView.av_right - 20 - 26, (self.headerView.av_height - AVSafeTop - 26) / 2.0 + AVSafeTop, 26, 26)];
    menuButton.titleLabel.font = AVGetRegularFont(12.0);
    [menuButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
    [menuButton setImage:AUIFoundationImage(@"ic_more") forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(onMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:menuButton];
    self.menuButton = menuButton;
    self.menuButton.hidden = _hiddenMenuButton;
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, AVSafeTop, self.headerView.av_width, self.headerView.av_height - AVSafeTop)];
    titleView.font = AVGetMediumFont(18);
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = AUIFoundationColor(@"text_strong");
    titleView.text = self.title;
    [self.headerView addSubview:titleView];
    [self.headerView sendSubviewToBack:titleView];
    self.titleView = titleView;
    
    UIView *headerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.av_height - 1, self.headerView.av_width, 1)];
    headerLineView.backgroundColor = AUIFoundationColor(@"border_infrared");
    headerLineView.hidden = YES;
    [self.headerView addSubview:headerLineView];
    self.headerLineView = headerLineView;
}

- (void)setHiddenBackButton:(BOOL)hiddenBackButton {
    _hiddenBackButton = hiddenBackButton;
    self.backButton.hidden = _hiddenBackButton;
}

- (BOOL)hiddenBackButton {
    if (!self.backButton) {
        return _hiddenBackButton;
    }
    return self.backButton.hidden;
}

- (void)setHiddenMenuButton:(BOOL)hiddenMenuButton {
    _hiddenMenuButton = hiddenMenuButton;
    self.menuButton.hidden = _hiddenMenuButton;
}

- (BOOL)hiddenMenuButton {
    if (!self.menuButton) {
        return _hiddenMenuButton;
    }
    return self.menuButton.hidden;
}

- (BOOL)disableInteractivePopGesture {
    return NO;
}

- (void)onBackBtnClicked:(UIButton *)sender {
    [self goBack];
}

- (void)goBack {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onMenuClicked:(UIButton *)sender {
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [AVTheme preferredStatusBarStyle];
}

// MARK: - 屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

@end
