//
//  AVCommentTextField.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVCommentTextField.h"
#import "AUIFoundationMacro.h"
#import "UIColor+AVHelper.h"

@interface AVCommentTextField () <UITextFieldDelegate>

@property (copy, nonatomic) NSString *inputText;
@property (nonatomic, assign) BOOL isKeyBoardShow;

@end

@implementation AVCommentTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColorForNormal = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        self.textColorForNormal = [UIColor av_colorWithHexString:@"#B2B7C4"];
        self.backgroundColorForEdit = AUIFoundationColor(@"fill_weak");
        self.textColorForEdit = AUIFoundationColor(@"text_strong");
        self.placeHolderColorForNormal = [UIColor av_colorWithHexString:@"#B2B7C4"];
        self.placeHolderColorForDisable = [UIColor av_colorWithHexString:@"#B2B7C4"];
        
        self.textAlignment = NSTextAlignmentLeft;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeySend;
        self.delegate = self;
        [self refreshCommentPlaceHolder];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [self refreshDisplayColor];
    }
    return self;
}

- (void)refreshDisplayColor {
    if (self.isKeyBoardShow) {
        self.textColor = self.textColorForEdit;
        self.backgroundColor = self.backgroundColorForEdit;
    }
    else {
        self.textColor = self.textColorForNormal;
        self.backgroundColor = self.backgroundColorForNormal;
    }
}

- (void)setCommentState:(AVCommentState)commentState {
    if (_commentState == commentState) {
        return;
    }
    
    _commentState = commentState;
    if (_commentState == AVCommentStateMute) {
        self.inputText = self.text;
        self.text = nil;
    }
    else {
        self.text = self.inputText;
        self.inputText = nil;
    }
    
    if (self.isFirstResponder) {
        [self resignFirstResponder];
    }
    else {
        [self refreshCommentPlaceHolder];
    }
}

- (void)refreshCommentPlaceHolder {
    if (self.commentState == AVCommentStateMute) {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:AUIFoundationLocalizedString(@"Muted")
                                                                     attributes:@{
                                  NSForegroundColorAttributeName:self.placeHolderColorForDisable,
                                  NSFontAttributeName:AVGetRegularFont(12)
                              }];
        self.enabled = NO;
    }
    else {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:AUIFoundationLocalizedString(@"Say something~")
                                                                     attributes:@{
                                  NSForegroundColorAttributeName:self.placeHolderColorForNormal,
                                  NSFontAttributeName:AVGetRegularFont(12)
                              }];
        self.enabled = YES;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 16, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 16, 0);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITextPosition *end = [textField endOfDocument];
        [self setSelectedTextRange:[self textRangeFromPosition:end toPosition:end]];
    });
}

#pragma mark - Notification

- (void)keyBoardWillShow:(NSNotification *)notification {
    if (!self.isFirstResponder) {
        return;
    }
    
    self.isKeyBoardShow = YES;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [self refreshDisplayColor];
    self.attributedPlaceholder = nil;

    if (self.willEditBlock) {
        self.willEditBlock(self, keyboardEndFrame);
    }
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    if (self.isKeyBoardShow) {
        self.isKeyBoardShow = NO;

        [self refreshDisplayColor];
        [self refreshCommentPlaceHolder];
        
        if (self.endEditBlock) {
            self.endEditBlock(self);
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resignFirstResponder];
    if (self.text.length > 0) {
        if (self.sendCommentBlock) {
            self.sendCommentBlock(self, self.text);
        }
    }
    self.text = nil;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
     return YES;
}

@end
