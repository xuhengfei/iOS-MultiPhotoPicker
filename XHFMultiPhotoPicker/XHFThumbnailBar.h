//
//  XHFThumbnailBar.h
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHFMultiPhotoPicker.h"


@interface XHFThumbnailBar : UIView
//当点击删除按钮时会触发的block
@property (nonatomic,copy) XHFPhotoBlock removeBlock;

@property (nonatomic,copy) void(^BrowseBlock)(int index);

- (void) redrawWithSelectPhotos:(NSArray *)photos;

@end
