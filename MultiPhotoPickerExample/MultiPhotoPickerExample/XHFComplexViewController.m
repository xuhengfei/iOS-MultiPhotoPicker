//
//  XHFComplexViewController.m
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-5-31.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import "XHFComplexViewController.h"
#import "XHFComplexBar.h"

@interface XHFComplexViewController ()

@end

@implementation XHFComplexViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor=[UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    XHFComplexBar *bar1=[[XHFComplexBar alloc]initWithFrame:CGRectMake(10, 100, 300, 60) andID:@"1" andViewController:self];
    
    XHFComplexBar *bar2=[[XHFComplexBar alloc]initWithFrame:CGRectMake(10, 200, 300, 60) andID:@"2" andViewController:self];
    
    [self.view addSubview:bar1];
    [self.view addSubview:bar2];
}

@end
