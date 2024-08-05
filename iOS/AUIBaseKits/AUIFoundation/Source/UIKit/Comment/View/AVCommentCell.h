//
//  AVCommentCell.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>
#import "AVCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AVCommentCellDelegate <NSObject>

- (void)onCommentCellLongPressGesture:(UILongPressGestureRecognizer*)recognizer
                              commentModel:(AVCommentModel*)commentModel;

- (void)onCommentCellTapGesture:(UITapGestureRecognizer*)recognizer
                        commentModel:(AVCommentModel*)commentModel;

@end


@interface AVCommentCell : UITableViewCell

@property (weak, nonatomic) id<AVCommentCellDelegate> delegate;

@property (strong, nonatomic) AVCommentModel *commentModel;

+ (CGFloat)heightWithModel:(AVCommentModel *)commentModel withLimitWidth:(CGFloat)limitWidth;

@end

NS_ASSUME_NONNULL_END
