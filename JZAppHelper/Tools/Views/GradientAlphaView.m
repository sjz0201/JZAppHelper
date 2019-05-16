//
//  GradientAlphaView.m
//  JZAppHelper
//
//  Created by sunjz on 2019/5/15.
//  Copyright © 2019 yiyangwang. All rights reserved.
//

#import "GradientAlphaView.h"

@implementation GradientAlphaView

- (instancetype)initWithFrame:(CGRect)frame leftColor:(UIColor *)leftcolor rightColor:(UIColor *)rightcolor{
    self = [super initWithFrame:frame];
    if (self) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)leftcolor.CGColor, (__bridge id)rightcolor.CGColor];
        gradientLayer.locations = @[@0, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1.0, 0);
        gradientLayer.frame = self.bounds;
        [self.layer addSublayer:gradientLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame topColor:(UIColor *)topcolor bottomColor:(UIColor *)botcolor{
    self = [super initWithFrame:frame];
    if (self) {
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)topcolor.CGColor, (__bridge id)botcolor.CGColor];
        gradientLayer.locations = @[@0, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        gradientLayer.frame = self.bounds;
        [self.layer addSublayer:gradientLayer];
    }
    return self;
}

//左下右上渐变色图片
+ (UIImage *)gradientImgFromColors:(NSArray *)colors withFrame:(CGRect)frame{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    
    start = CGPointMake(0.0, frame.size.height);
    end = CGPointMake(frame.size.width, 0.0);
    
    CGContextDrawLinearGradient(context, gradient, start, end,kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)addText:(NSString*)text toImage:(UIImage*)image{
    //设置字体样式
    UIFont * font = [UIFont systemFontOfSize:35];
    NSDictionary * dict = @{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor whiteColor]};
    CGSize textSize = [text sizeWithAttributes:dict];
    
    //绘制上下文
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0, image.size.width, image.size.height)];
    CGRect fram = CGRectMake((image.size.width-textSize.width)/2, (image.size.height-textSize.height)/2, textSize.width, textSize.height);
    
    //此方法必须写在上下文才生效
    [text drawInRect:fram withAttributes:dict];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
