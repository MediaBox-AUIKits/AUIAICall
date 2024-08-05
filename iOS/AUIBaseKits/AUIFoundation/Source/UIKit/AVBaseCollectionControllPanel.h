//
//  AVBaseCollectionControllPanel.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import "AVBaseControllPanel.h"

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

@interface AVBaseCollectionControllPanel : AVBaseControllPanel <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

@end

NS_ASSUME_NONNULL_END
