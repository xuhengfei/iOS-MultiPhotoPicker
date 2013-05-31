//
//  XHFThumbnailBar.m
//  Photo
//
//  Created by 周方 on 13-5-29.
//  Copyright (c) 2013年 周方. All rights reserved.
//

#import "XHFThumbnailBar.h"
#import "XHFSelectPhoto.h"
#import <QuartzCore/QuartzCore.h>

@implementation XHFThumbnailBar{
    NSArray *_photos;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    for(UIView *view in [self subviews]){
        if([view isKindOfClass:[UIView class]]){
            [view removeFromSuperview];
        }
    }
    for(int i=0;i<MAX_PHOTO_COUNT;i++){
        CGRect rectV=CGRectMake(11.3*(i+1)+(50*i), 0, 50, 50);
        UIView *rectView=[[UIView alloc]initWithFrame:rectV];
        rectView.tag=i;
        
        UIImageView *thumbnailView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
        thumbnailView.backgroundColor=[UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
        thumbnailView.layer.borderColor=[[UIColor whiteColor]CGColor];
        thumbnailView.layer.borderWidth=1.0;
        thumbnailView.userInteractionEnabled=YES;
        
        
        //红X
        UIImageView *redx=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"delete.jpeg"]];
        redx.frame=CGRectMake(30, 0, 10, 10);
        redx.hidden=YES;
        redx.userInteractionEnabled=YES;
        redx.tag=i;
        
        if(_photos!=nil && [_photos count]>i){
            XHFSelectPhoto *p=[_photos objectAtIndex:i];
            thumbnailView.image=p.thumbnail;
            
            if(p.status==0){
                redx.hidden=NO;
                UITapGestureRecognizer *redxTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRedx:)];
                [redx addGestureRecognizer:redxTap];
            }else{
                redx.hidden=YES;
            }
        }
        [rectView addSubview:thumbnailView];
        [rectView addSubview:redx];
        
        [self addSubview:rectView];
        
        
    }
}

- (void)tapRedx:(UITapGestureRecognizer *)sender{
    if(self.removeBlock!=nil){
        NSInteger index= sender.view.tag;
        self.removeBlock([_photos objectAtIndex:index]);
    }
}

- (void)redrawWithSelectPhotos:(NSArray *)photos{
    _photos=photos;
    [self setNeedsDisplay];
}

@end
