//
//  AVBaseControllPanel.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import "AVBaseControllPanel.h"
#import "AVLocalization.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"

@interface AVControllPanelBackgroundView : UIView

@property (nonatomic, copy) void(^clickedBlock)(AVControllPanelBackgroundView *sender);
@property (nonatomic, assign) BOOL passClickEvent;
@property (nonatomic, assign) BOOL receiveClickedEvent;

@end

@implementation AVControllPanelBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.receiveClickedEvent = NO;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.receiveClickedEvent && self.clickedBlock) {
            self.clickedBlock(self);
        }
    });

    if (!self.passClickEvent) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

@end

@interface AVBaseControllPanel ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *headerLineView;
@property (nonatomic, strong) UILabel *titleView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, weak) AVControllPanelBackgroundView *bgView;

@end

@implementation AVBaseControllPanel
@synthesize menuButton = _menuButton;
@synthesize backButton = _backButton;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), [self.class panelHeight])];
    if (self) {
        self.backgroundColor = AUIFoundationColor(@"bg_weak");
                        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.av_width, 46)];
        [self addSubview:headerView];
        self.headerView = headerView;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.av_bottom, self.av_width, self.av_height - headerView.av_bottom)];
        [self addSubview:contentView];
        self.contentView = contentView;
        
        UIView *headerLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.headerView.av_height - 1, self.headerView.av_width, 1)];
        headerLineView.backgroundColor = AUIFoundationColor(@"fg_strong");
        [self.headerView addSubview:headerLineView];
        self.headerLineView = headerLineView;
        
        UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.headerView.av_width, self.headerView.av_height)];
        titleView.font = AVGetRegularFont(14);
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor = AUIFoundationColor(@"text_strong");
        titleView.text = @"Controll Panel";
        [self.headerView addSubview:titleView];
        self.titleView = titleView;
    }
    return self;
}

- (UIButton *)menuButton {
    if (!_menuButton) {
        UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(self.headerView.av_right - 18 - 26, (self.headerView.av_height - 26) / 2.0, 26, 26)];
        menuButton.titleLabel.font = AVGetRegularFont(12.0);
        [menuButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [menuButton setImage:AUIFoundationImage(@"ic_more") forState:UIControlStateNormal];
        menuButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [menuButton addTarget:self action:@selector(onMenuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:menuButton];
        _menuButton = menuButton;
    }
    return _menuButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(18, (self.headerView.av_height - 26) / 2.0, 26, 26)];
        backButton.titleLabel.font = AVGetRegularFont(12.0);
        [backButton setTitleColor:AUIFoundationColor(@"text_strong") forState:UIControlStateNormal];
        [backButton setImage:AUIFoundationImage(@"ic_back") forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [backButton addTarget:self action:@selector(onBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:backButton];
        _backButton = backButton;
    }
    return _backButton;
}

- (void)setShowBackButton:(BOOL)showBackButton {
    self.backButton.hidden = !showBackButton;
}

- (BOOL)showBackButton {
    return _backButton && !_backButton.hidden;
}

- (void)setShowMenuButton:(BOOL)showMenuButton {
    self.menuButton.hidden = !showMenuButton;
}

- (BOOL)showMenuButton {
    return _menuButton && !_menuButton.hidden;
}

- (UIView *)bgViewOnShowing {
    return self.bgView;
}

+ (CGFloat)panelHeight {
    return 300;
}

+ (void)present:(AVBaseControllPanel *)cp onView:(UIView *)onView backgroundType:(AVControllPanelBackgroundType)bgType {
    CGFloat fromY = onView.av_height;
    CGFloat toY = onView.av_height - [self panelHeight];
    cp.frame = CGRectMake(0, fromY, onView.av_width, [self panelHeight]);
    [onView addSubview:cp];
    cp.isShowing = YES;
    
    if (bgType == AVControllPanelBackgroundTypeNone) {
        [UIView animateWithDuration:0.2 animations:^{
            cp.av_top = toY;
        }];
        return;
    }
    
    AVControllPanelBackgroundView *bgView = [[AVControllPanelBackgroundView alloc] initWithFrame:onView.bounds];
    bgView.clickedBlock = ^(AVControllPanelBackgroundView *sender) {
        if (bgType == AVControllPanelBackgroundTypeModal) {
            return;
        }
        [AVBaseControllPanel dismiss:cp];
        sender.receiveClickedEvent = YES;
    };
    bgView.passClickEvent = bgType == AVControllPanelBackgroundTypeCloseAndPassEvent;
    [onView insertSubview:bgView belowSubview:cp];
    
    bgView.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        cp.av_top = toY;
        bgView.alpha = 1.0;
    }];
    cp.bgView = bgView;
}


+ (void)dismiss:(AVBaseControllPanel *)cp {
    if (cp.bgView) {
        [cp.bgView removeFromSuperview];
    }
    
    cp.isShowing = NO;
    [UIView animateWithDuration:0.2 animations:^{
        cp.av_top = cp.superview.av_height;
    } completion:^(BOOL finished) {
        [cp removeFromSuperview];
    }];
}

- (void)setIsShowing:(BOOL)isShowing {
    if (_isShowing == isShowing) {
        return;
    }
    _isShowing = isShowing;
    [self onShowChange:isShowing];
}

- (void)onShowChange:(BOOL)isShow {
    if (self.onShowChanged) {
        self.onShowChanged(self);
    }
}

- (void)showOnView:(UIView *)onView {
    [self showOnView:onView withBackgroundType:AVControllPanelBackgroundTypeClickToClose];
}

- (void)showOnView:(UIView *)onView withBackgroundType:(AVControllPanelBackgroundType)bgType {
    if (_isShowing) {
        return;
    }
    [self.class present:self onView:onView backgroundType:bgType];
}

- (void)hide {
    if (!_isShowing) {
        return;
    }
    [self.class dismiss:self];
}

- (void)onBackBtnClicked:(UIButton *)sender {
    [self hide];
}

- (void)onMenuBtnClicked:(UIButton *)sender {
    
}

@end
