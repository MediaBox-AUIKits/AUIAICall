//
//  AVVideoPlayProgressView.m
//  AUIFoundation
//
//  Created by Bingo on 2023/9/15.
//

#import "AVVideoPlayProgressView.h"
#import "UIView+AVHelper.h"
#import "AVTheme.h"

@interface AVVideoPlayProgressView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *fgView;
@property (nonatomic, strong) UIView *sliderView;

@property (nonatomic, assign) AVVideoPlayProgressViewStyle innerViewStyle;
@property (nonatomic, assign) BOOL isPaning;

@end

@implementation AVVideoPlayProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [UIView new];
        _bgView.backgroundColor = AVTheme.fill_medium;
        [self addSubview:_bgView];
        
        _fgView = [UIView new];
        [self addSubview:_fgView];
        
        _sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        _sliderView.layer.cornerRadius = 3;
        [self addSubview:_sliderView];
        
        self.isPaning = NO;
        self.viewStyle = AVVideoPlayProgressViewStyleNormal;
        self.progress = 0.0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onActionTap:)];
        [self addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onActionPan:)];
        [self addGestureRecognizer:pan];
        [tap requireGestureRecognizerToFail:pan];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.frame = CGRectMake(0, (self.av_height - 2) / 2.0, self.av_width, 2);
    
    self.progress = _progress;
}

- (void)setProgress:(CGFloat)progress {
    if (progress < 0) {
        progress = 0.0;
    }
    else if (progress > 1) {
        progress = 1.0;
    }
    
    _progress = progress;
    if (self.onProgressChanged) {
        self.onProgressChanged(_progress);
    }
    
    if (!self.isPaning) {
        [self refreshProgressUI];
    }
}

- (void)setViewStyle:(AVVideoPlayProgressViewStyle)viewStyle {
    _viewStyle = viewStyle;
    if (!self.isPaning) {
        self.innerViewStyle = viewStyle;
    }
}

- (void)setInnerViewStyle:(AVVideoPlayProgressViewStyle)innerViewStyle {
    _innerViewStyle = innerViewStyle;
    UIColor *bgc = AVTheme.fill_infrared;
    self.fgView.backgroundColor = _innerViewStyle == AVVideoPlayProgressViewStyleNormal ? [bgc colorWithAlphaComponent:0.4] : bgc;
    self.sliderView.hidden = _innerViewStyle == AVVideoPlayProgressViewStyleNormal;
    self.sliderView.backgroundColor = bgc;
}

- (void)onActionTap:(UITapGestureRecognizer *)tap {
    [self updateProgress:tap];
}

- (void)onActionPan:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.isPaning = YES;
        self.innerViewStyle = AVVideoPlayProgressViewStyleHighlight;
        [self updateProgress:recognizer];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self updateProgress:recognizer];
    }
    else {
        self.isPaning = NO;
        self.viewStyle = _viewStyle;
        [self updateProgress:recognizer];
    }
}

- (void)updateProgress:(UIGestureRecognizer *)gesture {
    CGFloat pos = [gesture locationInView:gesture.view].x;
    if (isnan(pos)){
        return;
    }
    self.progress = pos / self.av_width;
    [self refreshProgressUI];
    if (self.onProgressChangedByGesture) {
        self.onProgressChangedByGesture(self.progress);
    }
}

- (void)refreshProgressUI {
    self.fgView.frame = CGRectMake(0, (self.av_height - 2) / 2.0, self.av_width * _progress, 2);
    self.sliderView.center = CGPointMake(self.fgView.av_right, self.fgView.av_centerY);
}

@end
