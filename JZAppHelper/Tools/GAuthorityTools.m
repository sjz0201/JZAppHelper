//
//  GTools.m
//  MyApp
//
//  Created by sunjz on 2018/10/31.
//  Copyright © 2018 caafc. All rights reserved.
//

#import "GAuthorityTools.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, GPermissionAuthorizationStatus) {
    GAuthorizationStatusNotDetermined,  // 第一次请求授权
    GAuthorizationStatusAuthorized,     // 已经授权成功
    GAuthorizationStatusForbid          // 非第一次请求授权
};

@interface GAuthorityTools ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, copy, nullable) GRequestResult locationResult;
@end

@implementation GAuthorityTools
+(instancetype)shareManager{
    static GAuthorityTools *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GAuthorityTools alloc] init];
    });
    return instance;
}

- (UIViewController *)currentViewController {
    UIViewController *currentVC = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWindow in windows) {
            if (tmpWindow.windowLevel == UIWindowLevelNormal) {
                window = tmpWindow;
                break;
            }
        }
    }
    
    UIView *frontV = [[window subviews] objectAtIndex:0];
    id nextReqoner = [frontV nextResponder];
    if ([nextReqoner isKindOfClass:[UIViewController class]]) {
        currentVC = nextReqoner;
    }else {
        currentVC = window.rootViewController;
    }
    return currentVC;
}

- (BOOL)determinePermission:(GPermission)permission {
    GPermissionAuthorizationStatus determine = [self authorizationPermission:permission];
    return determine == GAuthorizationStatusAuthorized;
}

- (void)requestPermission:(GPermission)permission
            ForResult:(GRequestResult)result {
    GPermissionAuthorizationStatus authorization = [self authorizationPermission:permission];
    if (result == nil) {
        result = ^(BOOL granted, NSError *error) {
        };;
    }
    switch (authorization) {
        case GAuthorizationStatusNotDetermined:
            // 第一次请求
            [self requestPermission:permission
                      requestResult:result];
            return;
            break;
        case GAuthorizationStatusForbid:
            // 之前请求过，现在禁了权限
            //
            self.locationResult = (permission == GLocationAllows) ||
            (permission == GLocationWhenInUse) ? result : nil;
            break;
        case GAuthorizationStatusAuthorized:
            // 已经授权
            //
            result(YES, nil);
            return;
            break;
    }
    __weak typeof(self) weakSelf = self;
    NSString *title = @"";
    NSString *description = @"";
    switch (permission) {
        case GCamera:{
            title = @"相机未授权";
            description = @"请到系统的“设置-隐私-相机”中授权此应用使用您的相机";
            break;
        }
        case GLocationAllows:{
            title = @"定位未授权";
            description = @"请到系统的“设置-隐私-定位”中授权此应用使用您的位置";
            break;
        }
        case GLocationWhenInUse:{
            title = @"相机未授权";
            description = @"请到系统的“设置-隐私-相机”中授权此应用使用您的相机";
            break;
        }
        case GCalendars:{
            title = @"日历未授权";
            description = @"请到系统的“设置-隐私-日历”中授权此应用使用您的日历";
            break;
        }
        case GReminders:{
            
            break;
        }
        case GUserNotification:{
           
            break;
        }
        case GPhotoLibrary:{
            title = @"相册未授权";
            description = @"请到系统的“设置-隐私-相册”中授权此应用使用您的相册";
            break;
        }
        case GMicrophone:{
            title = @"麦克风未授权";
            description = @"请到系统的“设置-隐私-麦克风”中授权此应用使用您的麦克风";
            break;
        }
        case GHealth:{
            title = @"健康未授权";
            description = @"请到系统的“设置-隐私-健康”中授权此应用使用您的健康";
            break;
        }
        case GContacts:{
            title = @"通讯录未授权";
            description = @"请到系统的“设置-隐私-通讯录”中授权此应用使用您的通讯录";
            break;
        }
    }
    
    
    
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:description
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"去设置"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                            if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                                                            }
                                                        });
                                                    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSError *error = [NSError errorWithDomain:GErrorDomain
                                                                                                code:GForbidPermission
                                                                                            userInfo:@{NSLocalizedDescriptionKey : GLocalized(@"Forbid permission")}];
                                                           result(NO,error);
                                                           weakSelf.locationResult = nil;
                                                       }];
    [alert addAction:cancel];
    [alert addAction:setting];
    
    UIViewController *currentVC = [self currentViewController];
    [currentVC presentViewController:alert
                            animated:YES
                          completion:nil];
}


/**************************************** 权 限 请 求 ****************************************/
- (void)requestPermission:(GPermission)permission
            requestResult:(GRequestResult)result{
    switch (permission) {
        case GCamera:{
            [self requestCamera:result];
            break;
        }
        case GLocationAllows:{
            [self requestLocationAllows:result];
            break;
        }
        case GLocationWhenInUse:{
            [self requestLocationWhenInUse:result];
            break;
        }
        case GCalendars:{
            [self requestCalendars:result];
            break;
        }
        case GReminders:{
            [self requestReminders:result];
            break;
        }
        case GUserNotification:{
            [self requestUserNotification:result];
            break;
        }
        case GPhotoLibrary:{
            [self requestPhotoLibrary:result];
            break;
        }
        case GMicrophone:{
            [self requestMicrophone:result];
            break;
        }
        case GHealth:{
            [self requestHealth:result];
            break;
        }
        case GContacts:{
            [self requestContacts:result];
            break;
        }
    }
}

- (void)requestCamera:(GRequestResult)result {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 NSError *error;
                                 if (granted) {
                                     //                                     @"开启成功"
                                 }else {
                                     //                                     @"开启失败"
                                     error = [NSError errorWithDomain:GErrorDomain
                                                                 code:GFailueAuthorize
                                                             userInfo:@{NSLocalizedDescriptionKey : GLocalized(@"Failue authorize")}];
                                 }
                                 result(granted, error);
                             }];
}

- (void)requestLocationAllows:(GRequestResult)result {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.locationResult = result;
    [self.manager requestAlwaysAuthorization];
}

- (void)requestLocationWhenInUse:(GRequestResult)result {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.locationResult = result;
    [self.manager requestWhenInUseAuthorization];
}

- (void)requestCalendars:(GRequestResult)result {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (error) {
                                  //
                              }else {
                                  if (granted) {
                                      //                                     @"请求成功");
                                  }else {
                                      //                                      @"请求失败");
                                  }
                              }
                              result(granted, error);
                          }];
}

- (void)requestReminders:(GRequestResult)result {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (error) {
                                  //
                              }else {
                                  if (granted) {
                                      //                                      @"请求成功");
                                  }else {
                                      //                                      @"请求失败");
                                  }
                              }
                              result(granted, error);
                          }];
}

- (void)requestUserNotification:(GRequestResult)result {
    NSAssert(0, @"* * * * * * 通知授权还未实现 * * * * * *");
}

- (void)requestPhotoLibrary:(GRequestResult)result {
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            NSError *error;
            BOOL granted = NO;
            if (status == PHAuthorizationStatusAuthorized) {
                //                @"授权成功");
                granted = YES;
            }else {
                //                @"授权失败");
                error = [NSError errorWithDomain:GErrorDomain
                                            code:GFailueAuthorize
                                        userInfo:@{NSLocalizedDescriptionKey : GLocalized(@"Failue authorize")}];
            }
            result(granted, error);
        }];
    }
}

- (void)requestMicrophone:(GRequestResult)result {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        NSError *error;
        if (granted) {
            //           @"请求成功");
        }else {
            //            (@"请求失败");
            error = [NSError errorWithDomain:GErrorDomain
                                        code:GFailueAuthorize
                                    userInfo:@{NSLocalizedDescriptionKey : GLocalized(@"Failue authorize")}];
        }
        result(granted, error);
    }];
}

- (void)requestHealth:(GRequestResult)result {
    if (![HKHealthStore isHealthDataAvailable]) {
        //        @"不支持 Health");
        NSError *error = [NSError errorWithDomain:GErrorDomain
                                             code:GUnsuportAuthorize
                                         userInfo:@{NSLocalizedDescriptionKey : GLocalized(@"Unsuport authorize")}];
        result(NO, error);
        return;
    }
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    // Share body mass, height and body mass index
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                               nil];
    // Read date of birth, biological sex and step count
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];
    // Request access
    [healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:readObjectTypes
                                       completion:^(BOOL success,
                                                    NSError *error) {
                                           if (error) {
                                               //
                                           }else {
                                               if(success == YES){
                                                   //                                                   @"请求成功");
                                               }
                                               else{
                                                   //                                                   @"请求失败");
                                               }
                                           }
                                           result(success, error);
                                       }];
}

- (void)requestContacts:(GRequestResult)result {
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts
                    completionHandler:^(BOOL granted,
                                        NSError * _Nullable error) {
                        if (error) {
                            //                                W
                        }else {
                            if (granted) {
                                //                                    @"请求成功");
                            }else {
                                //                                    @"请求失败");
                            }
                        }
                        result(granted, error);
                    }];
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
//        CNContactStore *store = [[CNContactStore alloc] init];
//        [store requestAccessForEntityType:CNEntityTypeContacts
//                        completionHandler:^(BOOL granted,
//                                            NSError * _Nullable error) {
//                            if (error) {
//                                //                                W
//                            }else {
//                                if (granted) {
//                                    //                                    @"请求成功");
//                                }else {
//                                    //                                    @"请求失败");
//                                }
//                            }
//                            result(granted, error);
//                        }];
//    }else {
//        ABAddressBookRef addressBook = ABAddressBookCreate();
//        ABAddressBookRequestAccessWithCompletion(addressBook,
//                                                 ^(bool granted,
//                                                   CFErrorRef error) {
//                                                     if (error) {
//                                                         //
//                                                     }else {
//                                                         if (granted) {
//                                                             //                                                             @"请求成功")
//                                                         }else {
//                                                             //                                                             @"请求失败");
//                                                         }
//                                                     }
//                                                     result(granted, (__bridge NSError *)(error));
//                                                 });
//    }
}



/**************************************** 权 限 判 断 ****************************************/
- (GPermissionAuthorizationStatus)authorizationPermission:(GPermission)permission {
    GPermissionAuthorizationStatus authorization;
    switch (permission) {
        case GCamera:
            authorization = [self determineCamera];
            break;
        case GLocationAllows:
            authorization = [self determineLocationAllows];
            break;
        case GLocationWhenInUse:
            authorization = [self determineLocationWhenInUse];
            break;
        case GCalendars:
            authorization = [self determineCalendars];
            break;
        case GReminders:
            authorization = [self determineReminders];
            break;
        case GPhotoLibrary:
            authorization = [self determinePhotoLibrary];
            break;
        case GUserNotification:
            authorization = [self determineUserNotification];
            break;
        case GMicrophone:
            authorization = [self determineMicrophone];
            break;
        case GHealth:
            authorization = [self determineHealth];
            break;
        case GContacts:
            authorization = [self determineContacts];
            break;
    }
    return authorization;
}

- (GPermissionAuthorizationStatus)determineCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determineLocationAllows {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determineLocationWhenInUse {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determineCalendars {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determineReminders {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determinePhotoLibrary {
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case PHAuthorizationStatusAuthorized: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
//
//        ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
//        switch (authStatus) {
//            case ALAuthorizationStatusNotDetermined: {
//                return GAuthorizationStatusNotDetermined;
//                break;
//            }
//            case ALAuthorizationStatusRestricted:
//            case ALAuthorizationStatusDenied: {
//                return GAuthorizationStatusForbid;
//                break;
//            }
//            case ALAuthorizationStatusAuthorized: {
//                return GAuthorizationStatusAuthorized;
//                break;
//            }
//        }
//    } else {
//        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
//        switch (authStatus) {
//            case PHAuthorizationStatusNotDetermined: {
//                return GAuthorizationStatusNotDetermined;
//                break;
//            }
//            case PHAuthorizationStatusRestricted:
//            case PHAuthorizationStatusDenied: {
//                return GAuthorizationStatusForbid;
//                break;
//            }
//            case PHAuthorizationStatusAuthorized: {
//                return GAuthorizationStatusAuthorized;
//                break;
//            }
//        }
//    }
}

- (GPermissionAuthorizationStatus)determineUserNotification {
    UIUserNotificationType type = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    switch (type) {
        case UIUserNotificationTypeNone: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case UIUserNotificationTypeBadge:
        case UIUserNotificationTypeSound:
        case UIUserNotificationTypeAlert: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determineMicrophone {
    AVAudioSessionRecordPermission authStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (authStatus) {
        case AVAudioSessionRecordPermissionUndetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case AVAudioSessionRecordPermissionDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case AVAudioSessionRecordPermissionGranted: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determineHealth {
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    HKObjectType *hkObjectType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:hkObjectType];
    switch (authStatus) {
        case HKAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case HKAuthorizationStatusSharingDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case HKAuthorizationStatusSharingAuthorized: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GPermissionAuthorizationStatus)determineContacts {
    
    CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (authStatus) {
        case CNAuthorizationStatusNotDetermined: {
            return GAuthorizationStatusNotDetermined;
            break;
        }
        case CNAuthorizationStatusRestricted:
        case CNAuthorizationStatusDenied: {
            return GAuthorizationStatusForbid;
            break;
        }
        case CNAuthorizationStatusAuthorized: {
            return GAuthorizationStatusAuthorized;
            break;
        }
    }
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
//        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//        switch (authStatus) {
//            case CNAuthorizationStatusNotDetermined: {
//                return GAuthorizationStatusNotDetermined;
//                break;
//            }
//            case CNAuthorizationStatusRestricted:
//            case CNAuthorizationStatusDenied: {
//                return GAuthorizationStatusForbid;
//                break;
//            }
//            case CNAuthorizationStatusAuthorized: {
//                return GAuthorizationStatusAuthorized;
//                break;
//            }
//        }
//    }else {
//        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
//        switch (authStatus) {
//            case kABAuthorizationStatusNotDetermined: {
//                return GAuthorizationStatusNotDetermined;
//                break;
//            }
//            case kABAuthorizationStatusRestricted:
//            case kABAuthorizationStatusDenied: {
//                return GAuthorizationStatusForbid;
//                break;
//            }
//            case kABAuthorizationStatusAuthorized: {
//                return GAuthorizationStatusAuthorized;
//                break;
//            }
//        }
//    }
}


#pragma mark  -- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.locationResult) {
            self.locationResult(YES, nil);
            self.locationResult = nil;
        }
    }
}
@end









