//
//  AVNetworkStatusView.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AVNetworkStatus)
{
    AVNetworkStatusFluent = 0,  // 网络良好
    AVNetworkStatusStuttering,  // 网络不佳
    AVNetworkStatusBrokenOff, // 网络异常
};

@interface AVNetworkStatusView : UIView

@property (assign, nonatomic) AVNetworkStatus status;

@property (strong, nonatomic, readonly) UIView *flagView;
@property (strong, nonatomic, readonly) UILabel *statusLabel;

@end

NS_ASSUME_NONNULL_END
