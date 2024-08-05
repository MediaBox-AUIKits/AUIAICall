//
//  AVCommonListViewController.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/21.
//

#import "AVBaseCollectionViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVCommonListItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, copy) void (^clickBlock)(void);

@end

@interface AVCommonListItemCell : UICollectionViewCell

@property (nonatomic, strong, readonly) AVCommonListItem *item;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UILabel *infoLabel;
@property (nonatomic, strong, readonly) UIImageView *iconView;
@property (nonatomic, strong, readonly) UIImageView *viewIconView;

- (void)updateItem:(AVCommonListItem *)item;

@end

@interface AVCommonListViewController : AVBaseCollectionViewController

- (instancetype)initWithItemList:(NSArray<AVCommonListItem *> *)itemList;

@property (nonatomic, copy, readonly) NSArray<AVCommonListItem *> *itemList;

@end

NS_ASSUME_NONNULL_END
