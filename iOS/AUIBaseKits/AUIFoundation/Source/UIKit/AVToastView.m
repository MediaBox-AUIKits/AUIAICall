//
//  AVToastView.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import "AVToastView.h"
#import "AVLocalization.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"
#import "UIColor+AVHelper.h"

@interface AVToastView ()

@property (nonatomic, strong) UILabel *toastLabel;

@end

@implementation AVToastView

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)show:(NSString *)toast view:(UIView *)view position:(AVToastViewPosition)position {
    if (!view) {
        return;
    }
    
    self.layer.cornerRadius = 8.0;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.8];
    
    self.toastLabel = [[UILabel alloc] init];
    self.toastLabel.font = AVGetRegularFont(14.0);
    self.toastLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
    self.toastLabel.numberOfLines = 0;
    self.toastLabel.text = toast;
    [self addSubview:self.toastLabel];
    
    CGSize best = [self.toastLabel sizeThatFits:CGSizeMake(view.av_width - 20 * 2 - 14 * 2, 0)];
    self.toastLabel.frame = CGRectMake(14, 12, best.width, best.height);
    self.frame = CGRectMake(0, 0, self.toastLabel.av_width + 14 * 2, self.toastLabel.av_height + 12 * 2);
    if (position == AVToastViewPositionTop) {
        self.center = CGPointMake(view.av_width / 2.0, view.av_height / 4.0);
    }
    else if (position == AVToastViewPositionBottom) {
        self.center = CGPointMake(view.av_width / 2.0, view.av_height * 3 / 4.0);
    }
    else {
        self.center = CGPointMake(view.av_width / 2.0, view.av_height / 2.0);
    }
    [view addSubview:self];
}

+ (AVToastView *)show:(NSString *)toast view:(UIView *)view position:(AVToastViewPosition)position {
    AVToastView *toastView = [[AVToastView alloc] init];
    [toastView show:toast view:view position:position];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [toastView removeFromSuperview];
    });
    return toastView;
}

@end
