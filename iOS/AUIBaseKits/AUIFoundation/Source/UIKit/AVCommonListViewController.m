//
//  AVCommonListViewController.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/21.
//

#import "AVCommonListViewController.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"

@implementation AVCommonListItem

@end

@implementation AVCommonListItemCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_iconView];

        _titleLabel = [UILabel new];
        _titleLabel.textColor = AUIFoundationColor(@"text_strong");
        _titleLabel.font = AVGetMediumFont(16);
        _titleLabel.numberOfLines = 1;
        _titleLabel.text = @"";
        [self.contentView addSubview:_titleLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = AUIFoundationColor(@"text_weak");
        _infoLabel.font = AVGetMediumFont(12);
        _infoLabel.numberOfLines = 1;
        _infoLabel.text = @"";
        [self.contentView addSubview:_infoLabel];
        
        _viewIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_viewIconView];
        
        self.backgroundColor = AUIFoundationColor(@"fg_strong");
        [self av_setLayerBorderColor:AUIFoundationColor(@"border_weak") borderWidth:1];
        self.layer.cornerRadius = 12.0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.iconView.frame = CGRectMake(20, (self.contentView.av_height - 40) / 2.0, 40, 40);
    self.viewIconView.frame = CGRectMake(self.contentView.av_right - 26 - 14, (self.contentView.av_height - 14) / 2.0, 14, 14);
    if (self.infoLabel.text.length == 0) {
        self.titleLabel.frame = CGRectMake(self.iconView.av_right + 16, (self.contentView.av_height - 24) / 2.0, self.viewIconView.av_left - self.iconView.av_right - 32, 24);
    }
    else {
        self.titleLabel.frame = CGRectMake(self.iconView.av_right + 16, (self.contentView.av_height - (24+18+1)) / 2.0, self.viewIconView.av_left - self.iconView.av_right - 32, 24);
    }
    self.infoLabel.frame = CGRectMake(self.titleLabel.av_left, self.titleLabel.av_bottom + 1, self.titleLabel.av_width, 18);
}

- (void)updateItem:(AVCommonListItem *)item {
    _item = item;
    self.iconView.image = item.icon;
    self.viewIconView.image = AUIFoundationImage(@"ic_arraw");
    self.titleLabel.text = item.title;
    self.infoLabel.text = item.info;
}

@end

@interface AVCommonListViewController ()

@end

@implementation AVCommonListViewController

- (instancetype)initWithItemList:(NSArray<AVCommonListItem *> *)itemList {
    self = [super init];
    if (self) {
        _itemList = [itemList copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delaysContentTouches = NO;
    [self.collectionView registerClass:AVCommonListItemCell.class forCellWithReuseIdentifier:AVCollectionViewCellIdentifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.itemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AVCommonListItemCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:AVCollectionViewCellIdentifier forIndexPath:indexPath];
    [cell updateItem:self.itemList[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AVCommonListItem *item = [self.itemList objectAtIndex:indexPath.row];
    if (item.clickBlock) {
        item.clickBlock();
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.av_width - 20 - 20, 72.0);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
   //当cell高亮时返回是否高亮
    return YES;
}
 
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //设置(Highlight)高亮下的颜色
    AVCommonListItemCell* cell = (AVCommonListItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:AVCommonListItemCell.class]) {
        cell.backgroundColor = AUIFoundationColor(@"bg_weak");
    }
}
 
- (void)collectionView:(UICollectionView *)collectionView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    //设置(Nomal)正常状态下的颜色
    AVCommonListItemCell* cell = (AVCommonListItemCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:AVCommonListItemCell.class]) {
        cell.backgroundColor = AUIFoundationColor(@"fg_strong");
    }
}

@end
