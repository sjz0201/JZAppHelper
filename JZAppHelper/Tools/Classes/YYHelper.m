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
    [SVProgressHUD setMinimumDismissTimeInterval:1.2];
    [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"call_speaker"]];
    [SVProgressHUD showSuccessWithStatus:text];
}
@end
