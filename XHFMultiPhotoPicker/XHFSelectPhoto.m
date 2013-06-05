//
//  XHFSelectPhoto.m
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "XHFSelectPhoto.h"



@implementation XHFSelectPhoto{
    NSMutableArray *_notifyArray;
}

- (void)addNotifyListener:(PhotoNotifyBlock)block{
    [_notifyArray addObject:block];
}

- (void)removeNotifyListener:(PhotoNotifyBlock)block{
    [_notifyArray removeObject:block];
}

- (void)notify{
    NSArray *array=[[NSArray alloc]initWithArray:_notifyArray];
    for(PhotoNotifyBlock block in array){
        if(block(self)){
            [_notifyArray removeObject:block];
        }
    }
}

-(id)init{
    self=[super init];
    _notifyArray=[[NSMutableArray alloc]init];
    return self;
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
