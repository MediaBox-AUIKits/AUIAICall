//
//  AVProgressHUD.m
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/16.
//

#import "AVProgressHUD.h"
#import "AUIFoundationMacro.h"
#import "UIColor+AVHelper.h"
#import "UIView+AVHelper.h"

@interface AVProgressHUD ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL finished;
@end

@implementation AVProgressHUD

+ (AVProgressHUD *)ShowHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    AVProgressHUD *hud = [AVProgressHUD new];
    [view addSubview:hud];
    [hud showAnimated:animated];
    return hud;
}

+ (AVProgressHUD *)ShowMessage:(NSString *)message inView:(UIView *)view {
    AVProgressHUD *hud = [AVProgressHUD new];
    hud.iconType = AVProgressHUDIconTypeNone;
    hud.labelText = message;
    [view addSubview:hud];
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:2.0];
    return hud;
}

+ (BOOL)HideHUDForView:(UIView *)view animated:(BOOL)animated {
    AVProgressHUD *hud = [self HUDForView:view];
    if (!hud) {
        return NO;
    }
    [hud hideAnimated:animated];
    return YES;
}

+ (AVProgressHUD *)HUDForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            AVProgressHUD *hud = (AVProgressHUD *)subview;
            if (!hud.finished) {
                return hud;
            }
        }
    }
    return nil;
}

- (void)showAnimated:(BOOL)animated {
    [self setNeedsLayout];
    [self.superview bringSubviewToFront:self];
    if (self.finished) {
        return;
    }
    
    if (!animated) {
        self.alpha = 1.0;
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hideAnimated:(BOOL)animated {
    [self hideAnimated:animated afterDelay:0];
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    if (self.finished) {
        return;
    }
    self.finished = YES;
    
    NSTimeInterval animDur = animated ? 0.00001 : 0.2;
    [UIView animateWithDuration:animDur delay:delay options:0 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setPosition:(AVProgressHUDShowPos)position {
    _position = position;
    [self setNeedsLayout];
}

- (void)setup {
    // clear
    [_label removeFromSuperview];
    [_iconView removeFromSuperview];
    [_activityView removeFromSuperview];

    // create
    _label = [UILabel new];
    _label.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
    _label.font = AVGetRegularFont(18.0);
    _label.numberOfLines = 0;
    [self addSubview:_label];
    _label.textAlignment = NSTextAlignmentCenter;
    
    _iconView = [UIImageView new];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconView];
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhiteLarge;
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    [self addSubview:_activityView];
    [_activityView startAnimating];

    // update
    self.layer.cornerRadius = 8.0;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.8];
    
    _label.text = _labelText;
    self.position = AVProgressHUDShowPosMid;
    self.iconType = AVProgressHUDIconTypeLoading;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.superview) {
        return;
    }
    
    const CGFloat kMinWidth = 112.0;
    const CGFloat kMaxWidth = 198.0;
    const CGFloat kLabelMargin = 12.0;
    const CGFloat kIconMargin = 12.0;
    const CGFloat kIconSize = 48.0;
    
    BOOL hasIcon = (_iconType != AVProgressHUDIconTypeNone);
    BOOL hasLabel = (_labelText.length > 0);
    
    CGSize size = CGSizeMake(0, 0);
    if (hasIcon) {
        size.width = kIconSize + kIconMargin * 2;
        size.height = kIconSize + kIconMargin * 2;
    }
    CGSize labelSize = CGSizeZero;
    if (hasLabel) {
        labelSize = [self.label sizeThatFits:CGSizeMake(kMaxWidth - kLabelMargin * 2, 0)];
        size.width = MAX(size.width, labelSize.width + kLabelMargin * 2);
        size.height = MAX(size.height, labelSize.height + kLabelMargin * 2);
    }
    
    size.width = MIN(MAX(size.width, kMinWidth), kMaxWidth);
    size.height = MAX(size.height, kMinWidth);
    
    if (hasIcon && hasLabel) {
        size.height = MAX(size.height, kIconMargin + kIconSize + MIN(kIconMargin, kLabelMargin) + labelSize.height + kLabelMargin);
    }
    
    CGRect iconFrame = CGRectMake(0, 0, kIconSize, kIconSize);
    iconFrame.origin.x = (size.width - kIconSize) * 0.5;
    iconFrame.origin.y = hasLabel ? kIconMargin : (size.height - kIconSize) * 0.5;
    _iconView.frame = iconFrame;
    _activityView.frame = iconFrame;
    
    CGRect labelFrame = CGRectZero;
    labelFrame.origin.x = (size.width - labelSize.width) * 0.5;
    labelFrame.origin.y = (size.height - labelSize.height - kLabelMargin);
    labelFrame.size = labelSize;
    _label.frame = labelFrame;
    
    
    CGSize superSize = self.superview.bounds.size;
    CGRect frame = CGRectZero;
    frame.size = size;
    frame.origin.x = (superSize.width - size.width) * 0.5;
    switch (_position) {
        case AVProgressHUDShowPosTop:
            frame.origin.y = superSize.height / 3.0 - size.height * 0.5;
            break;
        case AVProgressHUDShowPosMid:
            frame.origin.y = superSize.height * 0.5 - size.height * 0.5;
            break;
        case AVProgressHUDShowPosBottom:
            frame.origin.y = superSize.height * 2.0 / 3.0 - size.height * 0.5;
            break;
    }
    self.frame = frame;
}


- (void)setLabelText:(NSString *)labelText {
    _labelText = labelText;
    _label.text = labelText;
    [self setNeedsLayout];
}

- (void)setIconType:(AVProgressHUDIconType)iconType {
    _iconType = iconType;
    switch (iconType) {
        case AVProgressHUDIconTypeWarn:
            _iconView.image = AUIFoundationCommonImage(@"ic_warn");
            break;
        case AVProgressHUDIconTypeSuccess:
            _iconView.image = AUIFoundationCommonImage(@"ic_right");
            break;
        default:
            _iconView.image = nil;
    }
    [self setNeedsLayout];
    _activityView.hidden = (iconType != AVProgressHUDIconTypeLoading);
    _iconView.hidden = (iconType != AVProgressHUDIconTypeWarn && iconType != AVProgressHUDIconTypeSuccess);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    return self;
}

@end
