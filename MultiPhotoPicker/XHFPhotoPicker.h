//
//  XHFPhotoPicker.h
//  Photo
//
//  Created by 周方 on 13-5-28.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHFDefine.h"



@interface XHFPhotoPicker : NSObject

+(void)showWithType:(SOURCE_TYPE)type InitPhotos:(NSArray *)photos ViewController:(UIViewController *)vc ResultBlock:(XHFResultBlock)resultBlock;

@end
