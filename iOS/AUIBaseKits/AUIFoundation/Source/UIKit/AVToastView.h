//
//  AVToastView.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVToastViewPosition) {
    AVToastViewPositionTop,
    AVToastViewPositionMid,
    AVToastViewPositionBottom,
};

@interface AVToastView : UIView

@property (nonatomic, strong, readonly) UILabel *toastLabel;


+ (AVToastView *)show:(NSString *)toast view:(UIView *)view position:(AVToastViewPosition)position;

@end

NS_ASSUME_NONNULL_END
