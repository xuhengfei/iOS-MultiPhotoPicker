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



@interface ActionSheetObject : NSObject  <UIActionSheetDelegate>

@property (nonatomic,strong) UIViewController *vc;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,copy) XHFResultBlock resultBlock;

@end
static ActionSheetObject *singleton;

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
        [XHFPhotoPicker pickWithType:CAMERA InitPhotos:self.photos ViewController:self.vc ResultBlock:self.resultBlock];
    }else if([str isEqualToString:@"相册"]){
        [XHFPhotoPicker pickWithType:ALBUM InitPhotos:self.photos ViewController:self.vc ResultBlock:self.resultBlock];
    }else{
        if(_resultBlock !=nil){
            _resultBlock(self.photos);
        }
    }
}


@end

@implementation XHFPhotoPicker

+ (void)pickWithType:(SOURCE_TYPE)type InitPhotos:(NSArray *)photos ViewController:(UIViewController *)vc ResultBlock:(XHFResultBlock)resultBlock{
    if(type==USER_SELECT){
        ActionSheetObject *object=[[ActionSheetObject alloc]init];
        object.vc=vc;
        object.photos=photos;
        object.resultBlock=resultBlock;
        UIActionSheet *sheet=[[UIActionSheet alloc] initWithTitle:@"选择照片来源" delegate:object cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"相册", nil];
        [sheet showInView:vc.view];
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

@end


