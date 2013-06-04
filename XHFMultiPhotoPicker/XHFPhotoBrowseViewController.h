//
//  XHFPhotoBrowseViewController.h
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-6-3.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHFSelectPhoto.h"
#import "XHFMultiPhotoPicker.h"

@interface XHFPhotoBrowseViewController : UIViewController<UIScrollViewDelegate>


@property (nonatomic,readonly) UIScrollView *scrollView;

-(id)initWithPhotos:(NSArray *)photos andIndex:(int)index andReturnBlock:(XHFResultBlock)block;

@end
