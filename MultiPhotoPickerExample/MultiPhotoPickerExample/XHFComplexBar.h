//
//  XHFComplexBar.h
//  MultiPhotoPickerExample
//
//  Created by 周方 on 13-5-31.
//  Copyright (c) 2013年 xuhengfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHFComplexBar : UIView

@property (nonatomic,strong,readonly) NSString *ID;

@property (nonatomic,strong,readonly)NSMutableArray *buttons;



-(id)initWithFrame:(CGRect)frame andID:(NSString *)ID andViewController:(UIViewController *)vc;


@end
