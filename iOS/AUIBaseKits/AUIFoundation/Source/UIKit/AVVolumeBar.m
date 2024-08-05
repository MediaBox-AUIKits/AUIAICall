//
//  AVVolumeBar.m
//  AUIFoundation
//
//  Created by Bingo on 2024/7/18.
//

#import "AVVolumeBar.h"
#import "UIView+AVHelper.h"
#import "UIColor+AVHelper.h"

@interface AVVolumeBar ()


@property (nonatomic, strong, readonly) NSMutableArray<UIView *> *lineViews;

@end

@implementation AVVolumeBar

// 初始化时需要指定宽度&高度，不支持自适应
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22FF"];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = self.av_width / 2.0;
        
        _lineViews = [NSMutableArray array];
        CGFloat y = 3;
        while (y <= self.av_height - 3) {
            UIView *line = [self createLineView];
            line.center = CGPointMake(self.av_width / 2.0, y + line.av_height / 2.0);
            [self addSubview:line];
            [_lineViews addObject:line];
            y = line.av_bottom + 2;
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UIView *)createLineView {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
    lineView.backgroundColor = [UIColor av_colorWithHexString:@"#FCFCFDFF"];
    return lineView;
}

- (void)updateVolume:(CGFloat)volume {
    if (volume < 0) {
        volume = 0;
    }
    else if (volume > 1) {
        volume = 1;
    }
    CGFloat high = self.av_height * (1 - volume);
    [self.lineViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.av_top > high) {
            obj.backgroundColor = [UIColor av_colorWithHexString:@"#00BCD4FF"];
        }
        else {
            obj.backgroundColor = [UIColor av_colorWithHexString:@"#FCFCFDFF"];
        }
    }];
}

@end

