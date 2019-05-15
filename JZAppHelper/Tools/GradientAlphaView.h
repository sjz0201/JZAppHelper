//
//  GradientAlphaView.h
//  JZAppHelper
//
//  Created by sunjz on 2019/5/15.
//  Copyright © 2019 yiyangwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GradientAlphaView : UIView
- (instancetype)initWithFrame:(CGRect)frame leftColor:(UIColor *)leftcolor rightColor:(UIColor *)rightcolor;
- (instancetype)initWithFrame:(CGRect)frame topColor:(UIColor *)topcolor bottomColor:(UIColor *)botcolor;

//左下右上渐变色图片
+ (UIImage *)gradientImgFromColors:(NSArray *)colors withFrame:(CGRect)frame;
//图片添加文字（字体白色，居中）
+ (UIImage *)addText:(NSString*)text toImage:(UIImage*)image;
@end

NS_ASSUME_NONNULL_END
