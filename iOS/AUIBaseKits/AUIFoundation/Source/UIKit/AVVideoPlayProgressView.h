//
//  AVVideoPlayProgressView.h
//  AUIFoundation
//
//  Created by Bingo on 2023/9/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVVideoPlayProgressViewStyle) {
    AVVideoPlayProgressViewStyleNormal,
    AVVideoPlayProgressViewStyleHighlight,
};

@interface AVVideoPlayProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) AVVideoPlayProgressViewStyle viewStyle;

@property (nonatomic, copy) void(^onProgressChanged)(float value);
@property (nonatomic, copy) void(^onProgressChangedByGesture)(float value);
@end

NS_ASSUME_NONNULL_END
