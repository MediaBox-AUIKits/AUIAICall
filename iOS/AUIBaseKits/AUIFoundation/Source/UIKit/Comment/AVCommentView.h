//
//  AVCommentView.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>
#import "AVCommentModel.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVCommentViewMode) {
    AVCommentViewModeBottom,
    AVCommentViewModeTop,
};

@interface AVCommentView : UIView

@property (nonatomic, copy, readonly) NSArray<AVCommentModel *> *commentList;
@property (nonatomic, strong) UIColor *commentBackgroundColor;
@property (nonatomic, strong, readonly) UIButton *showNewCommentTipsButton;


- (instancetype)initWithFrame:(CGRect)frame mode:(AVCommentViewMode)mode  needShowNewCommentTips:(BOOL)needShowNewCommentTips;

/**
 * 插入普通直播弹幕
 * @param comment 弹幕model
 */
- (void)insertLiveComment:(AVCommentModel *)comment;

/**
 * 插入普通直播弹幕
 * @param content 弹幕内容
 * @param nick 弹幕发送者昵称
 */
- (void)insertLiveComment:(NSString *)content
         commentSenderNick:(NSString *)nick
           commentSenderID:(NSString *)userID;


@end

NS_ASSUME_NONNULL_END
