//
//  XHFAlbumViewController.h
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "XHFDefine.h"
@class XHFMultiSelectItem;

@interface XHFAlbumViewController : UINavigationController

@property (nonatomic,copy) XHFResultBlock resultBlock;

- (id)initWithInitPhotos:(NSArray *)photos;

@end

@interface XHFAlbumSelectViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@end


@interface XHFMultiSelectViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
- (id)initWithAssetsGroup:(ALAssetsGroup *)group;
@end

@interface XHFMultiSelectTableCell : UITableViewCell

@property (nonatomic,strong) NSMutableArray *items;
@property (nonatomic,strong) NSArray *photos;
@property (nonatomic,copy) void(^clickBlock)(XHFMultiSelectItem *);

- (id)initWithItems:(NSMutableArray *)items reuseIdentifier:(NSString *)reuseIdentifier;

@end

@interface XHFMultiSelectItem : UIView
@property (nonatomic,strong,readonly) ALAsset *asset;
@property (nonatomic) BOOL isSelected;

-(id)initWithAsset:(ALAsset *)asset AndFrame:(CGRect)frame;

-(void)makeSelect:(BOOL)select;
@end