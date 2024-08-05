//
//  AVSliderView.h
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVSliderView : UIView
@property (nonatomic) float value; // default 0.0. this value will be pinned to min/max
@property (nonatomic) float maximumValue; // default 0.0. the current value may change if outside new min value
@property (nonatomic) float minimumValue; // default 1.0. the current value may change if outside new max value

@property (nonatomic, strong) UIColor *thumbTintColor;
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nonatomic, strong) UIColor *maximumTrackTintColor;

@property (nonatomic) BOOL disabled;
@property (nonatomic, strong) UIColor *disabledThumbTintColor;
@property (nonatomic, strong) UIColor *disabledMinimumTrackTintColor;
@property (nonatomic, strong) UIColor *disabledMaximumTrackTintColor;

@property (nonatomic, readonly) BOOL isChanging;
@property (nonatomic, assign) float sensitivity;
@property (nonatomic, copy) void(^onValueChanged)(float value);
@property (nonatomic, copy) void(^onValueChangedByGesture)(float value, UIGestureRecognizer *gesture);

@end

NS_ASSUME_NONNULL_END
