//
//  Permission.m
//  GAppFramework
//
//  Created by iOS_Developer_G on 2019/4/15.
//  Copyright © 2019 doumi. All rights reserved.
//

#import "GPermission.h"
#import <GTask/GTask.h>

#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <EventKit/EventKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
#import <Photos/Photos.h>
#endif

#import <UserNotifications/UserNotifications.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
//at least iOS 9 code here
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#endif

NSString *const PrePermissionsDidAskForPushNotifications = @"PrePermissionsDidAskForPushNotifications";

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
@interface GPermission ()<CLLocationManagerDelegate, CNContactPickerDelegate>
#else
@interface Permission ()<CLLocationManagerDelegate>
#endif
///> 
@property (nonatomic, strong) CLLocationManager *manager;
///> 
@property (nonatomic, assign) LocationAuthType locationType;
///> 定位block 
@property (nonatomic, copy) PMActionBlock locationBlock;
/** 地理编码和反编码 */
@property (strong, nonatomic) CLGeocoder *geocoder;

@end
@implementation GPermission

#pragma mark - Singleton
///=============================================================================
/// @name Singleton
///=============================================================================

+ (instancetype)permission {
    static GPermission *temp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        temp = [GPermission new];
    });
    return temp;
}

#pragma mark - AuthStatus
///=============================================================================
/// @name AuthStatus
///=============================================================================

+ (AuthStatus)camera {
    return (AuthStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

+ (AuthStatus)microphone {
    return (AuthStatus)[AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
}

+ (AuthStatus)photo {
    return (AuthStatus)[PHPhotoLibrary authorizationStatus];
}

+ (AuthStatus)contacts {
    return (AuthStatus)[CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
}

+ (AuthStatus)reminder {
    return (AuthStatus)[EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
}

+ (AuthStatus)event {
    return (AuthStatus)[EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
}

+ (AuthStatus)location {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            return AuthStatusAuthorized;
        case kCLAuthorizationStatusDenied:
            return AuthStatusDenied;
        case kCLAuthorizationStatusRestricted:
            return AuthStatusRestricted;
        default:
            return AuthStatusUnDetermined;
    }
}

+ (AuthStatus)push {
    if (@available(iOS 10.0, *)) {
        __block AuthStatus status;
        GTaskSource *tcs = [GTaskSource source];
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                status = AuthStatusAuthorized;
            } else if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                status = AuthStatusUnDetermined;
            } else {
                status = AuthStatusDenied;
            }
            [tcs setResult:@YES];
        }];
        [tcs.task wait];
        return status;
    }
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone) {
        return AuthStatusAuthorized;
    } else if ([[NSUserDefaults standardUserDefaults] integerForKey:PrePermissionsDidAskForPushNotifications] == 0) {
        return AuthStatusUnDetermined;
    }
    return AuthStatusDenied;
}

#pragma mark - Auth
///=============================================================================
/// @name Auth
///=============================================================================

+ (GTask *)auth:(AuthStatus)status block:(PMActionBlock)block {
    GTaskSource *tcs = [GTaskSource source];
    if (status == AuthStatusUnDetermined) {
        id authBlock = ^(AuthStatus authStatus) {
            [tcs setResult:@(authStatus == AuthStatusAuthorized)];
        };
        block(authBlock);
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

+ (void)avAuth:(AVMediaType)type block:(PMActionBlock)block {
    [AVCaptureDevice requestAccessForMediaType:type
                             completionHandler:^(BOOL granted) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (block) block();
                                 });
                             }];
}

#pragma mark - Camera Auth

+ (void)cameraPreAuth {
    if ([self camera] == AuthStatusUnDetermined) {
        [self avAuth:AVMediaTypeVideo block:^{}];
    }
}

+ (GTask *)cameraAuth {
    PMActionBlock block = ^(PMActionBlock authBlock){
        [self avAuth:AVMediaTypeVideo block:^{
            authBlock([self camera]);
        }];
    };
    return [self auth:[self camera] block:block];
}

#pragma mark - Microphone Auth

+ (void)microphonePreAuth {
    if ([self microphone] == AuthStatusUnDetermined) {
        [self avAuth:AVMediaTypeAudio block:^{}];
    }
}

+ (GTask *)microphoneAuth {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [self microphone];
    if (status == AuthStatusUnDetermined) {
        [self avAuth:AVMediaTypeAudio block:^{
            [tcs setResult:@([self microphone] == AuthStatusAuthorized)];
        }];
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

#pragma mark - Push Auth

+ (void)pushPreAuth {
    if ([self push] == AuthStatusUnDetermined) {
        [self pushActualAuth:^{}];
    }
}

+ (GTask *)pushAuth {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [self push];
    if (status == AuthStatusUnDetermined) {
        [self pushActualAuth:^(NSNumber *auth){
            [tcs setResult:auth];
        }];
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

+ (void)pushActualAuth:(PMActionBlock)block {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL auth, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (auth) [[UIApplication sharedApplication] registerForRemoteNotifications];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PrePermissionsDidAskForPushNotifications];
                block(@(auth));
            });
        }];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound |
                                                UIUserNotificationTypeAlert
                                                categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        __block NSInteger count = 2;
        __block id observer =
        [[NSNotificationCenter defaultCenter]
         addObserverForName:UIApplicationDidBecomeActiveNotification
         object:nil
         queue:nil
         usingBlock:^(NSNotification *note) {
             count--;
             if ([self push] == AuthStatusAuthorized) {
                 block(@YES);
                 [[NSNotificationCenter defaultCenter] removeObserver:observer];
                 return;
             }
             if (count == 0) [[NSNotificationCenter defaultCenter] removeObserver:observer];
         }];
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:PrePermissionsDidAskForPushNotifications];
    }
}

#pragma mark - Photo Auth

+ (void)photoPreAuth {
    if ([self photo] == AuthStatusUnDetermined) {
        [self photoActualAuth:^{}];
    }
}

+ (GTask *)photoAuth {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [self photo];
    if (status == AuthStatusUnDetermined) {
        [self photoActualAuth:^{
            [tcs setResult:@([self photo] == AuthStatusAuthorized)];
        }];
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

+ (void)photoActualAuth:(PMActionBlock)block {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    }];
}

#pragma mark - Contacts Auth

+ (void)contactsPreAuth {
    if ([self contacts] == AuthStatusUnDetermined) {
        [self contactsActualAuth:^{}];
    }
}

+ (GTask *)contactsAuth {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [self contacts];
    if (status == AuthStatusUnDetermined) {
        [self contactsActualAuth:^{
            [tcs setResult:@([self contacts] == AuthStatusAuthorized)];
        }];
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

+ (void)contactsActualAuth:(PMActionBlock)block {
    CNContactStore *contactsStore = [[CNContactStore alloc] init];
    [contactsStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    }];
}

#pragma mark - Event Auth

+ (void)eventPreAuth {
    if ([self event] == AuthStatusUnDetermined) {
        [self event:EKEntityTypeEvent actualAuth:^{}];
    }
}

+ (GTask *)eventAuth {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [self event];
    if (status == AuthStatusUnDetermined) {
        [self event:EKEntityTypeEvent actualAuth:^{
            [tcs setResult:@([self event] == AuthStatusAuthorized)];
        }];
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

#pragma mark - Reminder Auth

+ (void)reminderPreAuth {
    if ([self reminder] == AuthStatusUnDetermined) {
        [self event:EKEntityTypeReminder actualAuth:^{}];
    }
}

+ (GTask *)reminderAuth {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [self reminder];
    if (status == AuthStatusUnDetermined) {
        [self event:EKEntityTypeReminder actualAuth:^{
            [tcs setResult:@([self reminder] == AuthStatusAuthorized)];
        }];
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

+ (void)event:(EKEntityType)type actualAuth:(PMActionBlock)block {
    EKEventStore *aStore = [[EKEventStore alloc] init];
    [aStore requestAccessToEntityType:type completion:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    }];
}

#pragma mark - Location Auth

+ (void)locationPreAuth:(LocationAuthType)type {
    if ([self location] == AuthStatusUnDetermined) {
        [[self permission] locationAuth:type block:^{}];
    }
}

+ (GTask *)locationAuth:(LocationAuthType)type {
    GTaskSource *tcs = [GTaskSource source];
    AuthStatus status = [self location];
    if (status == AuthStatusUnDetermined) {
        [[self permission] locationAuth:type block:^(id data){
            [tcs setResult:@([self location] == AuthStatusAuthorized)];
        }];
    } else {
        [tcs setResult:@(status == AuthStatusAuthorized)];
    }
    return tcs.task;
}

- (void)locationAuth:(LocationAuthType)type block:(PMActionBlock)block {
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    self.locationBlock = block;
    self.locationType = type;
    
    if (self.locationType == LocationAuthTypeAlways &&
        [self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.manager requestAlwaysAuthorization];
    } else if (self.locationType == LocationAuthTypeWhenInUse &&
               [self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.manager requestWhenInUseAuthorization];
    }
    [self.manager startUpdatingLocation];
}

+ (void)requestLocation:(PMActionBlock)block {
    [[self permission] requestLocation:block];
}

- (void)requestLocation:(PMActionBlock)block{
    // 定位
    self.manager = [CLLocationManager new];
    [self.manager setDistanceFilter:kCLDistanceFilterNone];
    [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
    self.locationBlock = block;
    // 2.设置代理
    self.manager.delegate = self;
    
    // 3.请求定位
    //    if ([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
    //        [self.manager requestAlwaysAuthorization];
    //    }
    //     只有使用时才访问位置信息
    if ([self.manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.manager requestWhenInUseAuthorization];
    }
    
    // 4.开始定位
    [self.manager startUpdatingLocation];
    // 初始化编码器
    self.geocoder = [CLGeocoder new];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self.manager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *location = locations[0];
    [self.manager stopUpdatingLocation];
    // 地理反编码
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.manager stopUpdatingLocation];
    if (self.locationBlock) {
        self.locationBlock(false);
    }
    self.locationBlock = nil;
    
}

@end
