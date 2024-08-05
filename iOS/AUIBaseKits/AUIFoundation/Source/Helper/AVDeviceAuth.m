//
//  AVDeviceAuth.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/23.
//

#import "AVDeviceAuth.h"
#import "AVAlertController.h"
#import "AUIFoundationMacro.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVDeviceAuth

+ (void)checkCameraAuth:(void(^)(BOOL auth))completed {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(granted);
                }
            });
        }];
        return;
    }
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AVAlertController showWithTitle:@"" message:AUIFoundationLocalizedString(@"Camera permission is required to use this feature.") cancelTitle:AUIFoundationLocalizedString(@"Cancel") okTitle:AUIFoundationLocalizedString(@"Go to Settings") onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                }
            }
        }];
        return;
    }
    
    if (completed) {
        completed(YES);
    }
}

+ (void)checkMicAuth:(void(^)(BOOL auth))completed {
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(granted);
                }
            });
        }];
        return;
    }
    
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AVAlertController showWithTitle:@"" message:AUIFoundationLocalizedString(@"Microphone permission is needed to enable live streaming features.") cancelTitle:AUIFoundationLocalizedString(@"Cancel") okTitle:AUIFoundationLocalizedString(@"Go to Settings") onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    // Fallback on earlier versions
                }
            }
        }];
        return;
    }
    
    if (completed) {
        completed(YES);
    }
}

@end
