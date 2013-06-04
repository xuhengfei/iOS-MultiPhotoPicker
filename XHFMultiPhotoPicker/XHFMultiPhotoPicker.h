//
//  MultiPhotoPicker.h
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-5-31.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHFSelectPhoto.h"

typedef void (^XHFBlock) ();

typedef void (^XHFResultBlock)(NSArray *);

typedef void (^XHFPhotoBlock)(XHFSelectPhoto *);

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height-20

#define MAX_PHOTO_COUNT 5

typedef enum {
    ALBUM=1,
    CAMERA,
    USER_SELECT
}SOURCE_TYPE;



@interface XHFMultiPhotoPicker : NSObject

+ (void)setLocalCacheFolder:(NSString *)path;

+ (NSString *)localCacheFolder;

+(void)pickWithType:(SOURCE_TYPE)type InitPhotos:(NSArray *)photos ViewController:(UIViewController *)vc ResultBlock:(XHFResultBlock)resultBlock;

//清除存放临时图片文件的文件夹
+(void)clearLocalImages;

@end