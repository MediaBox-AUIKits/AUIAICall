//
//  AVTheme.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define AVGetColor(key, module)  [AVTheme colorWithNamed:(key) withModule:(module)]
#define AVGetColor2(key, opacity, module)  [AVTheme colorWithNamed:(key) withOpacity:(opacity) withModule:(module)]
#define AVGetImage(key, module)  [AVTheme imageWithNamed:(key) withModule:(module)]
#define AVGetCommonImage(key, module)  [AVTheme imageWithCommonNamed:(key) withModule:(module)]

#define AVGetSemiboldFont(size)  [AVTheme semiboldFont:(size)]
#define AVGetMediumFont(size)  [AVTheme mediumFont:(size)]
#define AVGetRegularFont(size)  [AVTheme regularFont:(size)]
#define AVGetLightFont(size)  [AVTheme lightFont:(size)]
#define AVGetUltralightFont(size)  [AVTheme ultralightFont:(size)]

typedef NS_ENUM(NSUInteger, AVThemeMode) {
    AVThemeModeAuto,  //supportsAutoMode为NO时，与Light一致
    AVThemeModeLight,
    AVThemeModeDark,
};

@interface AVTheme : NSObject

@property (nonatomic, assign, class) AVThemeMode currentMode;

// App是否支持自动模式
// YES时，支持AVThemeModeAuto，切换模式时实时生效
// NO时，AVThemeModeAuto与Light一致，切换模式时必须重启APP生效，
// iOS13及以上以上默认为YES，其他默认为NO。当你APP不支持多种主题模式时（即使是iOS13及以上），建议设置为NO，并选择Light或Dark作为你的界面UI样式
@property (nonatomic, assign, class) BOOL supportsAutoMode;

+ (UIColor *)colorWithNamed:(NSString *)named withModule:(NSString *)moduleNamed;
+ (UIColor *)colorWithNamed:(NSString *)named withOpacity:(CGFloat)opacity withModule:(NSString *)moduleNamed;

+ (UIImage *)imageWithNamed:(NSString *)named withModule:(NSString *)moduleNamed;
+ (UIImage *)imageWithCommonNamed:(NSString *)named withModule:(NSString *)moduleNamed;
+ (UIImage *)imageWithLightNamed:(NSString *)lightNamed withDarkNamed:(NSString *)darkNamed inBundle:(nullable  NSBundle *)bundle;

+ (UIFont *)semiboldFont:(CGFloat)size;
+ (UIFont *)mediumFont:(CGFloat)size;
+ (UIFont *)regularFont:(CGFloat)size;
+ (UIFont *)lightFont:(CGFloat)size;
+ (UIFont *)ultralightFont:(CGFloat)size;

+ (UIStatusBarStyle)preferredStatusBarStyle;

+ (void)updateRootViewInterfaceStyle:(UIView *)view;
+ (void)updateRootViewControllerInterfaceStyle:(UIViewController *)vc;

@end

#define GetColorMethodDefine(method)  @property (nonatomic, readonly, class) UIColor *method;
@interface AVTheme (AUIFoundation)

GetColorMethodDefine(bg_weak)
GetColorMethodDefine(bg_medium)
GetColorMethodDefine(fg_strong)

GetColorMethodDefine(text_ultrastrong)
GetColorMethodDefine(text_strong)
GetColorMethodDefine(text_medium)
GetColorMethodDefine(text_weak)
GetColorMethodDefine(text_ultraweak)
GetColorMethodDefine(text_infrared)
GetColorMethodDefine(text_link)
GetColorMethodDefine(text_link_press)

GetColorMethodDefine(border_strong)
GetColorMethodDefine(border_medium)
GetColorMethodDefine(border_weak)
GetColorMethodDefine(border_ultraweak)
GetColorMethodDefine(border_infrared)

GetColorMethodDefine(ic_strong)
GetColorMethodDefine(ic_medium)
GetColorMethodDefine(ic_weak)
GetColorMethodDefine(ic_ultraweak)
GetColorMethodDefine(ic_press)

GetColorMethodDefine(fill_ultrastrong)
GetColorMethodDefine(fill_strong)
GetColorMethodDefine(fill_medium)
GetColorMethodDefine(fill_weak)
GetColorMethodDefine(fill_ultraweak)
GetColorMethodDefine(fill_infrared)
GetColorMethodDefine(fill_microwave)

GetColorMethodDefine(tsp_fill_ultrastrong)
GetColorMethodDefine(tsp_fill_strong)
GetColorMethodDefine(tsp_fill_medium)
GetColorMethodDefine(tsp_fill_weak)
GetColorMethodDefine(tsp_fill_ultraweak)
GetColorMethodDefine(tsp_fill_infrared)

GetColorMethodDefine(colourful_text_strong)
GetColorMethodDefine(colourful_ic_strong)
GetColorMethodDefine(colourful_border_strong)
GetColorMethodDefine(colourful_border_weak)
GetColorMethodDefine(colourful_fg_strong)
GetColorMethodDefine(colourful_fill_ultrastrong)
GetColorMethodDefine(colourful_fill_strong)
GetColorMethodDefine(colourful_fill_disabled)

+ (UIImage *)getCommonImage:(NSString *)key;
+ (UIImage *)getImage:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
