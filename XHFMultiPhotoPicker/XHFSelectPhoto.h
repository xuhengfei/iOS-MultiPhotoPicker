//
//  XHFSelectPhoto.h
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "XHFMultiPhotoPicker.h"


@interface XHFSelectPhoto : NSObject
//本地文件路径
@property (nonatomic,strong) NSString *localPath;
//上传成功后的url地址
@property (nonatomic,strong) NSString *urlPath;
//用于小图预览的图片
@property (nonatomic,strong) UIImage *thumbnail;
//状态 -1：上传失败 0：无行为  1：上传中 2:上传成功
@property (nonatomic,assign) NSInteger status;
//可选参数，用于反向查找相册的图片
@property (nonatomic,strong) NSURL *ref;

typedef BOOL (^PhotoNotifyBlock)(XHFSelectPhoto *p);

-(void)addNotifyListener:(PhotoNotifyBlock) block;
-(void)removeNotifyListener:(PhotoNotifyBlock)block;
-(void)notify;

+ (UIImage *)loadLocalThumbnail:(NSString *)localpath;

@end
