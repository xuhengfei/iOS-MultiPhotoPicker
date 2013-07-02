//
//  XHFPhotoPicker.m
//  Photo
//
//  Created by 周方 on 13-5-28.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import "XHFMultiPhotoPicker.h"
#import "XHFCameraViewController.h"
#import "XHFAlbumViewController.h"
#import "XHFSelectPhoto.h"


@interface ActionSheetObject : NSObject  <UIActionSheetDelegate>

@property (nonatomic,strong) UIViewController *vc;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,copy) XHFResultBlock resultBlock;

@end
static ActionSheetObject *singleton;

static NSString *localCacheFolder;

@implementation ActionSheetObject

- (id)init{
    self=[super init];
    singleton=self;
    return self;
}

#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *str=[actionSheet buttonTitleAtIndex:buttonIndex];
    if( [str isEqualToString:@"拍照"]){
        [XHFMultiPhotoPicker pickWithType:CAMERA InitPhotos:self.photos ViewController:self.vc ResultBlock:self.resultBlock];
    }else if([str isEqualToString:@"相册"]){
        [XHFMultiPhotoPicker pickWithType:ALBUM InitPhotos:self.photos ViewController:self.vc ResultBlock:self.resultBlock];
    }else{
        if(_resultBlock !=nil){
            _resultBlock(self.photos);
        }
    }
}


@end

@implementation XHFMultiPhotoPicker

+ (void)pickWithType:(SOURCE_TYPE)type InitPhotos:(NSArray *)photos ViewController:(UIViewController *)vc ResultBlock:(XHFResultBlock)resultBlock{
    if(type==USER_SELECT){
        ActionSheetObject *object=[[ActionSheetObject alloc]init];
        object.vc=vc;
        object.photos=photos;
        object.resultBlock=resultBlock;
        UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"选择照片来源" delegate:object cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
        [sheet showInView:vc.view.window];
    }else if(type==ALBUM){
        XHFAlbumViewController *album=[[XHFAlbumViewController alloc]initWithInitPhotos:photos];
        album.resultBlock=^(NSArray *photos){
            if(resultBlock!=nil){
                resultBlock(photos);
            }
        };
        [vc presentViewController:album animated:YES completion:nil];
    }else if(type==CAMERA){
        if(![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]){
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"出错了" message:@"设备不支持摄像头" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }

        XHFCameraViewController *camera=[[XHFCameraViewController alloc]initWithInitPhotos:photos];
        camera.ReturnBlock=^(NSArray *photos,SOURCE_TYPE type){
            if(type==ALBUM){
                [self pickWithType:ALBUM InitPhotos:photos ViewController:vc ResultBlock:resultBlock];
                return;
            }
            if(resultBlock!=nil){
                resultBlock(photos);
            }
        };
        [vc presentViewController:camera animated:YES completion:nil];
    }
}

+ (void)setLocalCacheFolder:(NSString *)path{
    localCacheFolder=path;
}

+ (NSString *)localCacheFolder{
    if(localCacheFolder==nil){
        NSString *TempDirectory = NSTemporaryDirectory();
        TempDirectory = [TempDirectory stringByAppendingString:@"/temp_images"];
        
        if(![[NSFileManager defaultManager]fileExistsAtPath:TempDirectory])
        {
            BOOL r = [[NSFileManager defaultManager]createDirectoryAtPath:TempDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            if(r)
            {
                NSLog(@"创建图片临时存放目录失败: %@", TempDirectory);
            }
        }
        localCacheFolder = TempDirectory;
    }
    return localCacheFolder;
}

+ (void)clearLocalImages{
    NSArray *files=[[NSFileManager defaultManager]contentsOfDirectoryAtPath:[self localCacheFolder] error:nil];
    for(NSString *path in files){
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    }
}

@end


