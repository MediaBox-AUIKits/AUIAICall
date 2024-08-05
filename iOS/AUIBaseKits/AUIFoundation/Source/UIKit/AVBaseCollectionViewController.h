//
//  AVBaseCollectionViewController.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import "AVBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

#ifndef AVCollectionViewCellIdentifier
#define AVCollectionViewCellIdentifier @"defaultCell"
#endif

#ifndef AVCollectionHeaderIdentifier
#define AVCollectionHeaderIdentifier @"defaultHeader"
#endif

#ifndef AVCollectionFooterIdentifier
#define AVCollectionFooterIdentifier @"defaultFooter"
#endif


@interface AVBaseCollectionViewController : AVBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
