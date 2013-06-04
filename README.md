iOS-MultiPhotoPicker
====================

iPhone上的多图拾取器，同时支持从相册勾选和摄像头拍摄  

<img src="http://xuhengfei.com/assets/images/multiphotopicker/snapshot1.jpg" width="320px" height="480px"/>
&nbsp;&nbsp;
<img src="http://xuhengfei.com/assets/images/multiphotopicker/snapshot2.jpg" width="320px" height="480px"/>

Quick Start  

1.导入XHFMultiPhotoPicker目录下的所有文件  
2.在工程中引入AssetsLibrary.framework AVFoundation.framework  
3.编写代码，示例如下： 
```objective-c

-(void)viewDidLoad{
  //设置临时文件夹，用来保存用户选择的图片(也可以不设置，有默认值)
  [XHFMultiPhotoPicker setLocalCacheFolder:@"path"];
  //弹出照片选择组件，有4个参数，分别是：
  //Type:USER_SELECT 表示用户自己来选择拍照还是相册 (也可以使用其他2个参数：ALBUM  CAMERA)
  //InitPhotos:self.photos 用户已经选中的照片(传入nil表示还没有选中的图片)
  //ViewController: 当前的UIViewController
  //ResultBlock: 用户选择完成后，返回选中的照片数组
  [XHFMultiPhotoPicker pickWithType:USER_SELECT InitPhotos:nil ViewController:self ResultBlock:^(NSArray *photos){
    //返回用户选中的照片Array
    for(XHFSelectPhoto *p in photos){
      NSLog(@"photo local path:%@",p.localPath);
    }
    //do something
    //清除临时照片文件
    [XHFMultiPhotoPicker clearLocalImages];
  }];
  
}


```

MultiPhotoPickerExample中有demo工程，可以试用


求设计师！  
因为这个组件没有设计师，界面不够好看。  
有哪位设计师愿意支持一下的，欢迎联系 QQ:82950408  
我们一起把这个组件做的漂亮一点  
