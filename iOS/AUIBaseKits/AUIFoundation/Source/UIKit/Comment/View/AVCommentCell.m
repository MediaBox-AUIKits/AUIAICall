//
//  AVCommentCell.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVCommentCell.h"
#import "AVEdgeInsetLabel.h"
#import "AUIFoundationMacro.h"
#import "UIView+AVHelper.h"
#import "UIColor+AVHelper.h"

@interface AVCommentCell()

@property (strong, nonatomic) AVEdgeInsetLabel *commentLabel;

@end

@implementation AVCommentCell

- (void)setCommentModel:(AVCommentModel *)commentModel{
    if (_commentModel == commentModel) {
        return;
    }
    _commentModel = commentModel;
    self.commentLabel.textInsets = commentModel.sentContentInsets;
    self.commentLabel.attributedText = commentModel.renderContent;
    [self layoutIfNeeded];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addTapGestureRecognizer];
        [self addLongPressGestureRecognizer];
        
        self.commentLabel = [[AVEdgeInsetLabel alloc] init];
        self.commentLabel.layer.cornerRadius = 4.0;
        self.commentLabel.layer.shouldRasterize = YES; //圆角缓存
        self.commentLabel.layer.masksToBounds = YES;
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
        self.commentLabel.textInsets = UIEdgeInsetsMake(2, 8, 2, 8);
        self.commentLabel.font = AVGetRegularFont(14);
        [self.contentView addSubview:self.commentLabel];
        
        self.backgroundColor = nil;
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    super.backgroundColor = UIColor.clearColor;
    self.commentLabel.backgroundColor = backgroundColor ?: [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
}

- (UIColor *)backgroundColor {
    return self.commentLabel.backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets insets = self.commentModel.sentContentInsets;
    UIEdgeInsets cellInsets = self.commentModel.cellInsets;
    CGSize size = [self.commentLabel sizeThatFits:CGSizeMake(self.av_width - (cellInsets.left + cellInsets.right) - (insets.left + insets.right), 0)];
    self.commentLabel.frame = CGRectMake(cellInsets.left, cellInsets.top, size.width + self.commentLabel.textInsets.left + self.commentLabel.textInsets.right, size.height + insets.top + insets.bottom);
}

- (void)addLongPressGestureRecognizer {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
    recognizer.minimumPressDuration = 1;
    [self.contentView addGestureRecognizer:recognizer];
}

- (void)addTapGestureRecognizer {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.contentView addGestureRecognizer:recognizer];
}

- (void)longPressGestureAction:(UILongPressGestureRecognizer*)recognizer{
    if ([self.delegate respondsToSelector:@selector(onCommentCellLongPressGesture:commentModel:)]){
        [self.delegate onCommentCellLongPressGesture:recognizer commentModel:self.commentModel];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer*)recognizer{
    if ([self.delegate respondsToSelector:@selector(onCommentCellTapGesture:commentModel:)]){
        [self.delegate onCommentCellTapGesture:recognizer commentModel:self.commentModel];
    }
}

+ (CGFloat)heightWithModel:(AVCommentModel *)commentModel withLimitWidth:(CGFloat)limitWidth {
    CGRect rect = [commentModel.renderContent boundingRectWithSize:CGSizeMake(limitWidth - (commentModel.cellInsets.left + commentModel.cellInsets.right) - (commentModel.sentContentInsets.left + commentModel.sentContentInsets.right), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect.size.height + commentModel.sentContentInsets.top + commentModel.sentContentInsets.bottom + commentModel.cellInsets.top + commentModel.cellInsets.bottom;
}

@end
