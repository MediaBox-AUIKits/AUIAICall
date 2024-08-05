//
//  AVCommentView.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVCommentView.h"
#import "AVCommentTableView.h"
#import "AVCommentCell.h"
#import "AUIFoundationMacro.h"
#import "UIColor+AVHelper.h"
#import "UIView+AVHelper.h"
#import <Masonry/Masonry.h>

@interface AVCommentView() <AVCommentTableViewDelegate>

@property (strong, nonatomic) AVCommentTableView *internalCommentView;
@property (assign, nonatomic) AVCommentViewMode mode;

@end

@implementation AVCommentView

- (instancetype)initWithFrame:(CGRect)frame mode:(AVCommentViewMode)mode  needShowNewCommentTips:(BOOL)needShowNewCommentTips {
    self = [super initWithFrame:frame];
    if (self) {
        _mode = mode;
        _internalCommentView = [[AVCommentTableView alloc] initWithFrame:self.bounds];
        _internalCommentView.commentDelegate = self;
        [self addSubview:_internalCommentView];
        
        if (needShowNewCommentTips) {
            _showNewCommentTipsButton = [[UIButton alloc] initWithFrame:CGRectZero];
            _showNewCommentTipsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
            [_showNewCommentTipsButton setTitle:AUIFoundationLocalizedString(@"You have new messages") forState:UIControlStateNormal];
            [_showNewCommentTipsButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
            _showNewCommentTipsButton.titleLabel.font = AVGetRegularFont(14);
            [_showNewCommentTipsButton setImage:AUIFoundationCommonImage(@"ic_comment_tips") forState:UIControlStateNormal];
            
            _showNewCommentTipsButton.hidden = YES;
            [_showNewCommentTipsButton addTarget:self action:@selector(onClickShowNewCommentTipsButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_showNewCommentTipsButton];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame mode:AVCommentViewModeBottom needShowNewCommentTips:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _internalCommentView.frame = self.bounds;
    
    [_showNewCommentTipsButton sizeToFit];
    _showNewCommentTipsButton.frame = CGRectMake(self.av_width - _showNewCommentTipsButton.av_width, self.av_height - _showNewCommentTipsButton.av_height, _showNewCommentTipsButton.av_width + 12, 28);
}

- (void)setCommentBackgroundColor:(UIColor *)commentBackgroundColor {
    self.internalCommentView.commentBackgroundColor = commentBackgroundColor;
}

- (UIColor *)commentBackgroundColor {
    return self.internalCommentView.commentBackgroundColor;
}

- (NSArray<AVCommentModel *> *)commentList {
    return self.internalCommentView.commentList;
}

#pragma mark -Public Methods

- (void)insertLiveComment:(AVCommentModel *)comment {
    
    if (_internalCommentView.av_width > 0) {
        if (self.mode == AVCommentViewModeBottom) {
            comment.cellHeight = [AVCommentCell heightWithModel:comment withLimitWidth:_internalCommentView.av_width];
            CGFloat height = self.internalCommentView.contentSize.height + comment.cellHeight;
            _internalCommentView.contentInset = UIEdgeInsetsMake(MAX(_internalCommentView.av_height - height, 0), 0, 0, 0);
        }
    }
    
    [self.internalCommentView insertNewComment:comment];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNewCommentTips) object:nil];
    [self performSelector:@selector(checkNewCommentTips) withObject:nil afterDelay:0.5];
}

- (void)insertLiveComment:(NSString *)content
        commentSenderNick:(NSString *)nick
          commentSenderID:(NSString *)userID {
    AVCommentModel* model = [[AVCommentModel alloc] init];
    model.senderID = userID;
    model.senderNick = nick;
    model.sentContent = content;
    
    [self insertLiveComment:model];
}

//- (void)runAutoCommentInputTest {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random() % 1000 / 500.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *string = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
//        NSUInteger count = string.length;
//        NSMutableString *nick = [NSMutableString new];
//        NSUInteger nickLength = arc4random() % 10 + 1;
//        for (NSUInteger i=0; i<nickLength; i++) {
//            [nick appendString:[string substringWithRange:NSMakeRange(arc4random()%count, 1)]];
//        }
//
//        NSMutableString *comment = [NSMutableString new];
//        NSUInteger commentLength = arc4random() % 50 + 5;
//        for (NSUInteger i=0; i<commentLength; i++) {
//            [comment appendString:[string substringWithRange:NSMakeRange(arc4random()%count, 1)]];
//        }
//
//        AVCommentModel* model = [[AVCommentModel alloc] init];
//        model.sentContent = comment;
//        model.senderNick = nick;
//        model.sentContentColor = AUIFoundationColor(@"text_strong");
//        model.senderNickColor = AUIFoundationColor(@"text_weak");
//        model.useFlag = YES;
//        model.isAnchor = YES;
//        model.isMe = YES;
//        [self insertLiveComment:model];
//
//        if (self.internalCommentView.commentList.count < 100) {
//            [self runAutoCommentInputTest];
//        }
//    });
//}

#pragma mark - new comment tips

- (void)checkNewCommentTips {
    if (_showNewCommentTipsButton) {
        _showNewCommentTipsButton.hidden = [self.internalCommentView presentingOnLastComment];
    }
}

- (void)onClickShowNewCommentTipsButton:(UIButton *)sender {
    _showNewCommentTipsButton.hidden = YES;
    [self.internalCommentView scrollToLastComment];
}

#pragma mark -AVCommentTableViewDelegate

- (void)onCommentDidScrolled {
    if ([self.internalCommentView presentingOnLastComment]) {
        _showNewCommentTipsButton.hidden = YES;
    }
}

-(void)onCommentCellLongPressed:(AVCommentModel *)commentModel {

}

-(void)onCommentCellTapped:(AVCommentModel *)commentModel {

}

@end
