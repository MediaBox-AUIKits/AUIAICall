//
//  AUIPickerPanel.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import "AVBaseControllPanel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPickerPanel : AVBaseControllPanel

@property (nonatomic, copy) NSArray<NSString *> *listArray;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, copy) void(^onDismissed)(AUIPickerPanel *sender, BOOL cancel);


@end

NS_ASSUME_NONNULL_END
