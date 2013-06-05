//
//  XHFCameraViewController.m
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//


#import "XHFCameraViewController.h"
#import "XHFThumbnailBar.h"
#import "XHFPhotoBrowseViewController.h"
#import "XHFAlbumViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface XHFCameraViewController ()

@end

@implementation XHFCameraViewController{
    NSMutableArray *_photos;
    AVCaptureDevice *_device;
    AVCaptureSession *_session;
    
    AVCaptureStillImageOutput *_output;
    
    AVCaptureVideoPreviewLayer *_monitorLayer;
    
    UIView *_cameraContainerView;//容器，用作前后摄像头切换
    UIView *_monitorView;
    
    UIButton *_backButton;
    UIButton *_albumButton;
    UIButton *_takePicButton;
    UIButton *_confirmButton;
    
    UIButton *_cameraSwapButton;//前后摄像头切换按钮
    UIButton *_flashlightButton;//闪光灯按钮
    
    XHFThumbnailBar *_thumbnailBar;
}

- (id)initWithInitPhotos:(NSArray *)photos{
    self=[super init];
    if(self){
        _photos=[[NSMutableArray alloc]initWithArray:photos];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor blackColor];
    
	//配置摄像头监控区
    _cameraContainerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _monitorView=[[UIView alloc]initWithFrame:_cameraContainerView.bounds];
    [_cameraContainerView addSubview:_monitorView];
    
    _session=[[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    _device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error=nil;
    AVCaptureDeviceInput *input=[AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if(!input){
        NSLog(@"%@",error);
    }
    [_session addInput:input];
    
    _output=[[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings=[[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [_output setOutputSettings:outputSettings];
    
    [_session addOutput:_output];
    
    
    
    _monitorLayer=[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _monitorLayer.frame=_monitorView.bounds;
    _monitorLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [_monitorView.layer addSublayer:_monitorLayer];
    [self.view addSubview:_cameraContainerView];
    
    //闪光灯按钮
    _flashlightButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _flashlightButton.frame=CGRectMake(20, 20, 78, 35);
    [_flashlightButton addTarget:self action:@selector(turnFlashLight:) forControlEvents:UIControlEventTouchUpInside];
    if(_device!=nil && [_device hasFlash]){
        [_device lockForConfiguration:nil];
        [_device setFlashMode:AVCaptureFlashModeOff];
        [_device unlockForConfiguration];
        [_cameraContainerView addSubview:_flashlightButton];
        [_flashlightButton setImage:[UIImage imageNamed:@"camera_flash_off.png"] forState:UIControlStateNormal];
    }
    
    //前后摄像头切换按钮
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] &&
       [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
        _cameraSwapButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_cameraSwapButton setTitle:@"前后切换" forState:UIControlStateNormal];
        _cameraSwapButton.frame=CGRectMake(220, 20, 80, 35);
        [_cameraSwapButton addTarget:self action:@selector(swapFrontAndBackCameras) forControlEvents:UIControlEventTouchUpInside];
        [_monitorView addSubview:_cameraSwapButton];
    }
        
    //配置5个缩略图区
    _thumbnailBar=[[XHFThumbnailBar alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-58-50-1.0f, SCREEN_WIDTH, 50)];
    __block NSMutableArray *tmpPhotos=_photos;
    __block XHFThumbnailBar *tmpBar=_thumbnailBar;
    __block XHFCameraViewController *blockSelf=self;
    _thumbnailBar.removeBlock=[^(XHFSelectPhoto *photo){
        [tmpPhotos removeObject:photo];
        [tmpBar redrawWithSelectPhotos:tmpPhotos];
    } copy];
    
    _thumbnailBar.BrowseBlock=[^(int index){
        XHFPhotoBrowseViewController *controller=[[XHFPhotoBrowseViewController alloc]initWithPhotos:tmpPhotos andIndex:index andReturnBlock:^(NSArray *photos) {
            [tmpPhotos removeAllObjects];
            [tmpPhotos addObjectsFromArray:photos];
            [tmpBar redrawWithSelectPhotos:tmpPhotos];
        }];
        [blockSelf presentViewController:controller animated:YES completion:nil];
    } copy];
    [_thumbnailBar redrawWithSelectPhotos:_photos];
    
    [self.view addSubview:_thumbnailBar];
    
    //配置ToolBar
    UIView *toolbarView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-58, SCREEN_WIDTH, 58)];
    UIImageView *toolbarGBView=[[UIImageView alloc] initWithFrame:toolbarView.bounds];
    toolbarGBView.image=[UIImage imageNamed:@"camera_toolBar_bg.png"];
    [toolbarView addSubview:toolbarGBView];
    
    _backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame=CGRectMake(10, 10, 40, 40);
    _backButton.backgroundColor=[UIColor clearColor];
    [_backButton setImage:[UIImage imageNamed:@"camera_back_btn.png"] forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"camera_back_btn_highlight.png"] forState:UIControlStateHighlighted];
    [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:_backButton];
    
    _albumButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _albumButton.frame=CGRectMake(88, 12, 39, 39);
    [_albumButton setImage:[UIImage imageNamed:@"album_btn.png"] forState:UIControlStateNormal];
    [_albumButton setImage:[UIImage imageNamed:@"album_btn_highlight.png"] forState:UIControlStateHighlighted];
    [_albumButton setImage:[UIImage imageNamed:@"album_btn_highlight.png"] forState:UIControlStateDisabled];
    [_albumButton addTarget:self action:@selector(albumButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:_albumButton];
    
    _takePicButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _takePicButton.frame=CGRectMake(135, 12, 98, 40);
    [_takePicButton setImage:[UIImage imageNamed:@"camera_btn.png"] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageNamed:@"camera_btn_highlight.png"] forState:UIControlStateHighlighted];
    [_takePicButton addTarget:self action:@selector(takeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    if([_photos count]>=MAX_PHOTO_COUNT){
        _takePicButton.enabled=NO;
    }
    
    [toolbarView addSubview:_takePicButton];
    
    _confirmButton=[UIButton buttonWithType:UIButtonTypeCustom];
    _confirmButton.frame=CGRectMake(toolbarView.bounds.size.width-20-26, 10, 40, 40);
    [_confirmButton setImage:[UIImage imageNamed:@"camera_ok_btn.png"] forState:UIControlStateNormal];
    [_confirmButton setImage:[UIImage imageNamed:@"camera_ok_btn_highlight.png"] forState:UIControlStateHighlighted];
    [_confirmButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton.hidden=YES;
    [toolbarView addSubview:_confirmButton];
    
    [self.view addSubview:toolbarView];

    [_session startRunning];
}

- (void)viewDidUnload{
    [_session stopRunning];
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}
//开关闪光灯
-(void)turnFlashLight:(id)a{
    if([_device hasFlash]){
        BOOL on=YES;
        if([_device flashMode]==AVCaptureFlashModeOff){
            on=YES;
        }else{
            on=NO;
        }
        [_device lockForConfiguration:nil];
        if(on){
            [_device setFlashMode:AVCaptureFlashModeOn];
            [_flashlightButton setImage:[UIImage imageNamed:@"camera_flash_on.png"] forState:UIControlStateNormal];
        }else{
            [_device setFlashMode:AVCaptureFlashModeOff];
            [_flashlightButton setImage:[UIImage imageNamed:@"camera_flash_off.png"] forState:UIControlStateNormal];
        }
        [_device unlockForConfiguration];
    }
}

//切换前后摄像头
-(void)swapFrontAndBackCameras{
    
    AVCaptureSession *oldSession=_session;
    
    AVCaptureDevice *newCamera=nil;
    NSArray *inputs = _session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            
            break;
        }
    }
    
    
    
    AVCaptureSession *newSession=[[AVCaptureSession alloc] init];
    [newSession setSessionPreset:AVCaptureSessionPresetPhoto];
    
    AVCaptureDeviceInput *input=[AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    [newSession addInput:input];
    
    AVCaptureStillImageOutput *newOutput=[[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings=[[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [_output setOutputSettings:outputSettings];
    
    [newSession addOutput:newOutput];
    
    
    
    UIView *newMonitorView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    newMonitorView.backgroundColor=[UIColor grayColor];
    AVCaptureVideoPreviewLayer *newMonitorLayer=[AVCaptureVideoPreviewLayer layerWithSession:newSession];
    newMonitorLayer.frame=newMonitorView.bounds;
    newMonitorLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    [newMonitorView.layer addSublayer:newMonitorLayer];
    //闪光灯按钮
    [_flashlightButton removeFromSuperview];
    if([newCamera hasFlash]){
        [newMonitorView addSubview:_flashlightButton];
        if([newCamera flashMode]==AVCaptureFlashModeOff){
            [_flashlightButton setTitle:@"打开" forState:UIControlStateNormal];
        }else{
            [_flashlightButton setTitle:@"关闭" forState:UIControlStateNormal];
        }
    }
    
    //动画开始
    [UIView beginAnimations:@"Flip" context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView transitionWithView:_cameraContainerView duration:2.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [_cameraSwapButton removeFromSuperview];
        [_monitorView removeFromSuperview];
        
        [_cameraContainerView addSubview:newMonitorView];
        
        [newMonitorView addSubview:_cameraSwapButton];
        _monitorView=newMonitorView;
        _monitorLayer=newMonitorLayer;
        _device=newCamera;
        _session=newSession;
        _output=newOutput;
        [_session startRunning];
        
        
    } completion:^(BOOL r){
        [oldSession stopRunning];
    }];
    [UIView commitAnimations];

    
}

#pragma mark Button Click Process
- (void) backButtonAction{
    NSArray *array=[[NSArray alloc] initWithArray:_photos];
    for(int i=0;i<[array count];i++){
        XHFSelectPhoto *photo=[array objectAtIndex:i];
        if(photo.status==0){
            [_photos removeObject:photo];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.ReturnBlock(_photos,nil);
    }];
}

- (void)albumButtonAction{
    [self dismissViewControllerAnimated:YES completion:^{
        self.ReturnBlock(_photos,ALBUM);
    }];
}

- (void)takeButtonAction{
    
    AVCaptureConnection *conn=nil;
    for(AVCaptureConnection *c in _output.connections){
        for(AVCaptureInputPort *port in [c inputPorts]){
            if([[port mediaType] isEqual:AVMediaTypeVideo]){
                conn=c;
                break;
            }
        }
    }
    if(!conn){
        return;
    }
    
    [_output captureStillImageAsynchronouslyFromConnection:conn completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if(!error){
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            //拍照
            if([_photos count]>=MAX_PHOTO_COUNT){
                return;
            }
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970]*1000;
            NSString *timeString = [NSString stringWithFormat:@"%.0f", a];//转为字符型
            
            NSString *imgName=[timeString stringByAppendingString:@".jpg"];
            NSString *path=[[XHFMultiPhotoPicker localCacheFolder] stringByAppendingPathComponent:imgName];
            [UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0) writeToFile:path atomically:YES];
            
            XHFSelectPhoto *photo=[[XHFSelectPhoto alloc]init];
            photo.localPath=path;
            photo.thumbnail=[XHFSelectPhoto loadLocalThumbnail:photo.localPath];
            [_photos addObject:photo];
            [_thumbnailBar redrawWithSelectPhotos:[[NSArray alloc]initWithArray:_photos]];
            if([_photos count]>0){
                _confirmButton.hidden=NO;
            }
            if([_photos count]>=MAX_PHOTO_COUNT){
                _takePicButton.enabled=NO;
            }
        }else{
            NSLog(@"Error: %@",error);
        }
        
    }];
}

- (void)confirmAction{
    [self dismissViewControllerAnimated:YES completion:^{
        self.ReturnBlock(_photos,nil);
    }];

}


@end
