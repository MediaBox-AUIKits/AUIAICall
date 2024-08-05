//
//  AVTheme.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/14.
//

#import "AVTheme.h"
#import "UIColor+AVHelper.h"
#import "UIImage+AVHelper.h"
#import "NSDictionary+AVHelper.h"
#import "UIView+AVHelper.h"

@interface AVColorReader : NSObject

@property (nonatomic, copy) NSDictionary *lightColorMap;
@property (nonatomic, copy) NSDictionary *darkColorMap;


@end

@implementation AVColorReader

- (instancetype)initWithModule:(NSString *)module {
    self = [super init];
    if (self) {
        
        NSString *bundlePath = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:[module stringByAppendingString:@".bundle"]];
        
        NSString *darkPath = [bundlePath stringByAppendingString:@"/Theme/DarkMode/color.plist"];
        _darkColorMap = [NSDictionary dictionaryWithContentsOfFile:darkPath];
        
        NSString *lightPath = [bundlePath stringByAppendingString:@"/Theme/LightMode/color.plist"];
        _lightColorMap = [NSDictionary dictionaryWithContentsOfFile:lightPath];
        
    }
    return self;
}

- (UIColor *)colorNamed:(NSString *)name lightMode:(BOOL)lightMode {
    return lightMode ? [UIColor av_colorWithHexString:[self.lightColorMap av_stringValueForKey:name]] : [UIColor av_colorWithHexString:[self.darkColorMap av_stringValueForKey:name]];
}

@end

@interface AVTheme ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, AVColorReader *> *moduleColorMap;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSBundle *> *moduleImageBundleMap;

@property (nonatomic, assign) AVThemeMode currentMode;

// App是否支持自动模式
// YES时，支持AVThemeModeAuto，切换模式时实时生效
// NO时，AVThemeModeAuto与Light一致，切换模式时必须重启APP生效，
// iOS13及以上以上默认为YES，其他默认为NO。当你APP不支持多种主题模式时（即使是iOS13及以上），建议设置为NO，并选择Light或Dark作为你的界面UI样式
@property (nonatomic, assign) BOOL supportsAutoMode;

@property (nonatomic, strong, readonly, class) AVTheme *currentTheme;


@end

@implementation AVTheme

- (instancetype)init {
    self = [super init];
    if (self) {
        self.moduleColorMap = [NSMutableDictionary dictionary];
        self.moduleImageBundleMap = [NSMutableDictionary dictionary];
        if (@available(iOS 13.0, *)) {
            _supportsAutoMode = YES;
            self.currentMode = AVThemeModeLight;
        }
        else {
            _supportsAutoMode = NO;
            self.currentMode = AVThemeModeLight;
        }
    }
    return self;
}

- (void)setSupportsAutoMode:(BOOL)supportsAutoMode {
    if (@available(iOS 13.0, *)) {
        _supportsAutoMode = supportsAutoMode;
    }
    else {
        _supportsAutoMode = NO;
    }
}

#pragma mark - Color

- (AVColorReader *)addColorModule:(NSString *)module {
    if (module.length == 0) {
        return nil;
    }
    AVColorReader *colorReader = [self.moduleColorMap objectForKey:module];
    if (colorReader) {
        return colorReader;
    }
    colorReader = [[AVColorReader alloc] initWithModule:module];
    [self.moduleColorMap setObject:colorReader forKey:module];
    return colorReader;
}

- (UIColor *)colorNamed:(NSString *)name opacity:(CGFloat)opacity module:(NSString *)module {
    if (name.length == 0) {
        return nil;
    }
    AVColorReader *colorReader = [self addColorModule:module];
    UIColor *lightColor = [colorReader colorNamed:name lightMode:YES];
    UIColor *darkColor = [colorReader colorNamed:name lightMode:NO];
    if (opacity >= 0) {
        lightColor = [lightColor colorWithAlphaComponent:opacity];
        darkColor = [darkColor colorWithAlphaComponent:opacity];
    }
    
    if (self.supportsAutoMode) {
        NSAssert(darkColor, @"In auto mode, darkColor(name:%@) can't be nil", name);
        NSAssert(lightColor, @"In auto mode, lightColor(name:%@) can't be nil", name);
        return [UIColor av_colorWithLightColor:lightColor darkColor:darkColor];
    }
    
    if (self.currentMode == AVThemeModeDark) {
        NSAssert(darkColor, @"In dark mode, darkColor(name:%@) can't be nil", name);
        return darkColor;
    }

    NSAssert(lightColor, @"In light mode, lightColor(name:%@) can't be nil", name);
    return lightColor;
}

- (UIColor *)colorNamed:(NSString *)name module:(NSString *)module {
    return [self colorNamed:name opacity:-1.0 module:module];
}


#pragma mark - Image

- (NSBundle *)addImageModule:(NSString *)module {
    NSBundle *bundle = [self.moduleImageBundleMap objectForKey:module];
    if (bundle) {
        return bundle;
    }
    
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:[module stringByAppendingString:@".bundle/Theme"]];
    bundle = [NSBundle bundleWithPath:path];
    [self.moduleImageBundleMap setObject:bundle forKey:module];
    return bundle;
}

- (UIImage *)imageWithLightNamed:(NSString *)lightNamed withDarkNamed:(NSString *)darkNamed inBundle:(nullable NSBundle *)bundle {
    
    if (self.supportsAutoMode) {
        return [UIImage av_imageWithLightNamed:lightNamed withDarkNamed:darkNamed inBundle:bundle];
    }
    
    if (self.currentMode == AVThemeModeDark) {
        UIImage *image = [UIImage imageNamed:darkNamed inBundle:bundle compatibleWithTraitCollection:nil];
        return image;
    }

    UIImage *image = [UIImage imageNamed:lightNamed inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

- (UIImage *)imageNamed:(NSString *)name module:(NSString *)module {
    if (name.length == 0) {
        return nil;
    }
    NSBundle *bundle = [self addImageModule:module];
    NSString *lightNamed = [NSString stringWithFormat:@"LightMode/%@", name];
    NSString *darkNamed = [NSString stringWithFormat:@"DarkMode/%@", name];
    return [self imageWithLightNamed:lightNamed withDarkNamed:darkNamed inBundle:bundle];
}

- (UIImage *)imageWithCommonNamed:(NSString *)named module:(NSString *)module {
    if (named.length == 0) {
        return nil;
    }
    NSBundle *bundle = [self addImageModule:module];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"Common/%@", named] inBundle:bundle compatibleWithTraitCollection:nil];
    return image;
}

#pragma mark - Global Methods

+ (AVTheme *)currentTheme {
    static AVTheme *_global = nil;
    if (!_global) {
        _global = [AVTheme new];
    }

    return _global;
}

+ (void)setCurrentMode:(AVThemeMode)themeMode {
    [AVTheme.currentTheme setCurrentMode:themeMode];
    if (AVTheme.currentTheme.supportsAutoMode) {
        [self updateRootViewInterfaceStyle:UIView.av_mainWindow];
    }
}

+ (AVThemeMode)currentMode {
    return AVTheme.currentTheme.currentMode;
}

+ (void)setSupportsAutoMode:(BOOL)supportsAutoMode {
    [AVTheme.currentTheme setSupportsAutoMode:supportsAutoMode];
}

+ (BOOL)supportsAutoMode {
    return AVTheme.currentTheme.supportsAutoMode;
}

+ (UIColor *)colorWithNamed:(NSString *)named withModule:(NSString *)module {
    return [AVTheme.currentTheme colorNamed:named module:module];
}

+ (UIColor *)colorWithNamed:(NSString *)named withOpacity:(CGFloat)opacity withModule:(NSString *)module {
    return [AVTheme.currentTheme colorNamed:named opacity:opacity module:module];
}

+ (UIImage *)imageWithNamed:(NSString *)named withModule:(NSString *)module {
    return [AVTheme.currentTheme imageNamed:named module:module];
}

+ (UIImage *)imageWithCommonNamed:(NSString *)named withModule:(NSString *)module {
    return [AVTheme.currentTheme imageWithCommonNamed:named module:module];
}

+ (UIImage *)imageWithLightNamed:(NSString *)lightNamed withDarkNamed:(NSString *)darkNamed inBundle:(NSBundle *)bundle {
    return [AVTheme.currentTheme imageWithLightNamed:lightNamed withDarkNamed:darkNamed inBundle:bundle];
}

+ (UIFont *)semiboldFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Semibold" size:size];
}

+ (UIFont *)mediumFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Medium" size:size];
}

+ (UIFont *)regularFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
}

+ (UIFont *)lightFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Light" size:size];
}

+ (UIFont *)ultralightFont:(CGFloat)size {
    return [UIFont fontWithName:@"PingFangSC-Ultralight" size:size];
}

+ (UIStatusBarStyle)preferredStatusBarStyle {
    if (AVTheme.supportsAutoMode) {
        return UIStatusBarStyleDefault;
    }
    if (AVTheme.currentMode == AVThemeModeDark) {
        return UIStatusBarStyleLightContent;
    }
    
    // auth or light
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    }
    return UIStatusBarStyleDefault;
}

+ (void)updateRootViewInterfaceStyle:(UIView *)view {
    if (AVTheme.currentMode == AVThemeModeDark) {
        if (@available(iOS 13.0, *)) {
            view.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }
        return;
    }
    
    if (AVTheme.currentMode == AVThemeModeLight) {
        if (@available(iOS 13.0, *)) {
            view.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        return;
    }
    
    if (@available(iOS 13.0, *)) {
        view.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }
}

+ (void)updateRootViewControllerInterfaceStyle:(UIViewController *)vc {
    if (AVTheme.currentMode == AVThemeModeDark) {
        if (@available(iOS 13.0, *)) {
            vc.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }
        return;
    }
    
    if (AVTheme.currentMode == AVThemeModeLight) {
        if (@available(iOS 13.0, *)) {
            vc.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
        return;
    }
    
    if (@available(iOS 13.0, *)) {
        vc.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }
}

@end

@implementation AVTheme (AUIFoundation)

#define ModuleName @"AUIFoundation"
#define MethodImplementation(method)  +(UIColor *)method {return [AVTheme colorWithNamed:@#method withModule:ModuleName];}


MethodImplementation(bg_weak)
MethodImplementation(bg_medium)
MethodImplementation(fg_strong)

MethodImplementation(text_strong)
MethodImplementation(text_ultrastrong)
MethodImplementation(text_medium)
MethodImplementation(text_weak)
MethodImplementation(text_ultraweak)
MethodImplementation(text_infrared)
MethodImplementation(text_link)
MethodImplementation(text_link_press)

MethodImplementation(border_strong)
MethodImplementation(border_medium)
MethodImplementation(border_weak)
MethodImplementation(border_ultraweak)
MethodImplementation(border_infrared)

MethodImplementation(ic_strong)
MethodImplementation(ic_medium)
MethodImplementation(ic_weak)
MethodImplementation(ic_ultraweak)
MethodImplementation(ic_press)

MethodImplementation(fill_ultrastrong)
MethodImplementation(fill_strong)
MethodImplementation(fill_medium)
MethodImplementation(fill_weak)
MethodImplementation(fill_ultraweak)
MethodImplementation(fill_infrared)
MethodImplementation(fill_microwave)

MethodImplementation(tsp_fill_ultrastrong)
MethodImplementation(tsp_fill_strong)
MethodImplementation(tsp_fill_medium)
MethodImplementation(tsp_fill_weak)
MethodImplementation(tsp_fill_ultraweak)
MethodImplementation(tsp_fill_infrared)

MethodImplementation(colourful_text_strong)
MethodImplementation(colourful_ic_strong)
MethodImplementation(colourful_border_strong)
MethodImplementation(colourful_border_weak)
MethodImplementation(colourful_fg_strong)
MethodImplementation(colourful_fill_ultrastrong)
MethodImplementation(colourful_fill_strong)
MethodImplementation(colourful_fill_disabled)

+ (UIImage *)getCommonImage:(NSString *)key {
    return [self imageWithCommonNamed:key withModule:@"AUIFoundation"];
}

+ (UIImage *)getImage:(NSString *)key {
    return [self imageWithNamed:key withModule:@"AUIFoundation"];
}

@end
