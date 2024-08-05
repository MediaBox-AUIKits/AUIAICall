//
//  AVCommentTableView.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>
#import "AVCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AVCommentTableViewDelegate <NSObject>

- (void)onCommentDidScrolled;
- (void)onCommentCellLongPressed:(AVCommentModel *)commentModel;
- (void)onCommentCellTapped:(AVCommentModel *)commentModel;

@end

@interface AVCommentTableView : UITableView

@property (nonatomic, weak) id<AVCommentTableViewDelegate> commentDelegate;

@property (nonatomic, copy, readonly) NSArray<AVCommentModel *> *commentList;
@property (nonatomic, strong) UIColor *commentBackgroundColor;

- (void)insertNewComment:(AVCommentModel*)comment;

- (void)scrollToLastComment;

- (BOOL)presentingOnLastComment;

@end

NS_ASSUME_NONNULL_END
