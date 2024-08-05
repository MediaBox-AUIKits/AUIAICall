//
//  AVSwitchBar.m
//  AUIFoundation
//
//  Created by Bingo on 2024/7/8.
//

#import "AVSwitchBar.h"
#import "AVTheme.h"
#import "UIView+AVHelper.h"

@interface AVSwitchBar ()

@end

@implementation AVSwitchBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = AVTheme.text_strong;
        _titleLabel.font = [AVTheme regularFont:14];
        [self addSubview:_titleLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = AVTheme.text_ultraweak;
        _infoLabel.font = [AVTheme regularFont:10];
        [self addSubview:_infoLabel];
        
        _switchBtn = [UISwitch new];
        _switchBtn.onTintColor = AVTheme.colourful_fg_strong;
        _switchBtn.tintColor = AVTheme.fill_weak;
        [self addSubview:_switchBtn];
        
        _lineView = [UIView new];
        _lineView.backgroundColor = AVTheme.border_weak;
        [self addSubview:_lineView];
        
        [_switchBtn addTarget:self action:@selector(onSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.switchBtn.center = CGPointMake(self.av_width - self.switchBtn.av_width / 2.0 - 20, self.av_height / 2.0);
    
    CGFloat h = 22 + 16 + 4;
    if (self.infoLabel.hidden == YES) {
        h = 22;
    }
    self.titleLabel.frame = CGRectMake(20, (self.av_height - h) / 2.0, self.switchBtn.av_left - 16 - 20, 22);
    self.infoLabel.frame = CGRectMake(self.titleLabel.av_left, self.titleLabel.av_bottom + 4, self.titleLabel.av_width, 16);
    self.lineView.frame = CGRectMake(self.titleLabel.av_left, self.av_height - 1, self.titleLabel.av_width, 1);
}

- (void)onSwitchValueChanged:(UISwitch *)sender {
    if (self.onSwitchValueChanged) {
        self.onSwitchValueChanged(self);
    }
}

@end

