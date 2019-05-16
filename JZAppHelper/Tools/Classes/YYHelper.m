//
//  YYHelper.m
//  JZAppHelper
//
//  Created by sunjz on 2019/5/15.
//  Copyright © 2019 yiyangwang. All rights reserved.
//

#import "YYHelper.h"
#import "SVProgressHUD.h"
@implementation YYHelper
+(void)showSuccessWithText:(NSString *)text{
    //设置显示时间
    
    
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
   UIImage *image = [UIImage imageNamed:@"call_speaker" inBundle:bundle compatibleWithTraitCollection:nil];
//    UIImage *infoImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"call_speaker" ofType:@"png"]];
    [SVProgressHUD setMinimumDismissTimeInterval:1.2];
    [SVProgressHUD setSuccessImage:image];
    [SVProgressHUD showSuccessWithStatus:text];
}
@end
