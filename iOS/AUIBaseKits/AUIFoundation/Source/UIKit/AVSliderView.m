//
//  AVSliderView.m
//  AlivcUgsvDemo
//
//  Created by mengyehao on 2022/6/1.
//

#import "AVSliderView.h"
#import "AUIFoundation.h"

@interface AVSliderView()

@property (nonatomic) UIView *contentView;
@property (nonatomic) UIView *bgLineView;
@property (nonatomic) UIView *lineView;
@property (nonatomic) UIView *actionView;
@end


@implementation AVSliderView

@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minimumValue = 0.0;
        _maximumValue = 1.0;
        _value = 0.0;
        _sensitivity = 0.0;
        _thumbTintColor = AUIFoundationColor(@"fill_infrared");
        _minimumTrackTintColor = AUIFoundationColor(@"fill_infrared");
        _maximumTrackTintColor = AUIFoundationColor(@"fill_medium");
        _disabledThumbTintColor = AUIFoundationColor(@"fill_strong");
        _disabledMinimumTrackTintColor = AUIFoundationColor(@"fill_infrared");
        _disabledMaximumTrackTintColor = AUIFoundationColor(@"fill_medium");
        
        _bgLineView = [UIView new];
        _lineView = [UIView new];
        _actionView = [UIView new];
        _actionView.layer.cornerRadius = 7.0;

        [self addSubview:self.contentView];
        [self.contentView addSubview:self.bgLineView];
        [self.contentView addSubview:self.actionView];
        [self.bgLineView addSubview:self.lineView];

        self.contentView.frame = self.bounds;
        self.bgLineView.frame = CGRectMake(0, (self.av_height - 2)/2, self.contentView.av_width, 2);
        self.lineView.frame = self.bgLineView.bounds;
        self.lineView.av_width = 0.f;
        self.actionView.frame = CGRectMake(0, (self.av_height - 14)/2, 14, 14);
        
        [self updateUIColor];
    }
    return self;
}

- (void)updateUIColor {
    if (_disabled) {
        _actionView.backgroundColor = _disabledThumbTintColor;
        _bgLineView.backgroundColor = _disabledMaximumTrackTintColor;
        _lineView.backgroundColor = _disabledMinimumTrackTintColor;
    }
    else {
        _actionView.backgroundColor = _thumbTintColor;
        _bgLineView.backgroundColor = _maximumTrackTintColor;
        _lineView.backgroundColor = _minimumTrackTintColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.bgLineView.frame = CGRectMake(0, (self.av_height - 2)/2, self.contentView.av_width, 2);
    self.lineView.frame = self.bgLineView.bounds;
    self.lineView.av_width = 0.f;
    self.actionView.frame = CGRectMake(0, (self.av_height - 14)/2, 14, 14);
    
    self.lineView.av_width = self.actionView.av_width + (self.bgLineView.av_width - self.actionView.av_width) * (self.value - _minimumValue) / (_maximumValue - _minimumValue);
    self.actionView.av_right = self.lineView.av_width;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [UIView new];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap:)];
        [_contentView addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onActionPan:)];
        [_contentView addGestureRecognizer:pan];
        [tap requireGestureRecognizerToFail:pan];
    }
    return _contentView;
}

- (void)onTap:(UITapGestureRecognizer *)tap {
    [self updateProgress:tap];
    if (self.onValueChangedByGesture) {
        self.onValueChangedByGesture(self.value, tap);
    }
}

- (float)calculateValue:(UIGestureRecognizer *)gesture {
    CGFloat moveX = [gesture locationInView:gesture.view].x;
    if (isnan(moveX)){
        return self.value;
    }
    CGFloat width = self.bgLineView.av_width - self.actionView.av_width;
    if (width <= 0) {
        moveX = 0;
    }
    else {
        moveX = (moveX  - self.actionView.av_width / 2.0) / width;
    }
    
    //保留2位小数
    moveX = round(moveX * 100) / 100.0;
    moveX = MAX(0, moveX);
    moveX = MIN(moveX, 1);
    return moveX * (self.maximumValue - self.minimumValue) + self.minimumValue;
}

- (void)onActionPan:(UIPanGestureRecognizer *)pan {
    _isChanging = (pan.state == UIGestureRecognizerStateBegan ||
                   pan.state == UIGestureRecognizerStateChanged);
    float value = [self calculateValue:pan];
    if (self.isChanging && fabs(value - self.value) < self.sensitivity) {
        return;
    }
    
    self.value = value;
    if (self.onValueChangedByGesture) {
        self.onValueChangedByGesture(self.value, pan);
    }
}

- (void)updateProgress:(UIGestureRecognizer *)gesture {
    self.value = [self calculateValue:gesture];
}

- (float)minimumValue {
    return MIN(_minimumValue, _maximumValue);
}
- (float)maximumValue {
    return MAX(_minimumValue, _maximumValue);
}

- (void)setValue:(float)value {
    value = MAX(self.minimumValue, MIN(self.maximumValue, value));
    if (value == _value) {
        return;
    }
    _value = value;
    [self setNeedsLayout];
    
    if (self.onValueChanged) {
        self.onValueChanged(self.value);
    }
}
- (void)limitValue {
    self.value = MAX(self.minimumValue, MIN(self.maximumValue, self.value));
}
- (void)setMinimumValue:(float)minimumValue {
    if (_minimumValue == minimumValue) {
        return;
    }
    _minimumValue = minimumValue;
    [self limitValue];
    [self setNeedsLayout];
}
- (void)setMaximumValue:(float)maximumValue {
    if (_maximumValue == maximumValue) {
        return;
    }
    _maximumValue = maximumValue;
    [self limitValue];
    [self setNeedsLayout];
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    _thumbTintColor = thumbTintColor;
    [self updateUIColor];
}
- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    [self updateUIColor];
}
- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    [self updateUIColor];
}
- (void)setDisabledThumbTintColor:(UIColor *)disabledThumbTintColor {
    _disabledThumbTintColor = disabledThumbTintColor;
    [self updateUIColor];
}
- (void)setDisabledMinimumTrackTintColor:(UIColor *)disabledMinimumTrackTintColor {
    _disabledMinimumTrackTintColor = disabledMinimumTrackTintColor;
    [self updateUIColor];
}
- (void)setDisabledMaximumTrackTintColor:(UIColor *)disabledMaximumTrackTintColor {
    _disabledMaximumTrackTintColor = disabledMaximumTrackTintColor;
    [self updateUIColor];
}
- (void)setDisabled:(BOOL)disabled {
    if (_disabled == disabled) {
        return;
    }
    _disabled = disabled;
    self.userInteractionEnabled = !disabled;
    [self updateUIColor];
}

@end
