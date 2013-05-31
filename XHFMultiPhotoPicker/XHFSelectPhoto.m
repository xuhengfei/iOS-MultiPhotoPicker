//
//  XHFSelectPhoto.m
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import "XHFSelectPhoto.h"

static NSString *localCacheFolder;

@implementation XHFSelectPhoto

+ (void)setLocalCacheFolder:(NSString *)path{
    localCacheFolder=path;
}

+ (NSString *)localCacheFolder{
    if(localCacheFolder==nil){
        return [[NSBundle mainBundle] bundlePath];
    }
    return localCacheFolder;
}

+ (UIImage *)loadLocalThumbnail:(NSString *)localpath{
    if([[NSFileManager defaultManager] fileExistsAtPath:localpath]){
            
        UIImage *originImage=[[UIImage alloc] initWithContentsOfFile:localpath];
        UIGraphicsBeginImageContext(CGSizeMake(originImage.size.width*0.5f, originImage.size.height*0.5f));
        [originImage drawInRect:CGRectMake(0, 0, originImage.size.width*0.5f, originImage.size.height*0.5f)];
            
        UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
            
        return image;
    }
    return nil;
}

@end
