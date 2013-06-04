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

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    
	_scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    for(int i=0;i<[_photos count];i++){
        XHFSelectPhoto *p=[_photos objectAtIndex:i];
        UIImageView *image=[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:p.localPath]];
        image.frame=CGRectMake((SCREEN_WIDTH*i), 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        image.tag=i;
        [_scrollView addSubview:image];
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
    
//    UIView *toolbarView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-58, SCREEN_WIDTH, 58)];
//    UIImageView *toolbarGBView=[[UIImageView alloc] initWithFrame:toolbarView.bounds];
//    toolbarGBView.image=[[UIImage imageNamed:@"camera_toolBar_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//    [toolbarView addSubview:toolbarGBView];
    
    _cancelButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera_back_btn.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClick)];
    
    _deleteButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteClick)];//[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    _deleteButton=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteClick)];
//    _deleteButton.frame=CGRectMake(toolbarView.bounds.size.width/2-20-26, 10, 40, 40);
//    [_deleteButton addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
//    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    
    _okButton=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"camera_ok_btn.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
//    _okButton.frame=CGRectMake(toolbarView.bounds.size.width-20-26, 10, 40, 40);
//    [_okButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
//    [_okButton setImage:[UIImage imageNamed:@"camera_ok_btn.png"] forState:UIControlStateNormal];
//    [_okButton setImage:[UIImage imageNamed:@"camera_ok_btn_highlight.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *flexItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flexItem2=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:_cancelButton,flexItem,_deleteButton,flexItem2,_okButton, nil]];
    
    [self.view addSubview:toolbar];
}

-(void)removePhotoAtIndex:(int)index{
    BOOL isLast=([_photos count]-1==index);
    [_photos removeObjectAtIndex:index];
    if([_photos count]==0){
        [self dismiss];
        return;
    }
    for(id sub in _scrollView.subviews){
        if([sub isKindOfClass:[UIImageView class]]){
            UIImageView *view=(UIImageView *)sub;
            int tag=view.tag;
            if(tag==index){
                [view removeFromSuperview];
            }else if(tag>index){
                CGRect oldFrame=view.frame;
                view.frame=CGRectMake(oldFrame.origin.x-320, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
            }
        }
    }
    int current=(isLast?(index-1):index);
    _scrollView.contentSize=CGSizeMake(SCREEN_WIDTH*[_photos count], SCREEN_HEIGHT);
    [_scrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH*current, 0, SCREEN_WIDTH, SCREEN_HEIGHT) animated:YES];
    [_pageControl setNumberOfPages:[_photos count]];
    [_pageControl setCurrentPage:current];
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
