//
//  AVActivityIndicator.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import "AVActivityIndicator.h"
#import "AVLocalization.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"

@interface AVActivityIndicator ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation AVActivityIndicator

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)start:(UIView *)view displaySize:(CGSize)displaySize displayColor:(UIColor *)displayColor indicatorColor:(UIColor *)indicatorColor {
    
    if (!view) {
        return;
    }
    
    self.frame = view.bounds;
    [view addSubview:self];
    
    UIActivityIndicatorViewStyle style = UIActivityIndicatorViewStyleWhiteLarge;
    if (@available(iOS 13.0, *)) {
        style = UIActivityIndicatorViewStyleLarge;
    }
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    
    if (CGSizeEqualToSize(displaySize, CGSizeZero)) {
        self.activityIndicator.frame = self.bounds;
    }
    else {
        self.activityIndicator.frame = CGRectMake((self.av_width - displaySize.width) / 2.0, (self.av_height -displaySize.height) / 2.0, displaySize.width, displaySize.height);
    }
    self.activityIndicator.layer.cornerRadius = 8.0;
    self.activityIndicator.layer.masksToBounds = YES;
    [self.activityIndicator av_setLayerBorderColor:AUIFoundationColor(@"border_weak") borderWidth:1.0];
    self.activityIndicator.color = indicatorColor;
    self.activityIndicator.backgroundColor = displayColor;
    [self.activityIndicator startAnimating];
    
    [self addSubview:self.activityIndicator];
}

- (void)stop {
    [self.activityIndicator stopAnimating];
    [self removeFromSuperview];
}

+ (AVActivityIndicator *)start:(UIView *)view displaySize:(CGSize)displaySize displayColor:(UIColor *)displayColor indicatorColor:(UIColor *)indicatorColor {
    AVActivityIndicator *object = [AVActivityIndicator new];
    [object start:view displaySize:displaySize displayColor:displayColor indicatorColor:indicatorColor];
    return object;
}

+ (AVActivityIndicator *)start:(UIView *)view {
    return [self start:view displaySize:CGSizeMake(200, 100) displayColor:AUIFoundationColor2(@"bg_weak", 0.8) indicatorColor:AUIFoundationColor(@"text_strong")];
}

+ (void)stop:(AVActivityIndicator *)activityIndicator {
    [activityIndicator stop];
}

@end
