//
//  AVSwitchBar.h
//  AUIFoundation
//
//  Created by Bingo on 2024/7/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVSwitchBar : UIView

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *infoLabel;
@property (nonatomic, strong, readonly) UISwitch *switchBtn;
@property (nonatomic, strong, readonly) UIView *lineView;

@property (nonatomic, copy) void (^onSwitchValueChanged)(AVSwitchBar *bar);

@end

NS_ASSUME_NONNULL_END
