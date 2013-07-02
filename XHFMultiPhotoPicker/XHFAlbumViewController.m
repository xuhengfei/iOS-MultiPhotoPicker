//
//  XHFAlbumViewController.m
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "XHFThumbnailBar.h"
#import "XHFAlbumViewController.h"
#import "XHFMultiPhotoPicker.h"
#import "XHFPhotoBrowseViewController.h"
#import "UIImage+FixOrientation.h"

@implementation XHFAlbumViewController{
    @public
    NSMutableArray *_photos;
}

- (id)initWithInitPhotos:(NSArray *)photos{
    self=[super init];
    if(self){
        _photos=[[NSMutableArray alloc]initWithArray:photos];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    XHFAlbumSelectViewController *c=[[XHFAlbumSelectViewController alloc]init];
    [self pushViewController:c animated:YES];
}


- (void)cancelSelect{
    NSArray *array=[[NSArray alloc]initWithArray:_photos];
    for(int i=0;i<[array count];i++){
        XHFSelectPhoto *p=[array objectAtIndex:i];
        if(p.status==0){
            NSString *path=p.localPath;
            if( [path hasPrefix:[[NSBundle mainBundle] bundlePath]]){
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            [_photos removeObject:p];
        }
    }
}

@end

@implementation XHFAlbumSelectViewController{
    UITableView *_tableView;
    NSMutableArray *_assetsGroup;

}
- (id)init{
    self=[super init];
    if(self){
        _assetsGroup=[[NSMutableArray alloc] init];
        [self loadAssetsGroup];
        
        _tableView=[[UITableView alloc]init];
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_tableView];
    }
    return self;
}

- (void)viewDidLoad{
    UIBarButtonItem *cancel=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.leftBarButtonItem=cancel;
}
#pragma mark button click
- (void)cancelAction:(id)sender{
    XHFAlbumViewController *nav=(XHFAlbumViewController *)self.navigationController;
    [nav cancelSelect];
    [self dismissViewControllerAnimated:YES completion:nil];
    if(nav.resultBlock!=nil){
        nav.resultBlock(nav->_photos);
    }
}
#pragma mark TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_assetsGroup count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier=@"Cell";
    UITableViewCell *cell=[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    ALAssetsGroup *group=[_assetsGroup objectAtIndex:indexPath.row];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSUInteger numberOfAsstes=group.numberOfAssets;
    
    cell.textLabel.text=[NSString stringWithFormat:@"%@",[group valueForProperty:ALAssetsGroupPropertyName]];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%d",numberOfAsstes];
    [cell.imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)[_assetsGroup objectAtIndex:indexPath.row] posterImage]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 57;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    ALAssetsGroup *group=[_assetsGroup objectAtIndex:indexPath.row];
    XHFMultiSelectViewController *c=[[XHFMultiSelectViewController alloc]initWithAssetsGroup:group];
    //[self setNavigationBarHidden:YES];
    XHFAlbumViewController *nav=(XHFAlbumViewController *)self.navigationController;
    [nav pushViewController:c animated:YES];
}
#pragma mark 私有方法
- (void)loadAssetsGroup{
    [_assetsGroup removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        void (^assetsGroupEnumerator)(ALAssetsGroup *,BOOL *)=^(ALAssetsGroup *group,BOOL *stop){
            if(group!=nil){
                [_assetsGroup addObject:group];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            }
        };
        ALAssetsLibrary *assetsLibrary=[self defaultAssetsLibrary];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:assetsGroupEnumerator failureBlock:nil];
    });
}
- (ALAssetsLibrary *)defaultAssetsLibrary
{
    static ALAssetsLibrary *assetsLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        // Workaround for triggering ALAssetsLibraryChangedNotification
        [assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) { }];
    });
    
    return assetsLibrary;
}

@end

@implementation XHFMultiSelectViewController{
    ALAssetsGroup *_assetsGroup;
    NSMutableArray *_assets;
    UITableView *_tableView;
    XHFThumbnailBar *_thumbnailBar;
}

- (id)initWithAssetsGroup:(ALAssetsGroup *)group{
    self=[super init];
    if(self){
        _assetsGroup=group;
        [self loadAsstes];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    UIBarButtonItem *done=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem=done;
    self.view.backgroundColor=[UIColor grayColor];
    
    //配置TableView
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tableView.backgroundColor=[UIColor clearColor];
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight;
    [_tableView setSeparatorColor:[UIColor clearColor]];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    
    //toolbar
    UIImageView *toolbarView=[[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-58-44, SCREEN_WIDTH, 58)];
    toolbarView.image=[[UIImage imageNamed:@"camera_toolBar_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //toolbarGBView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"camera_toolBar_pure_bg.png"]];
    [self.view addSubview:toolbarView];
    
    //配置5个小图区域
    CGRect thumb=CGRectMake(0, SCREEN_HEIGHT-50-44-1.0f, SCREEN_WIDTH, 50);
    _thumbnailBar=[[XHFThumbnailBar alloc]initWithFrame:thumb];
    __block __unsafe_unretained UITableView *tv=_tableView;
    __block __unsafe_unretained XHFAlbumViewController *blockNav=(XHFAlbumViewController *)self.navigationController;
    __block __unsafe_unretained XHFThumbnailBar *blockThumbnailBar=_thumbnailBar;
    _thumbnailBar.removeBlock=[^{
        [tv reloadData];
    } copy];
    _thumbnailBar.BrowseBlock=^(int index){
        XHFPhotoBrowseViewController *c=[[XHFPhotoBrowseViewController alloc]initWithPhotos:blockNav->_photos andIndex:index andReturnBlock:^(NSArray *photos){
            blockNav->_photos=[[NSMutableArray alloc]initWithArray:photos];
            [blockThumbnailBar redrawWithSelectPhotos:photos];
            [tv reloadData];
        }];
        [blockNav presentViewController:c animated:YES completion:nil];
    };
    XHFAlbumViewController *nav=(XHFAlbumViewController *)self.navigationController;
    [_thumbnailBar redrawWithSelectPhotos:nav->_photos];
    [self.view addSubview:_thumbnailBar];
}

#pragma mark click
- (void)doneAction:(id)sender{
    XHFAlbumViewController *nav=(XHFAlbumViewController *)self.navigationController;
    [self dismissViewControllerAnimated:YES completion:nil];
    if(nav.resultBlock!=nil){
        
        nav.resultBlock(nav->_photos);
        
    }
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    double number= _assetsGroup.numberOfAssets;
    NSInteger rows= ceil(number/4);
    return rows;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier=@"Cell";
    XHFMultiSelectTableCell *cell=[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell=[[XHFMultiSelectTableCell alloc]initWithItems:[self itemsForRowAtIndexPath:indexPath]reuseIdentifier:CellIdentifier];
    }else{
        cell.items=[self itemsForRowAtIndexPath:indexPath];
    }
    __block __unsafe_unretained XHFThumbnailBar *weakThumbnailBar=_thumbnailBar;
    __unsafe_unretained XHFAlbumViewController *nav=(XHFAlbumViewController *)self.navigationController;
    cell.clickBlock=^(XHFMultiSelectItem *item){
        if([nav->_photos count]<MAX_PHOTO_COUNT){
            if(!item.isSelected){
                XHFSelectPhoto *photo=[[XHFSelectPhoto alloc]init];
                photo.thumbnail=[UIImage imageWithCGImage:item.asset.thumbnail];
                photo.ref=item.asset.defaultRepresentation.url;
                [nav->_photos addObject:photo];
                [item makeSelect:YES];
                [weakThumbnailBar redrawWithSelectPhotos:[[NSArray alloc]initWithArray:nav->_photos]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
                    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
                    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];//转为字符型
                    
                    NSString *imgName=[timeString stringByAppendingString:@".jpg"];
                    NSString *path=[[XHFMultiPhotoPicker localCacheFolder] stringByAppendingPathComponent:imgName];
                    
                    //根据图像的方向，进行旋转
                    ALAssetRepresentation *rep= item.asset.defaultRepresentation;
                    UIImage *image=[UIImage imageWithCGImage:rep.fullResolutionImage scale:rep.scale orientation:rep.orientation];
                    
                    [UIImageJPEGRepresentation([image fixOrientation], 0) writeToFile:path atomically:YES];
                    photo.localPath=path;
                    [photo notify];
                });
                

            }

        }
    };
    cell.photos=nav->_photos;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

-(NSMutableArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *items=[[NSMutableArray alloc]initWithCapacity:4];
    NSUInteger startIndex=indexPath.row * 4;
    NSUInteger endIndex=startIndex+4-1;
    
    if (startIndex < _assets.count){
        if (endIndex > _assets.count - 1){
            endIndex = _assets.count - 1;
        }
        for (NSUInteger i = startIndex; i <= endIndex; i++){
            [items addObject:[_assets objectAtIndex:i]];
        }
    }
    return items;
}

#pragma mark 私有方法
- (void)loadAsstes{
    if(_assets==nil){
        _assets=[[NSMutableArray alloc]init];
    }
    [_assets removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @autoreleasepool {
            [_assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if(result!=nil){
                    [_assets addObject:result];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadData];
                    });
                }
            }];
        }
    });
}
@end

@implementation XHFMultiSelectTableCell{
}
-(id)initWithItems:(NSMutableArray *)items reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if(self){
        _items=items;
        self.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)layoutSubviews{
    for(int i=0;i<[_items count];i++){
        ALAsset *assert=[_items objectAtIndex:i];
        XHFMultiSelectItem *item=[[XHFMultiSelectItem alloc] initWithAsset:assert AndFrame:CGRectMake(75*i+12, 2, 71, 71)];
        UITapGestureRecognizer *recogizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellClick:)];
        [item addGestureRecognizer:recogizer];
        for(XHFSelectPhoto *p in self.photos){
            if(p.ref!=nil && [p.ref isEqual:assert.defaultRepresentation.url]){
                [item makeSelect:YES];
            }
        }
        
        [self addSubview:item];
    }
}
- (void)cellClick:(UITapGestureRecognizer *)sender{
    if(self.clickBlock!=nil){
        XHFMultiSelectItem *item=(XHFMultiSelectItem *)sender.view;
        self.clickBlock(item);
    }
}
@end

@implementation XHFMultiSelectItem{
    UIImageView *_imageView;
    UIView *_maskView;
}

-(id)initWithAsset:(ALAsset *)asset AndFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        _asset=asset;
        _imageView=[[UIImageView alloc]initWithImage:[UIImage imageWithCGImage:[asset thumbnail]]];
        _imageView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self addSubview:_imageView];
        
        _maskView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _maskView.backgroundColor=[UIColor whiteColor];
        _maskView.alpha=0.5f;
        _maskView.hidden=YES;
        
        [self addSubview:_maskView];
    }
    return self;

}

- (void)makeSelect:(BOOL)select{
    self.isSelected=select;
    if(select){
        _maskView.hidden=NO;
    }else{
        _maskView.hidden=YES;
    }
}

@end
