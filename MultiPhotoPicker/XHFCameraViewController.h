//
//  XHFCameraViewController.h
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHFDefine.h"

@interface XHFCameraViewController : UIViewController

@property (nonatomic,copy) void(^ReturnBlock)(NSArray *photos,SOURCE_TYPE type);

-(id)initWithInitPhotos:(NSArray *)photos;

@end
