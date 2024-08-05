//
//  AVProgressHUD.h
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVProgressHUDIconType) {
    AVProgressHUDIconTypeNone,
    AVProgressHUDIconTypeLoading,
    AVProgressHUDIconTypeSuccess,
    AVProgressHUDIconTypeWarn,
};

typedef NS_ENUM(NSUInteger, AVProgressHUDShowPos) {
    AVProgressHUDShowPosTop,
    AVProgressHUDShowPosMid,
    AVProgressHUDShowPosBottom,
};

@interface AVProgressHUD : UIView
@property (nonatomic, assign) AVProgressHUDIconType iconType;
@property (nonatomic, copy) NSString *labelText;
@property (nonatomic, assign) AVProgressHUDShowPos position;

+ (AVProgressHUD *)ShowHUDAddedTo:(UIView *)view animated:(BOOL)animated;
+ (AVProgressHUD *)ShowMessage:(NSString *)message inView:(UIView *)view;
+ (BOOL)HideHUDForView:(UIView *)view animated:(BOOL)animated;
+ (AVProgressHUD *)HUDForView:(UIView *)view;

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;
@end

NS_ASSUME_NONNULL_END
