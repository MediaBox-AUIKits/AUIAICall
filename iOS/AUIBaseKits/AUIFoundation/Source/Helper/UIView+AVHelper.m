//
//  UIView+AVHelper.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/6.
//

#import "UIView+AVHelper.h"
#import <objc/runtime.h>

@interface AVTraitCollectionView ()

@property (nonatomic, copy) NSMutableArray<AVTraitCollectionDidChangedHandler> *callbackList;

@end

@implementation AVTraitCollectionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
    }
    return self;
}

- (void)addTraitCollectionDidChangedHandler:(AVTraitCollectionDidChangedHandler)handler {
    [self.callbackList addObject:handler];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            for (AVTraitCollectionDidChangedHandler handler in self.callbackList) {
                handler();
            }
        }
    }
}

- (NSMutableArray<AVTraitCollectionDidChangedHandler> *)callbackList {
    if (!_callbackList) {
        _callbackList = [NSMutableArray array];
    }
    return _callbackList;
}

@end



@implementation UIView (AVHelper)

+ (UIWindow *)av_keyWindow {
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        if ([scene isKindOfClass:scene.class]) {
            for (UIWindow *win in scene.windows) {
                if (win.isKeyWindow) {
                    keyWindow = win;
                    break;
                }
            }
        }
        
        if (!keyWindow) {
            for (UIWindow *win in UIApplication.sharedApplication.windows) {
                if (win.isKeyWindow) {
                    keyWindow = win;
                    break;
                }
            }
        }
        
    } else {
        keyWindow = UIApplication.sharedApplication.keyWindow;
    }
    return keyWindow;
}

+ (UIWindow *)av_mainWindow {
    UIWindow *mainWindow = nil;
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                windowScene = (UIWindowScene *)scene;
                break;
            }
        }
        if (windowScene && [windowScene.delegate respondsToSelector:@selector(window)]) {
            mainWindow = [(id<UIWindowSceneDelegate>)windowScene.delegate window];
        }
    }
    if (mainWindow == nil) {
        if ([UIApplication.sharedApplication.delegate respondsToSelector:@selector(window)]) {
            mainWindow = UIApplication.sharedApplication.delegate.window;
        }
    }
    
    return mainWindow;
}

+ (BOOL)av_isIphoneX {
    BOOL iPhoneX = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return iPhoneX;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = self.av_mainWindow;
        if (mainWindow && mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneX = YES;
        }
    }
    return iPhoneX;
}

+ (UIEdgeInsets)av_windowSafeArea {
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {//判断是否是手机
        return UIEdgeInsetsZero;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = self.av_mainWindow;
        return mainWindow == nil ? UIEdgeInsetsZero : mainWindow.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

+ (CGFloat)av_safeTop {
    return self.av_windowSafeArea.top;
}

+ (CGFloat)av_safeBottom {
    return self.av_windowSafeArea.bottom;
}

- (CGFloat)av_left
{
    return self.frame.origin.x;
}

- (CGFloat)av_right
{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)av_top
{
    return self.frame.origin.y;
}

- (CGFloat)av_bottom;
{
    return CGRectGetMaxY(self.frame);
}


- (CGFloat)av_width
{
    return CGRectGetWidth(self.frame);
}

- (CGFloat)av_height
{
    return CGRectGetHeight(self.frame);
}

- (CGSize) av_size {
    return self.frame.size;
}
- (void) setAv_size:(CGSize)av_size {
    CGRect frame = self.frame;
    frame.size = av_size;
    self.frame = frame;
}

- (CGSize) av_boundsSize {
    return self.bounds.size;
}
- (void) setAv_boundsSize:(CGSize)av_boundsSize {
    CGRect bounds = self.bounds;
    bounds.size =av_boundsSize;
    self.bounds = bounds;
}

- (void)setAv_left:(CGFloat)av_left {
    CGRect frame = self.frame;
    frame.origin.x = av_left;
    self.frame = frame;
}

- (void)setAv_right:(CGFloat)av_right {
    [self setAv_left:av_right - self.av_width];
}

- (void)setAv_top:(CGFloat)av_top {
    CGRect frame = self.frame;
    frame.origin.y = av_top;
    self.frame = frame;
}

- (void)setAv_bottom:(CGFloat)av_bottom {
    [self setAv_top:av_bottom - self.av_height];
}

- (CGFloat) av_centerX {
    return self.center.x;
}
- (void) setAv_centerX:(CGFloat)av_centerX {
    CGPoint center = self.center;
    center.x = av_centerX;
    self.center = center;
}

- (CGFloat) av_centerY {
    return self.center.y;
}
- (void) setAv_centerY:(CGFloat)av_centerY {
    CGPoint center = self.center;
    center.y = av_centerY;
    self.center = center;
}

- (void)setAv_width:(CGFloat)av_width
{
    CGRect frame = self.frame;
    frame.size.width = av_width;
    self.frame = frame;
}

- (void)setAv_height:(CGFloat)av_height
{
    CGRect frame = self.frame;
    frame.size.height = av_height;
    self.frame = frame;
}


static const char TraitCollectionViewKey = '\0';

- (void)setTraitCollectionView:(AVTraitCollectionView *)traitCollectionView {
    if (traitCollectionView != self.traitCollectionView) {
        [self.traitCollectionView removeFromSuperview];
        [self insertSubview:traitCollectionView atIndex:0];
        objc_setAssociatedObject(self, &TraitCollectionViewKey, traitCollectionView, OBJC_ASSOCIATION_RETAIN);
    }
}

- (AVTraitCollectionView *)traitCollectionView {
    return objc_getAssociatedObject(self, &TraitCollectionViewKey);
}

- (void)av_setLayerBorderColor:(UIColor *)color {
    if (@available(iOS 13.0, *)) {
        if (self.traitCollectionView == nil) { self.traitCollectionView = [AVTraitCollectionView new]; }
        __weak UIView *weakView = self;
        [self.traitCollectionView addTraitCollectionDidChangedHandler:^{
            weakView.layer.borderColor = [color resolvedColorWithTraitCollection:weakView.traitCollection].CGColor;
        }];
        self.layer.borderColor = [color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    } else {
        self.layer.borderColor = color.CGColor;
    }
}

- (void)av_setLayerBorderColor:(UIColor *)color borderWidth:(CGFloat)width {
    [self av_setLayerBorderColor:color];
    self.layer.borderWidth = width;
}

- (void)av_setLayerShadowColor:(UIColor *)color {
    if (@available(iOS 13.0, *)) {
        if (self.traitCollectionView == nil) { self.traitCollectionView = [AVTraitCollectionView new]; }
        __weak UIView *weakView = self;
        [self.traitCollectionView addTraitCollectionDidChangedHandler:^{
            weakView.layer.shadowColor = [color resolvedColorWithTraitCollection:weakView.traitCollection].CGColor;
        }];
        self.layer.shadowColor = [color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    } else {
        self.layer.shadowColor = color.CGColor;
    }
}

- (void)av_setLayerBackgroundColor:(UIColor *)color {
    if (@available(iOS 13.0, *)) {
        if (self.traitCollectionView == nil) { self.traitCollectionView = [AVTraitCollectionView new]; }
        __weak UIView *weakView = self;
        [self.traitCollectionView addTraitCollectionDidChangedHandler:^{
            weakView.layer.backgroundColor = [color resolvedColorWithTraitCollection:weakView.traitCollection].CGColor;
        }];
        self.layer.backgroundColor = [color resolvedColorWithTraitCollection:self.traitCollection].CGColor;
    } else {
        self.layer.backgroundColor = color.CGColor;
    }
}

+ (CGSize)av_aspectSizeWithOriginalSize:(CGSize)oriSize withResolution:(CGSize)resolution {
    if (resolution.width <= 0 || resolution.height <= 0) {
        return oriSize;
    }
    
    CGFloat w = oriSize.width;
    CGFloat h = oriSize.height;
    CGFloat fh = w * resolution.height / resolution.width;
    if (fh > h) {
        CGFloat fw = h * resolution.width / resolution.height;
        w = fw;
    }
    else {
        h = fh;
    }
    return CGSizeMake(w, h);
}

+ (CGRect)av_aspectFitRectWithFitSize:(CGSize)fitSize targetRect:(CGRect)rect {
    if (fitSize.width <= 0 || fitSize.height <= 0) {
        return CGRectZero;
    }
    
    CGFloat scale = rect.size.height / fitSize.height;
    CGSize renderSize = CGSizeMake(fitSize.width * scale, fitSize.height * scale);
    if (renderSize.width > rect.size.width) {
        scale = rect.size.width / renderSize.width;
        renderSize = CGSizeMake(renderSize.width * scale, renderSize.height * scale);
    }
    
    return CGRectMake((rect.size.width - renderSize.width) / 2.0, (rect.size.height - renderSize.height) / 2.0, renderSize.width, renderSize.height);
}

+ (CGRect)av_aspectFillRectWithFillSize:(CGSize)fillSize targetRect:(CGRect)rect {
    if (rect.size.width <= 0 || rect.size.height <= 0) {
        return CGRectZero;
    }
    
    CGFloat scale = rect.size.width / fillSize.width;
    CGSize renderSize = CGSizeMake(fillSize.width * scale, fillSize.height * scale);
    if (renderSize.height < rect.size.height) {
        scale = rect.size.width / renderSize.width;
        renderSize = CGSizeMake(renderSize.width * scale, renderSize.height * scale);
    }
    
    return CGRectMake((rect.size.width - renderSize.width) / 2.0, (rect.size.height - renderSize.height) / 2.0, renderSize.width, renderSize.height);
}

@end
