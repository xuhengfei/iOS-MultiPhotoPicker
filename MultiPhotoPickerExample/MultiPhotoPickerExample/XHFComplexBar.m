//
//  XHFComplexBar.m
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-5-31.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import "XHFComplexBar.h"
#import "XHFSelectPhoto.h"
#import "XHFMultiPhotoPicker.h"

@implementation XHFComplexBar{
    UIViewController *_vc;
    NSMutableArray *_photos;
    UIButton *_add;
}

- (id)initWithFrame:(CGRect)frame andID:(NSString *)ID andViewController:(UIViewController *)vc{
    self=[super initWithFrame:frame];
    if(self){
        _ID=ID;
        _vc=vc;
        
        _photos=[self getPhotosFromLastUpdate];
        if(_photos==nil){
            _photos=[[NSMutableArray alloc]init];
        }
        
        _add=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_add setTitle:@"+" forState:UIControlStateNormal];
        _add.frame=CGRectMake(0, 0, 40, 40);
        [_add addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_add];
        
        _buttons=[[NSMutableArray alloc] initWithCapacity:5];
        
        for(int i=0;i<5;i++){
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag=i;
            [btn setBackgroundColor:[UIColor grayColor]];
            [btn setFrame:CGRectMake((i+1)*45, 0, 40, 40)];
            
            [_buttons addObject:btn];
            [self addSubview:btn];
        }
        
        [self refreshButtons];

    }
    return  self;
}

-(void)addButtonClick{
    [XHFMultiPhotoPicker pickWithType:USER_SELECT InitPhotos:_photos ViewController:_vc ResultBlock:^(NSArray *photos){
        _photos=[[NSMutableArray alloc]initWithArray:photos];
        [self refreshButtons];
        [self persistentPhotosToLocal];
    }];
}

- (void)refreshButtons{
    for(int i=0;i<[self.buttons count];i++){
        
        UIButton *btn=[self.buttons objectAtIndex:i];
        if([_photos count]>i){
            XHFSelectPhoto *p=[_photos objectAtIndex:i];
            [btn setImage:p.thumbnail forState:UIControlStateNormal];
        }else{
            [btn setImage:nil forState:UIControlStateNormal];
        }
    }
}
//从本地文件中读取
//{id:[{localpath:'',url:''},{}]}
-(NSMutableArray *)getPhotosFromLastUpdate{
    NSMutableArray *ret=[[NSMutableArray alloc]init];
    NSString *path=[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/pick_photos_config.json"];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSData *data=[[NSData alloc]initWithContentsOfFile:path];
        NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSArray *photos=[dict objectForKey:_ID];
        if(photos!=nil){
            for(NSDictionary *p in photos){
                
                UIImage *thumbnail=[XHFSelectPhoto loadLocalThumbnail:[p objectForKey:@"localpath"]];
                if(thumbnail==nil){
                    break;
                }
                XHFSelectPhoto *sp=[[XHFSelectPhoto alloc]init];
                sp.localPath=[p objectForKey:@"localpath"];
                sp.thumbnail=thumbnail;
                sp.urlPath=[p objectForKey:@"url"];
                if(sp.urlPath!=nil){
                    sp.status=2;
                }else{
                    sp.status=-1;
                }
                [ret addObject:sp];
            }
        }
    }
    return ret;
}
//将信息持久化到本地
-(void)persistentPhotosToLocal{
    if([_photos count]==0){
        return;
    }
    NSMutableArray *my=[[NSMutableArray alloc]init];
    for(XHFSelectPhoto *p in _photos){
        NSMutableDictionary *d=[[NSMutableDictionary alloc]init];
        [d setObject:p.localPath forKey:@"localpath"];
        if(p.urlPath!=nil){
            [d setObject:p.urlPath forKey:@"url"];
        }
        [my addObject:d];
    }
    
    
    NSString *path=[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/pick_photos_config.json"];
    NSMutableDictionary *ret=[[NSMutableDictionary alloc]init];
    if([[NSFileManager defaultManager]fileExistsAtPath:path]){
        NSData *data=[[NSData alloc]initWithContentsOfFile:path];
        ret=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        ret=[[NSMutableDictionary alloc]initWithDictionary:ret];
    }
    
    [ret setObject:my forKey:_ID];
    
    if([NSJSONSerialization isValidJSONObject:ret]){
        NSData *data=[NSJSONSerialization dataWithJSONObject:ret options:NSJSONWritingPrettyPrinted error:nil];
        [data writeToFile:path atomically:YES];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
