//
//  AUIPickerPanel.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import "AUIPickerPanel.h"
#import "AVLocalization.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"

@interface AUIPickerPanel () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerVIew;

@end


@implementation AUIPickerPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _pickerVIew = [[UIPickerView alloc] initWithFrame:self.contentView.bounds];
        _pickerVIew.delegate = self;
        _pickerVIew.dataSource = self;
        [self.contentView addSubview:_pickerVIew];
        
        self.titleView.text = @"";
        
        UIButton *cancelBtn = [UIButton new];
        [cancelBtn setTitle:AUIFoundationLocalizedString(@"Cancel") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:AUIFoundationColor(@"text_medium") forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = AVGetRegularFont(15);
        [cancelBtn sizeToFit];
        cancelBtn.frame = CGRectMake(20, 0, cancelBtn.av_width, self.headerView.av_height);
        [cancelBtn addTarget:self action:@selector(onCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:cancelBtn];
        
        UIButton *okBtn = [UIButton new];
        [okBtn setTitle:AUIFoundationLocalizedString(@"OK") forState:UIControlStateNormal];
        [okBtn setTitleColor:AUIFoundationColor(@"colourful_text_strong") forState:UIControlStateNormal];
        okBtn.titleLabel.font = AVGetRegularFont(15);
        [okBtn sizeToFit];
        okBtn.frame = CGRectMake(self.headerView.av_width - 20 - okBtn.av_width, 0, okBtn.av_width, self.headerView.av_height);
        [okBtn addTarget:self action:@selector(onOkClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:okBtn];
    }
    return self;
}

- (void)onCancelClicked:(UIButton *)sender {
    [self.class dismiss:self];
    if (self.onDismissed) {
        self.onDismissed(self, YES);
    }
}

- (void)onOkClicked:(UIButton *)sender {
    [self.class dismiss:self];
    if (self.onDismissed) {
        self.onDismissed(self, NO);
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.listArray.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *text = [self.listArray objectAtIndex:row];
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:text attributes:@{
        NSForegroundColorAttributeName:AUIFoundationColor(@"text_strong")
    }];
    return attr;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedIndex = row;
}

- (void)setListArray:(NSArray<NSString *> *)listArray {
    if (_listArray == listArray) {
        return;
    }
    
    _listArray = listArray;
    [self.pickerVIew reloadAllComponents];
    if (self.selectedIndex > _listArray.count) {
        self.selectedIndex = 0;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (_selectedIndex == selectedIndex) {
        return;
    }
    if (selectedIndex < 0) {
        return;
    }
    if (selectedIndex > 0 && selectedIndex >= self.listArray.count) {
        return;
    }
    
    _selectedIndex = selectedIndex;
    
    if (self.listArray.count > 0) {
        [self.pickerVIew selectRow:_selectedIndex inComponent:0 animated:YES];
    }
}

@end
