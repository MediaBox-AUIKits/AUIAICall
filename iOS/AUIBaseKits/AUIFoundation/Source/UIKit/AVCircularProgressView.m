//
//  AVCircularProgressView.m
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/9.
//

#import "AVCircularProgressView.h"
#import "UIView+AVHelper.h""
#import "AUIFoundationMacro.h"

@interface AVCircularProgressView()<CAAnimationDelegate>
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@end

@implementation AVCircularProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // clear
    [_trackLayer removeFromSuperlayer];
    [_progressLayer removeFromSuperlayer];
    
    // create
    if (!_trackTintColor) {
        _trackTintColor = AUIFoundationColor(@"fill_ultraweak");
    }
    if (!_progressTintColor) {
        _progressTintColor = AUIFoundationColor(@"colourful_fill_strong");
    }
    
    _lineCap = kCALineCapRound;
    
    _trackLayer = [CAShapeLayer layer];
    _trackLayer.fillColor = UIColor.clearColor.CGColor;
    _trackLayer.strokeColor = _trackTintColor.CGColor;
    _trackLayer.backgroundColor = UIColor.clearColor.CGColor;
    [self.layer addSublayer:_trackLayer];
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.fillColor = UIColor.clearColor.CGColor;
    _progressLayer.strokeColor = _progressTintColor.CGColor;
    _progressLayer.backgroundColor = UIColor.clearColor.CGColor;
    _progressLayer.lineCap = _lineCap;
    [self.layer addSublayer:_progressLayer];

    // update
    _animationFullDuration = 1.0;
    self.userInteractionEnabled = NO;
    [self updateUI];
}

- (void)setLineCap:(CAShapeLayerLineCap)lineCap {
    _progressLayer.lineCap = lineCap;
}

static void s_updatePath(CAShapeLayer *layer, CGFloat radius, CGFloat beginAngle, CGFloat endAngle) {
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint center = CGPointMake(radius, radius);
    [path addArcWithCenter:center
                    radius:radius - layer.lineWidth * 0.5
                startAngle:beginAngle
                  endAngle:endAngle
                 clockwise:YES];
    layer.path = path.CGPath;
}

- (void)updateProgress {
    const CGFloat radius = self.bounds.size.width * 0.5;
    CGFloat angle = _progress * M_PI * 2 - M_PI_2;
    s_updatePath(_progressLayer, radius, -M_PI_2, angle);
}

- (CGFloat)progressWidth {
    if (_lineWidth > 0.0) {
        return _lineWidth;
    }
    const CGFloat radius = self.bounds.size.width * 0.5;
    return radius * 0.2;
}

- (void)updateUI {
    const CGFloat radius = self.bounds.size.width * 0.5;
    if (radius < 1) {
        return;
    }

    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    
    const CGFloat width = self.progressWidth;
    _trackLayer.lineWidth = width;
    _progressLayer.lineWidth = width;
    
    s_updatePath(_trackLayer, radius, 0, M_PI * 2);
    [self updateProgress];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateUI];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    _trackLayer.strokeColor = trackTintColor.CGColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    _progressLayer.strokeColor = progressTintColor.CGColor;
}

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (CABasicAnimation *) strokeAnimationWithFrom:(float)from to:(float)to {
    NSTimeInterval duration = MAX(0.5, _animationFullDuration);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    anim.delegate = self;
    anim.fillMode = kCAFillModeForwards;
    anim.removedOnCompletion = NO;
    anim.duration = fabs(from - to) * duration;
    if (from > to) {
        anim.fromValue = @1.0;
        anim.toValue = @(to/from);
    }
    else {
        anim.fromValue = @(from/to);
        anim.toValue = @1.0;
    }
    return anim;
}

#define kAnimationKey @"ProgressAnimation"
- (void)setProgress:(float)progress animated:(BOOL)animated {
    progress = MAX(0.0, MIN(1.0, progress));
    if (fabs(progress - _progress) <= 0.0001) {
        return;
    }
    
    [_progressLayer removeAnimationForKey:kAnimationKey];

    float lastProgress = _progress;
    _progress = progress;
    if (!animated || progress > lastProgress) {
        [self updateProgress];
    }
    if (animated) {
        [_progressLayer addAnimation:[self strokeAnimationWithFrom:lastProgress to:progress]
                              forKey:kAnimationKey];
    }
}

// MARK: - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        [self updateProgress];
        [_progressLayer removeAnimationForKey:kAnimationKey];
    }
}


+ (AVCircularProgressView *)presentOnView:(UIView *)onView message:(NSString *)message {
    
    UIView *bgView = [[UIView alloc] initWithFrame:onView.bounds];
    bgView.backgroundColor = AUIFoundationColor(@"tsp_fill_medium");
    [onView addSubview:bgView];
    
    AVCircularProgressView *progressView = [[AVCircularProgressView alloc] initWithFrame:CGRectMake((bgView.av_width - 64) / 2.0, (bgView.av_height - 64) / 2.0, 64, 64)];
    progressView.progress = 0.0;
    [bgView addSubview:progressView];
    
    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, progressView.av_bottom + 12, bgView.av_width, 20)];
    textView.text = message;
    textView.textColor = AUIFoundationColor(@"text_strong");
    textView.font = AVGetMediumFont(16);
    textView.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:textView];
    
    return progressView;
}

+ (void)dismiss:(AVCircularProgressView *)progressView {
    [progressView.superview removeFromSuperview];
}


@end
