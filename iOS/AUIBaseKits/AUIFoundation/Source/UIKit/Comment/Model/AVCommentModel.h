//
//  AVCommentModel.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVCommentModel : NSObject

@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) UIEdgeInsets cellInsets;

@property (copy, nonatomic) NSString *senderID;
@property (copy, nonatomic) NSString *senderNick;
@property (copy, nonatomic) UIColor *senderNickColor;

@property (copy, nonatomic) NSString *sentContent;
@property (copy, nonatomic) UIColor *sentContentColor;
@property (assign, nonatomic) CGFloat sentContentFontSize;
@property (assign, nonatomic) UIEdgeInsets sentContentInsets;

@property (assign, nonatomic) BOOL useFlag;
@property (assign, nonatomic) BOOL isAnchor;
@property (assign, nonatomic) BOOL isMe;
@property (assign, nonatomic) CGPoint flagOriginPoint;
@property (strong, nonatomic, nullable) UIImage* anchorFlagImage;
@property (strong, nonatomic, nullable) UIImage* meFlagImage;

@property (copy, nonatomic, readonly) NSAttributedString *renderContent;


+ (UIImage *)flagImage:(NSString *)title
              fontSize:(CGFloat)fontSize
             textColor:(UIColor *)textColor
               bgColor:(UIColor *)bgColor
          cornerRadius:(CGFloat)cornerRadius
              minWidth:(CGFloat)minWidth
                height:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
