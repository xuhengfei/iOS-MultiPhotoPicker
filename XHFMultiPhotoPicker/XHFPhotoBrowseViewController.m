//
//  XHFPhotoBrowseViewController.m
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-6-3.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import "XHFPhotoBrowseViewController.h"
#import "XHFMultiPhotoPicker.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+FixOrientation.h"

@interface XHFPhotoBrowseViewController ()

@end

@implementation XHFPhotoBrowseViewController{
    NSArray *_originPhotos;//最初传进来的原始数据
    NSMutableArray *_photos;
    XHFResultBlock _returnBlock;
    UIPageControl *_pageControl;
    int _index;
    
    UIBarButtonItem *_cancelButton;
    UIBarButtonItem *_deleteButton;
    UIBarButtonItem *_okButton;
}

-(id)initWithPhotos:(NSArray *)photos andIndex:(int)index andReturnBlock:(XHFResultBlock)block{
    self=[super init];
    if(self){
        _returnBlock=block;
        _index=index;
        _originPhotos=[[NSArray alloc]initWithArray:photos];
        _photos=[[NSMutableArray alloc]initWithArray:photos];
    }
    return self;
}
//图片数据预加载
-(UIImage *)imageWarmup:(UIImage *)image{
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(image.size, YES, 0);
    else
        UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return ret;
}
//从文件路径加载图片
-(UIImageView *)loadImageView:(UIImage *)img{
    UIImageView *image=[[UIImageView alloc]initWithImage:img];
    float rate=img.size.height/img.size.width;
    float standard=SCREEN_HEIGHT*1.0f/SCREEN_WIDTH;
    if(rate<standard){//太扁了
        float height=rate*SCREEN_HEIGHT;
        image.frame=CGRectMake(0, (SCREEN_HEIGHT-height)/2, SCREEN_WIDTH, height);
    }else{
        float width=rate*SCREEN_WIDTH;
        image.frame=CGRectMake((SCREEN_WIDTH-width)/2, 0, width, SCREEN_HEIGHT);
    }
    
    return image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    dispatch_queue_t queue=dispatch_queue_create("XHFMultiPhotoPicker.XHFPhotoBrowseViewController",NULL);
    
	_scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _scrollView.showsHorizontalScrollIndicator=NO;
    _scrollView.showsVerticalScrollIndicator=NO;
    
    for(int i=0;i<[_photos count];i++){
        __block XHFSelectPhoto *p=[_photos objectAtIndex:i];
        
        UIImage *real=nil;
        if(p.localPath!=nil){
            real=[UIImage imageWithContentsOfFile:p.localPath];
        }else if(p.thumbnail!=nil){
            real=p.thumbnail;
        }
        if(real==nil){
            continue;
        }
        
        UIView *view=[[UIView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH*i), 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        UIImageView *image=[self loadImageView:real];
        
        [view addSubview:image];
//        dispatch_async(queue, ^{
//            NSLog(@"start index:%@",p.thumbnail);
//            if(p.localPath!=nil){
//                UIImageView *imageView=[self loadImageView:[self imageWarmup:[UIImage imageWithContentsOfFile:p.localPath]]];
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [image removeFromSuperview];
//                    [view addSubview:imageView];
//                });
//            }else{
//                [p addNotifyListener:^BOOL(XHFSelectPhoto *p) {
//                    
//                    if(p.localPath==nil){
//                        return NO;
//                    }
//                    dispatch_async(queue, ^{
//                        UIImageView *imageView=[self loadImageView:[self imageWarmup:[UIImage imageWithContentsOfFile:p.localPath]]];
//                        dispatch_sync(dispatch_get_main_queue(), ^{
//                            [image removeFromSuperview];
//                            [view addSubview:imageView];
//                        });
//                    });
//                    return YES;
//                }];
//                
//            }
//            NSLog(@"end index:%@",p.thumbnail);
//        });
        view.tag=i;
        [_scrollView addSubview:view];
    }                                                                                                                 
    _scrollView.backgroundColor=[UIColor grayColor];
    _scrollView.contentSize=CGSizeMake(SCREEN_WIDTH*([_photos count]), SCREEN_HEIGHT);
    _scrollView.contentOffset=CGPointMake(0, 0);
    _scrollView.pagingEnabled=YES;
    _scrollView.delegate=self;
    [_scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH*_index, 0, SCREEN_WIDTH, SCREEN_HEIGHT) animated:NO];
    
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 380, SCREEN_WIDTH, 10)];
    [_pageControl setNumberOfPages:[_photos count]];
    [_pageControl setCurrentPage:_index];
    [_pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_scrollView];
    [self.view addSubview:_pageControl];
    
    //配置ToolBar
    UIToolbar *toolbar=[[UIToolbar alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-44, SCREEN_WIDTH, 44)];
    toolbar.barStyle=UIBarStyleBlack;
    toolbar.translucent=YES;
    
    
    _cancelButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera_back_btn.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClick)];
    
    _deleteButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteClick)];

    
    _okButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera_ok_btn.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
    
    UIBarButtonItem *flexItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexItem2=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:_cancelButton,flexItem,_deleteButton,flexItem2,_okButton, nil]];
    
    [self.view addSubview:toolbar];
}

-(void)removePhotoAtIndex:(int)index{
    BOOL isLast=([_photos count]-1==index);
    if([_photos count]==1){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"确认删除" message:@"已经是最后一张图片了，确认删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    [_photos removeObjectAtIndex:index];
    if([_photos count]==0){
        [self dismiss];
        return;
    }
    for(id sub in _scrollView.subviews){
        if([sub isKindOfClass:[UIView class]]){
            UIView *view=(UIView *)sub;
            int tag=view.tag;
            if(tag==index){
                [view removeFromSuperview];
            }else if(tag>index){
                CGRect oldFrame=view.frame;
                view.frame=CGRectMake(oldFrame.origin.x-320, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
                view.tag--;
            }
        }
    }
    int current=(isLast?(index-1):index);
    _scrollView.contentSize=CGSizeMake(SCREEN_WIDTH*[_photos count], SCREEN_HEIGHT);
    
    [_scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH*current, 0, SCREEN_WIDTH, SCREEN_HEIGHT) animated:YES];
    [_pageControl setNumberOfPages:[_photos count]];
    [_pageControl setCurrentPage:current];
}
//删除最后一张照片时的确认操作
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"]){
        [_photos removeObjectAtIndex:0];
        [self dismiss];
    }
}

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(_returnBlock!=nil){
        _returnBlock(_photos);
    }
}

-(void)cancelClick{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(_returnBlock!=nil){
        _returnBlock(_originPhotos);
    }
}
-(void)deleteClick{
    [self removePhotoAtIndex:[_pageControl currentPage]];
}

-(void)changePage:(id)sender{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_pageControl setCurrentPage:fabs(_scrollView.contentOffset.x/self.view.frame.size.width)];
    
}

@end
