//
//  AVBaseControllPanel.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVControllPanelBackgroundType) {
    AVControllPanelBackgroundTypeNone,  // Not bg
    AVControllPanelBackgroundTypeClickToClose, // click bg to close
    AVControllPanelBackgroundTypeCloseAndPassEvent,  // click bg to close and pass the event
    AVControllPanelBackgroundTypeModal,  // modal state
};

@interface AVBaseControllPanel : UIView

@property (nonatomic, strong, readonly) UIView *headerView;
@property (nonatomic, strong, readonly) UILabel *titleView;
@property (nonatomic, strong, readonly) UIView *contentView;

@property (nonatomic, strong, readonly) UIButton *backButton;
@property (nonatomic, strong, readonly) UIButton *menuButton;
@property (nonatomic, assign) BOOL showMenuButton;
@property (nonatomic, assign) BOOL showBackButton;

@property (nonatomic, weak, readonly) UIView *bgViewOnShowing;

@property (nonatomic, readonly) BOOL isShowing;
@property (nonatomic, copy, nullable) void(^onShowChanged)(AVBaseControllPanel *sender);

- (void)showOnView:(UIView *)onView;
- (void)showOnView:(UIView *)onView withBackgroundType:(AVControllPanelBackgroundType)bgType;
- (void)hide;
- (void)onShowChange:(BOOL)isShow;  // override by sub class

+ (CGFloat)panelHeight;
+ (void)present:(AVBaseControllPanel *)cp onView:(UIView *)onView backgroundType:(AVControllPanelBackgroundType)bgType;

+ (void)dismiss:(AVBaseControllPanel *)cp;


@end

NS_ASSUME_NONNULL_END
