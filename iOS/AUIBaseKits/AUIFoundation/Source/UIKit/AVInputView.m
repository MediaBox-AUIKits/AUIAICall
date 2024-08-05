//
//  AVInputView.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVInputView.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"

@implementation AVInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lineView = [UIView new];
        _lineView.backgroundColor = AVTheme.border_weak;
        [self addSubview:_lineView];
        
        _inputTextView = [UITextField new];
        _inputTextView.backgroundColor = UIColor.clearColor;
        _inputTextView.textColor = AVTheme.text_strong;
        _inputTextView.font = [AVTheme regularFont:14];
        _inputTextView.keyboardType = UIKeyboardTypeDefault;
        _inputTextView.returnKeyType = UIReturnKeyDone;
        _inputTextView.delegate = self;
        [self addSubview:_inputTextView];
        
        _placeLabel = [UILabel new];
        _placeLabel.textColor = AVTheme.text_ultraweak;
        _placeLabel.font = [AVTheme regularFont:16];
        [self addSubview:_placeLabel];
        
        _inputCountLabel = [UILabel new];
        _inputCountLabel.textColor = AVTheme.text_ultraweak;
        _inputCountLabel.font = [AVTheme regularFont:12];
        _inputCountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_inputCountLabel];
        
        _clearButton = [UIButton new];
        [_clearButton setImage:[AVTheme getImage:@"ic_input_clear"] forState:UIControlStateNormal];
        _clearButton.imageEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [_clearButton addTarget:self action:@selector(onClearInput) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_clearButton];
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = AVTheme.text_strong;
        _titleLabel.font = [AVTheme regularFont:16];
        [self addSubview:_titleLabel];

        self.maxInputCount = 15;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.inputTextView];
        [self updateInputState];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(4.0, 0, self.av_width - 8.0, 24.0);
    CGFloat top = self.titleLabel.av_bottom + 4.0;
    CGFloat height = self.av_height - top;
    self.clearButton.frame = CGRectMake(self.av_width - 24.0 - 4.0, top + (height - 24.0) / 2.0, 24.0, 24.0);
    self.inputCountLabel.frame = CGRectMake(self.clearButton.av_left - 50.0, self.clearButton.av_top, 50, self.clearButton.av_height);
    self.inputTextView.frame = CGRectMake(4.0, top, self.inputCountLabel.av_left, height);
    self.placeLabel.frame = self.inputTextView.frame;
    self.placeLabel.av_width = self.placeLabel.av_width - 24.0;
    self.lineView.frame = CGRectMake(4.0, self.av_height - 1.0, self.av_width - 8.0, 1.0);
}

- (void)onClearInput {
    self.inputTextView.text = @"";
    [self updateInputState];
}

- (NSString *)inputText {
    return self.inputTextView.text;
}

- (void)setInputText:(NSString *)inputText {
    if (inputText.length <= self.maxInputCount) {
        self.inputTextView.text = inputText;
    }
    else {
        self.inputTextView.text = [inputText substringToIndex:self.maxInputCount];
    }
    
    [self updateInputState];
}

- (void)updateInputState {
    NSInteger count = self.inputTextView.text.length;
    self.clearButton.hidden = count == 0;
    self.placeLabel.hidden = count != 0;
    self.inputCountLabel.hidden = count == 0;
    self.inputCountLabel.text = [NSString stringWithFormat:@"%zd/%zd", count, self.maxInputCount];
    if (self.inputTextChanged) {
        self.inputTextChanged(self);
    }
}

- (void)textFieldDidChange:(NSNotification *)notify {
    if (notify.object == self.inputTextView) {
        [self updateInputState];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    
    NSString *substringToReplace = [textField.text substringWithRange:range];
    return textField.text.length - substringToReplace.length + string.length <= self.maxInputCount;
}

@end
