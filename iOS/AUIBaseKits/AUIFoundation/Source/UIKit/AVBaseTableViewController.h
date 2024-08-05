//
//  AVBaseTableViewController.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import "AVBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

#define AVTableViewCellIdentifier @"defaultCell"

@interface AVBaseTableViewController : AVBaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong, readonly) UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
