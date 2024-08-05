//
//  AVAlertController.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import "AVAlertController.h"
#import "AVLocalization.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"
#import "UIViewController+AVHelper.h"

@implementation AVAlertController

+ (void)show:(NSString *)message vc:(UIViewController *)vc {
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [AVTheme updateRootViewControllerInterfaceStyle:alertController];
    
    UIAlertAction *action2 =[UIAlertAction actionWithTitle:AVGetString(@"OK", @"AUIFoundation") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:action2];
    [vc presentViewController:alertController animated:YES completion:nil];
}

+ (void)show:(NSString *)message {
    UIViewController *vc = UIViewController.av_topViewController;
    [self show:message vc:vc];
}

+ (void)showInput:(NSString *)title vc:(UIViewController *)vc onCompleted:(void(^)(NSString *input))completed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [AVTheme updateRootViewControllerInterfaceStyle:alertController];
    
    [alertController addAction:[UIAlertAction actionWithTitle:AVGetString(@"OK", @"AUIFoundation") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UITextField *titleTextField = alertController.textFields.firstObject;
        NSLog(@"%@", titleTextField.text);
        if (completed) {
            completed(titleTextField.text);
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:AVGetString(@"Cancel", @"AUIFoundation") style:UIAlertActionStyleDefault handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
    }];
    
    vc = vc ?: UIViewController.av_topViewController;
    [vc presentViewController:alertController animated:true completion:nil];
}


+ (void)showInput:(NSString *)input title:(NSString *)title message:(NSString *)message okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle vc:(UIViewController *)vc onCompleted:(void(^)(NSString *input, BOOL isCancel))completed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [AVTheme updateRootViewControllerInterfaceStyle:alertController];
    
    [alertController addAction:[UIAlertAction actionWithTitle:okTitle ?: AVGetString(@"OK", @"AUIFoundation") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UITextField *titleTextField = alertController.textFields.firstObject;
        if (completed) {
            completed(titleTextField.text, NO);
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle ?: AVGetString(@"Cancel", @"AUIFoundation") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UITextField *titleTextField = alertController.textFields.firstObject;
        if (completed) {
            completed(titleTextField.text, YES);
        }
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = input;
    }];
    
    vc = vc ?: UIViewController.av_topViewController;
    [vc presentViewController:alertController animated:true completion:nil];
}

+ (void)showInput:(NSString *)inputTitle1
      inputTitle2:(NSString *)inputTitle2
            title:(NSString *)title
          message:(NSString *)message
          okTitle:(NSString *)okTitle
      cancelTitle:(NSString *)cancelTitle
               vc:(UIViewController *)vc
      onCompleted:(void(^)(NSString *input1, NSString *input2))completed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:okTitle ?: AVGetString(@"OK", @"AUIFoundation") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UITextField *titleTextField = alertController.textFields.firstObject;
        UITextField *titleTextField2 = alertController.textFields.lastObject;
        if (completed) {
            completed(titleTextField.text, titleTextField2.text);
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelTitle ?: AVGetString(@"Cancel", @"AUIFoundation") style:UIAlertActionStyleDefault handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = inputTitle1;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = inputTitle2;
    }];
    
    vc = vc ?: UIViewController.av_topViewController;
    [vc presentViewController:alertController animated:true completion:nil];
}


+ (void)showWithTitle:(NSString *)title message:(NSString *)message needCancel:(BOOL)needCancel onCompleted:(void(^)(BOOL isCanced))completed {
    [self showWithTitle:title message:message cancelTitle:needCancel?AUIFoundationLocalizedString(@"Cancel"):nil okTitle:AUIFoundationLocalizedString(@"OK") onCompleted:completed];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle onCompleted:(void(^)(BOOL isCanced))completed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [AVTheme updateRootViewControllerInterfaceStyle:alertController];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okTitle
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        if (completed) {
            completed(NO);
        }
    }];
    [alertController addAction:okAction];
    
    if (cancelTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
            if (completed) {
                completed(YES);
            }
        }];
        [alertController addAction:cancelAction];
    }
    
    UIViewController *topVC = UIViewController.av_topViewController;
    [topVC presentViewController:alertController animated:YES completion:nil];
}

+ (void)showSheet:(NSArray<NSString *> *)actionTitles alertTitle:(NSString *)alertTitle message:(NSString *)message cancelTitle:(NSString *)cancelTitle vc:(UIViewController *)vc onCompleted:(void (^)(NSInteger idx))completed {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [AVTheme updateRootViewControllerInterfaceStyle:alertController];
    
    [actionTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completed) {
                completed(idx);
            }
        }];
        [alertController addAction:action];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle ?: AUIFoundationLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    vc = vc ?: UIViewController.av_topViewController;
    [vc presentViewController:alertController animated:true completion:nil];
}

@end
