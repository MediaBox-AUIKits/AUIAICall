//
//  AVBlockButton.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVBlockButton : UIButton

@property (nonatomic, copy) void(^clickBlock)(AVBlockButton *sender);
@property (nonatomic, copy) void(^touchDownBlock)(AVBlockButton *sender);
@property (nonatomic, copy) void(^touchDragEnterBlock)(AVBlockButton *sender);
@property (nonatomic, copy) void(^touchDragExitBlock)(AVBlockButton *sender);
@property (nonatomic, copy) void(^touchUpInsideBlock)(AVBlockButton *sender);
@property (nonatomic, copy) void(^touchUpOutsideBlock)(AVBlockButton *sender);

- (void)setBorderColor:(nullable UIColor *)color forState:(UIControlState)state;
- (void)setBackgroundColor:(nullable UIColor *)color forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
