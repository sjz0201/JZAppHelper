//
//  GTools.h
//  MyApp
//
//  Created by sunjz on 2018/10/31.
//  Copyright © 2018 caafc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#define GLocalized(key) NSLocalizedStringFromTable(key, @"GLocalized", nil)
#define GErrorDomain @"GErrorDomain"
//typedef NS_ENUM(NSInteger, GErrorCode) {
//    GForbidPermission,//不x允许
//    GFailueAuthorize,//授权失败
//    GUnsuportAuthorize,//不支持
//};
typedef NS_ENUM(NSInteger, GPermission){
    GPhotoLibrary,        // 相册
    GCamera,              // 相机
    GMicrophone,          // 麦克风
    GLocationAllows,      // 始终定位
    GLocationWhenInUse,   // 使用时定位
    GCalendars,           // 日历
    GReminders,           // 提醒事项
    GHealth,              // 健康更新
    GUserNotification,    // 通知
    GContacts,            // 通讯录
};

typedef NS_ENUM(NSInteger, GErrorCode) {
    GForbidPermission,
    GFailueAuthorize,
    GUnsuportAuthorize
};

typedef void(^GRequestResult)(BOOL granted, NSError *error);


@interface GAuthorityTools : NSObject

+(instancetype)shareManager;

/**
 *  判断权限是否存在
 *
 *  @param permission 权限类型
 *
 *  @return 权限是否存在
 */
- (BOOL)determinePermission:(GPermission)permission;

/**
 *  获得当前活动视图控制器
 *
 *  @return 当前活动视图控制器
 */
- (UIViewController *)currentViewController;

/**
 *  权限是否存在,如果权限不存在则请求权限
 *
 *  @param permission  权限类型
 *  @param result      请求结果
 */
- (void)requestPermission:(GPermission)permission
                ForResult:(GRequestResult)result;



@end

NS_ASSUME_NONNULL_END
