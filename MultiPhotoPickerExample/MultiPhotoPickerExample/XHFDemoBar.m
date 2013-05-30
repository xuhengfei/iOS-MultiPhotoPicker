//
//  XHFDemoBar.m
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-5-30.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import "XHFDemoBar.h"
#import "XHFSelectPhoto.h"

@implementation XHFDemoBar

-(id)init{
    self=[super initWithFrame:CGRectMake(10, 250, 300, 50)];
    if(self){
        _buttons=[[NSMutableArray alloc] initWithCapacity:5];
        
        for(int i=0;i<5;i++){
            UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag=i;
            [btn setBackgroundColor:[UIColor grayColor]];
            [btn setFrame:CGRectMake((i+1)*45, 0, 40, 40)];
            
            [_buttons addObject:btn];
            [self addSubview:btn];
        }

    }
    return self;
}

- (void)refreshButtons:(NSArray *)photos{
    for(int i=0;i<[self.buttons count];i++){
        
        UIButton *btn=[self.buttons objectAtIndex:i];
        if([photos count]>i){
            XHFSelectPhoto *p=[photos objectAtIndex:i];
            [btn setImage:p.thumbnail forState:UIControlStateNormal];
        }else{
            [btn setImage:nil forState:UIControlStateNormal];
        }
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
