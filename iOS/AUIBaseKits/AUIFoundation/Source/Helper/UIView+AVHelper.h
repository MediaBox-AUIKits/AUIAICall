//
//  UIView+AVHelper.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^AVTraitCollectionDidChangedHandler)(void);

@interface AVTraitCollectionView : UIView

- (void)addTraitCollectionDidChangedHandler:(AVTraitCollectionDidChangedHandler)handler;

@end

@interface UIView (AVHelper)

@property (nonatomic, class, readonly, nullable) UIWindow *av_keyWindow;  //
@property (nonatomic, class, readonly, nullable) UIWindow *av_mainWindow;
@property (nonatomic, assign, class, readonly) BOOL av_isIphoneX;  // 是否为刘海屏
@property (nonatomic, assign, class, readonly) UIEdgeInsets av_windowSafeArea;  // 窗口安全区域
@property (nonatomic, assign, class, readonly) CGFloat av_safeTop;
@property (nonatomic, assign, class, readonly) CGFloat av_safeBottom;


@property (nonatomic, assign) CGFloat av_top;
@property (nonatomic, assign) CGFloat av_bottom;
@property (nonatomic, assign) CGFloat av_left;
@property (nonatomic, assign) CGFloat av_right;
@property (nonatomic, assign) CGFloat av_width;
@property (nonatomic, assign) CGFloat av_height;
@property (nonatomic, assign) CGSize av_size;
@property (nonatomic, assign) CGSize av_boundsSize;
@property (nonatomic, assign) CGFloat av_centerX;
@property (nonatomic, assign) CGFloat av_centerY;


- (void)av_setLayerBorderColor:(UIColor *)color;
- (void)av_setLayerBorderColor:(UIColor *)color borderWidth:(CGFloat)width;
- (void)av_setLayerShadowColor:(UIColor *)color;
- (void)av_setLayerBackgroundColor:(UIColor *)color;

+ (CGSize)av_aspectSizeWithOriginalSize:(CGSize)oriSize withResolution:(CGSize)resolution;

+ (CGRect)av_aspectFitRectWithFitSize:(CGSize)fitSize targetRect:(CGRect)rect;
+ (CGRect)av_aspectFillRectWithFillSize:(CGSize)oriSize targetRect:(CGRect)rect;

@end

#define AVSafeTop UIView.av_safeTop
#define AVSafeBottom UIView.av_safeBottom

NS_ASSUME_NONNULL_END
