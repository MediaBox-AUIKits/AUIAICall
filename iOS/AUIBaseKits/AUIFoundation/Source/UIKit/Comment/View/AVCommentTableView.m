//
//  AVCommentTableView.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVCommentTableView.h"
#import "AVCommentCell.h"
#import "UIView+AVHelper.h"

#define ReuseableCellId @"CommentViewCell"

@interface AVCommentTableView ()<UITableViewDelegate, UITableViewDataSource, AVCommentCellDelegate>

@property (strong, nonatomic) NSMutableArray<AVCommentModel *> *commentsPresented;
@property (assign, nonatomic) BOOL autoScroll;

@end


@implementation AVCommentTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.dataSource = self;
        self.delegate = self;
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self registerClass:[AVCommentCell class] forCellReuseIdentifier:ReuseableCellId];
        
        _commentsPresented = [[NSMutableArray alloc] init];
        _autoScroll = YES;
    }
    return self;
}

- (void)scrollToLastComment {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkAutoScroll) object:nil];
    self.autoScroll = YES;
    if (self.commentsPresented.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.commentsPresented.count - 1 inSection:0];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (BOOL)presentingOnLastComment {
    if (self.contentOffset.y + self.av_height >= self.contentSize.height + self.contentInset.bottom - self.commentList.lastObject.cellHeight) {
        return YES;
    }
    return NO;
}

- (NSArray<AVCommentModel *> *)commentList {
    return self.commentsPresented;
}

- (void)insertNewComment:(AVCommentModel *)comment {
    [self.commentsPresented addObject:comment];
    
    [CATransaction begin];
    [self beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.commentsPresented.count - 1 inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
    [CATransaction commit];
    
    if (self.autoScroll) {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVCommentModel *model = self.commentsPresented[indexPath.row];
    if (model.cellHeight <= 0) {
        model.cellHeight = [AVCommentCell heightWithModel:model withLimitWidth:self.av_width];
    }
    return model.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentsPresented.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AVCommentCell* cell = [self dequeueReusableCellWithIdentifier:ReuseableCellId];
    cell.delegate = self;
    cell.commentModel = self.commentsPresented[indexPath.row];
    cell.backgroundColor = self.commentBackgroundColor;
    return cell;
}

#pragma mark - auto scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.commentDelegate respondsToSelector:@selector(onCommentDidScrolled)]) {
        [self.commentDelegate onCommentDidScrolled];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDragging");
    self.autoScroll = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkAutoScroll) object:nil];

}

//#define AUTO_SCROLL
// 滚动方案，打开宏AUTO_SCROLL使用方案2，默认方案1
// 方案1：是否滑动到底，是的话，切换到自动滚动
// 方案2：5.0s后自动滚动

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"scrollViewDidEndDragging");
#ifndef AUTO_SCROLL
    [self performSelector:@selector(checkAutoScroll) withObject:nil afterDelay:0.5];
#else
    [self performSelector:@selector(checkAutoScroll) withObject:nil afterDelay:5.0];
#endif
}

- (void)checkAutoScroll {
#ifndef AUTO_SCROLL
    if ([self presentingOnLastComment]) {
        self.autoScroll = YES;
    }
#else
    self.autoScroll = YES;
#endif
}

#pragma mark - AVCommentCellDelegate

-(void)onCommentCellLongPressGesture:(UILongPressGestureRecognizer *)recognizer commentModel:(AVCommentModel *)commentModel{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        if([self.commentDelegate respondsToSelector:@selector(onCommentCellTapped:)]){
            [self.commentDelegate onCommentCellTapped:commentModel];
        }
    }
}

-(void)onCommentCellTapGesture:(UITapGestureRecognizer *)recognizer
                       commentModel:(AVCommentModel *)commentModel {
    if([self.commentDelegate respondsToSelector:@selector(onCommentCellTapped:)]){
        [self.commentDelegate onCommentCellTapped:commentModel];
    }
}

@end
