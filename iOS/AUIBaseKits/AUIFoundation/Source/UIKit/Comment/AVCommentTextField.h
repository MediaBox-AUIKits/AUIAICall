//
//  AVCommentTextField.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVCommentState) {
    AVCommentStateDefault,
    AVCommentStateMute,
};

@interface AVCommentTextField : UITextField

@property (assign, nonatomic) AVCommentState commentState;

@property (copy, nonatomic) void (^sendCommentBlock)(AVCommentTextField *sender, NSString *comment);

@property (copy, nonatomic) void (^willEditBlock)(AVCommentTextField *sender, CGRect keyboardFrame);
@property (copy, nonatomic) void (^endEditBlock)(AVCommentTextField *sender);

@property(strong, nonatomic) UIColor *backgroundColorForNormal;
@property(strong, nonatomic) UIColor *backgroundColorForEdit;
@property(strong, nonatomic) UIColor *textColorForNormal;
@property(strong, nonatomic) UIColor *textColorForEdit;
@property(strong, nonatomic) UIColor *placeHolderColorForNormal;
@property(strong, nonatomic) UIColor *placeHolderColorForDisable;

- (void)refreshCommentPlaceHolder;
- (void)refreshDisplayColor;

@end

NS_ASSUME_NONNULL_END
