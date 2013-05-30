//
//  XHFDemoBar.h
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-5-30.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHFDemoBar : UIView

@property (nonatomic,strong,readonly)NSMutableArray *buttons;

-(void)refreshButtons:(NSArray *)photos;

@end
