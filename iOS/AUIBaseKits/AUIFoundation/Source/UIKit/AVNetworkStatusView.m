//
//  AVNetworkStatusView.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/20.
//

#import "AVNetworkStatusView.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"
#import "UIColor+AVHelper.h"
#import <Masonry/Masonry.h>

@interface AVNetworkStatusView ()

@property (strong, nonatomic) UIView *flagView;
@property (strong, nonatomic) UILabel *statusLabel;

@end

@implementation AVNetworkStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *flagView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:flagView];
        [flagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.width.height.mas_equalTo(4);
            make.centerY.equalTo(self);
        }];
        self.flagView = flagView;
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        statusLabel.font = AVGetRegularFont(10);
        statusLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        [self addSubview:statusLabel];
        [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.flagView.mas_right).offset(4);
            make.top.bottom.right.equalTo(self);
        }];
        self.statusLabel = statusLabel;
        
        self.status = AVNetworkStatusFluent;
    }
    return self;
}

- (void)setStatus:(AVNetworkStatus)status {
    _status = status;
    if (_status == AVNetworkStatusFluent) {
        self.statusLabel.text = AUIFoundationLocalizedString(@"Network is good");
        self.flagView.backgroundColor = [UIColor av_colorWithHexString:@"#3BB346" alpha:1.0];
    }
    else if (_status == AVNetworkStatusStuttering) {
        self.statusLabel.text = AUIFoundationLocalizedString(@"Network is poor");
        self.flagView.backgroundColor = [UIColor av_colorWithHexString:@"#FFC422" alpha:1.0];
    }
    else if (_status == AVNetworkStatusBrokenOff) {
        self.statusLabel.text = AUIFoundationLocalizedString(@"Network error");
        self.flagView.backgroundColor = [UIColor av_colorWithHexString:@"#F53F3F" alpha:1.0];
    }
}


@end
