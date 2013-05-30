//
//  XHFDefine.h
//  Photo
//
//  Created by 周方 on 13-5-28.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHFSelectPhoto.h"

typedef void (^XHFBlock) ();

typedef void (^XHFResultBlock)(NSArray *);

typedef void (^XHFPhotoBlock)(XHFSelectPhoto *photo);

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height-20

#define MAX_PHOTO_COUNT 5

typedef enum {
    ALBUM=1,
    CAMERA,
    USER_SELECT
}SOURCE_TYPE;