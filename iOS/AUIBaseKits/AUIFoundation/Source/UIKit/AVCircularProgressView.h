//
//  AVCircularProgressView.h
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCircularProgressView : UIView

@property(nonatomic, assign) float progress;
@property(nonatomic, assign) CGFloat lineWidth;
@property(nonatomic, assign) CAShapeLayerLineCap lineCap;
@property(nonatomic, strong, nullable) UIColor* progressTintColor;
@property(nonatomic, strong, nullable) UIColor* trackTintColor;
@property(nonatomic, assign) NSTimeInterval animationFullDuration;
- (void)setProgress:(float)progress animated:(BOOL)animated;

+ (AVCircularProgressView *)presentOnView:(UIView *)onView message:(NSString *)message;
+ (void)dismiss:(AVCircularProgressView *)progressView;

@end

NS_ASSUME_NONNULL_END
