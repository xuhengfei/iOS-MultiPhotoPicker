iOS-MultiPhotoPicker
====================

iPhone上的多图拾取器，同时支持从相册勾选和摄像头拍摄  

Quick Start  

1.导入XHFMultiPhotoPicker目录下的所有文件  
2.在工程中引入AssetsLibrary.framework AVFoundation.framework  
3.编写代码，示例如下： 
```objective-c
//XHFPhotoPicker 中的核心静态方法
//type可选为从相册获取，从摄像头获取，或者交由用户选择
//vc表示当前的UIViewController
//ResultBlock为选择完成后的回调Block，返回一个数组，内含XHFSelectPhoto对象
+(void)pickWithType:(SOURCE_TYPE)type InitPhotos:(NSArray *)photos ViewController:(UIViewController *)vc ResultBlock:(XHFResultBlock)resultBlock;  
//从相册多选照片
[XHFPhotoPicker pickWithType:ALBUM InitPhotos:self.photos ViewController: self ResultBlock:_resultBlock];
//从摄像头获取
[XHFPhotoPicker pickWithType:CAMERA InitPhotos:self.photos ViewController:self ResultBlock:_resultBlock];
//交由用户选择
[XHFPhotoPicker pickWithType:USER_SELECT InitPhotos:self.photos ViewController:self ResultBlock:_resultBlock];

//在使用之前最好先设置一下图片的临时存放路径
[XHFPhotoPicker setLocalCacheFolder:@"path"];
//使用完后，清除图片文件夹
[XHFPhotoPicker clearLocalImages];

```

MultiPhotoPickerExample中有demo工程，可以试用


求设计师！  
因为这个组件没有设计师，界面不够好看。  
有哪位设计师愿意支持一下的，欢迎联系 QQ:82950408  
我们一起把这个组件做的漂亮一点  