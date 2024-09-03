//
//  AVQRCodeScanner.h
//  AUIFoundation
//
//  Created by Bingo on 2024/8/7.
//

#import "AVQRCodeScanner.h"
#import "AVDeviceAuth.h"
#import <AVFoundation/AVFoundation.h>

@interface AVQRCodeScanner () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation AVQRCodeScanner

- (void)dealloc {
    NSLog(@"dealloc: AVQRCodeScanner");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hiddenMenuButton = YES;
    self.contentView.frame = self.view.bounds;
    [self.view sendSubviewToBack:self.contentView];
    
    [AVDeviceAuth checkCameraAuth:^(BOOL auth) {
            
        if (auth == NO) {
            return;
        }
        
        // 初始化扫描会话
        self.captureSession = [[AVCaptureSession alloc] init];

        // 获取设备的相机
        AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:nil];
        
        if (videoInput) {
            [self.captureSession addInput:videoInput];
            
            // 初始化元数据输出
            AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
            [self.captureSession addOutput:metadataOutput];
            
            // 设置代理
            [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
            metadataOutput.rectOfInterest = CGRectMake(0.1, 0.2, 0.8, 0.6);
            
            // 初始化预览图层
            self.videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
            self.videoPreviewLayer.frame = self.contentView.layer.bounds;
            self.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.contentView.layer addSublayer:self.videoPreviewLayer];
            
            // 开始扫描
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.captureSession startRunning];
            });
        } else {
            // 处理无法获取相机的情况
            NSLog(@"Unable to obtain video input.");
        }
    }];
}


// 扫描结果回调方法
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        NSString *qrCodeContent = metadataObject.stringValue;
        
        // 处理二维码内容
        NSLog(@"QRCode Content: %@", qrCodeContent);
        if (self.scanResultBlock) {
            self.scanResultBlock(self, qrCodeContent);
        }
        
        // 停止扫描
        [self.captureSession stopRunning];
    }
}

// 确保在视图消失时停止会话
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.captureSession stopRunning];
    });
}

@end
