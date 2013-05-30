iOS-MultiPhotoPicker
====================

iPhone上的多图拾取器，同时支持从相册勾选和摄像头拍摄  

Quick Start  

1.导入MultiPhotoPicker目录下的所有文件  
2.在工程中引入AssetsLibrary.framework AVFoundation.framework  
3.编写代码，示例如下： 
```objective-c
//XHFPhotoPicker 中的核心静态方法
//type可选为从相册获取，从摄像头获取，或者交由用户选择
//vc表示当前的UIViewController
//ResultBlock为选择完成后的回调Block，返回一个数组，内含XHFSelectPhoto对象
+(void)showWithType:(SOURCE_TYPE)type InitPhotos:(NSArray *)photos ViewController:(UIViewController *)vc ResultBlock:(XHFResultBlock)resultBlock;  
//从相册多选照片
[XHFPhotoPicker showWithType:ALBUM InitPhotos:self.photos ViewController: self ResultBlock:_resultBlock];
//从摄像头获取
[XHFPhotoPicker showWithType:CAMERA InitPhotos:self.photos ViewController:self ResultBlock:_resultBlock];
//交由用户选择
[XHFPhotoPicker showWithType:USER_SELECT InitPhotos:self.photos ViewController:self ResultBlock:_resultBlock];
```

MultiPhotoPickerExample中有demo工程，可以试用
