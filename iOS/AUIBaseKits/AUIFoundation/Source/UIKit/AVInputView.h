//
//  AVInputView.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVInputView : UIView<UITextFieldDelegate>

@property (nonatomic, strong, readonly) UIView *lineView;
@property (nonatomic, strong, readonly) UITextField *inputTextView;
@property (nonatomic, strong, readonly) UILabel *placeLabel;
@property (nonatomic, strong, readonly) UILabel *inputCountLabel;
@property (nonatomic, strong, readonly) UIButton *clearButton;
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, assign) NSInteger maxInputCount;

@property (nonatomic, copy) void(^inputTextChanged)(AVInputView *inputView);
@property (nonatomic, copy, nullable) NSString *inputText;


@end

NS_ASSUME_NONNULL_END
