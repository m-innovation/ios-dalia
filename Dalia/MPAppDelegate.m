//
//  MPAppDelegate.m
//  Misepuri
//
//  Created by 3SI-TUYENBQ on 11/25/13.
//  Copyright (c) 2013 3SI-TUYENBQ. All rights reserved.
//

#import "MPAppDelegate.h"
#import "MPTabBarViewController.h"
#import "MPConfigObject.h"
#import "DatabaseManager.h"
#import "ManagerDownload.h"
#import "MPApnsDAO.h"
#import "DeployGateSDK/DeployGateSDK.h"

@implementation MPAppDelegate

+ (MPAppDelegate *)sharedMPAppDelegate {

    return (MPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Check network
-(void)networkChangeStatus:(NSNotification*)notifyObject {

    NetworkStatus internetStatus = self.reachability.currentReachabilityStatus;
    if(internetStatus == NotReachable){
        // lost network, alert user
        self.networkStatus = FALSE;

    }
    else{
        // network avaible, notify to process
        self.networkStatus = TRUE;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // DeployGateセット
    [[DeployGateSDK sharedInstance] launchApplicationWithAuthor:@"akafune" key:@"4c2b720f624aed3f6d4d59ca21341c65d29e3e47"];

    //2秒止める
    [NSThread sleepForTimeInterval:2.0];

    //画面生成
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    //Notification 有効化
    //TODO: SET ENABLE NOTIFICATION - 1:ENABLE - 0:DISABLE
    self.enableNotificationString = @"1";

    //@"kReachabilityChangedNotification" という文字列で通知を受け取れるようにする
    //TODO: check network connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChangeStatus:) name:kReachabilityChangedNotification object:nil];

    //通信状態の確認用
    self.reachability = [Reachability reachabilityForInternetConnection];
    self.networkStatus = [self.reachability currentReachabilityStatus];
    [self.reachability startNotifier];

    //マルチスレッド数設定
    //TODO: CREATE QUEUE
    self.mainQueue = [[NSOperationQueue alloc] init];
    [self.mainQueue setMaxConcurrentOperationCount:7];

    //TABの設定
    //TODO: ADD TABBARCONTROLLER TO ROOT VIEW
    MPTabBarViewController *tabBarController = [MPTabBarViewController sharedInstance];
    [tabBarController setUpTabBar];
    [self.window setRootViewController:tabBarController];

    //データベース前準備
    //TODO: DATABASE
    [DatabaseManager checkPhycicalDatabase];

    //通知設定（デバイストークン取得）
    //TODO: Let the device know we want to receive push notifications
    //[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    // (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];

        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
//        [application registerForRemoteNotificationTypes:
//         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

    //通知件数取得
    //TODO: Get default notification
//    [[ManagerDownload sharedInstance] getDefaultNotification:[Utility getDeviceID] withAppID:[Utility getAppID] delegate:self];

    NSLog(@"generic device ID: %@ %@",[Utility deviceID],[Utility getDeviceID]);

    //デバイス登録（iOSで登録）
    //TODO: Save device id to UserDefault
    [[ManagerDownload sharedInstance] submitDeviceID:[Utility deviceID] withAppID:[Utility getAppID] withType:@"1" delegate:self];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[Utility deviceID] forKey:DEVICE_ID_USER_DEFAULT];
    [userDefault synchronize];

    return YES;
}

#pragma mark - ManagerDownloadDelegate
- (void)downloadDataSuccess:(DownloadParam *)param {

    switch (param.request_type) {
        case RequestType_SUBMIT_DEVICE_ID:
            NSLog(@"Submitted device id");
        {
            //デバイス登録
            if(![param.listData[0][@"member_no"] isEqualToString:@""] ) {
                [[NSUserDefaults standardUserDefaults] setObject:param.listData[0][@"member_no"]  forKey:MEMBER_NO];
            }

            [[NSUserDefaults standardUserDefaults] setObject:[Utility formatDateToString:[NSDate date]] forKey:SET_DATE_SUBMIT_DEVICE_USER_DEFAULT];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
            break;

        case RequestType_SUBMIT_DEVICE_TOKEN:
            NSLog(@"submitted device token");
            break;

        case RequestType_GET_DEFAULT_NOTIFICATION:
            NSLog(@"%@",[param.listData lastObject]);
        {
            MPApnsObject *obj = [param.listData lastObject];

            self.couponBadge = [obj.apns_cp integerValue];
            self.totalBadge = [obj.apns_badge integerValue];

//            [[MPTabBarViewController sharedInstance] setBadgeValue:self.couponBadge];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.totalBadge];

        }
            break;

        default:
            break;
    }
}

- (void)downloadDataFail:(DownloadParam *)param {

    switch (param.request_type) {
        case RequestType_SUBMIT_DEVICE_ID:
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:MESSAGE_SEND_DEVICE_ID_FAIL delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;

        case RequestType_SUBMIT_DEVICE_TOKEN:
            break;

        default:
            break;
    }
}

#pragma mark - APNS
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {

    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My token is: %@ - %@", deviceToken,dt);
    NSString *appId = [Utility getAppID];

    //TODO: Post device id & post device token
    //[[ManagerDownload sharedInstance] submitDeviceID:dt withAppID:appId withType:@"1" delegate:self];
    
//API 確認必要（M.ama １１／１３）
//    [[ManagerDownload sharedInstance] submitDeviceToken:dt withAppID:appId withDeviceID:[Utility getDeviceID] delegate:self];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {

    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{

    if (application.applicationState != UIApplicationStateActive){
        NSLog(@"user info: %@",userInfo);
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        [[MPApnsDAO sharedInstance] deleteAll];
        MPApnsObject *apnsObject = [[MPApnsObject alloc] init];
        apnsObject.apns_badge = [aps objectForKey:@"badge"];
        apnsObject.apns_cp = [aps objectForKey:@"cp"];
        apnsObject.apns_type = [aps objectForKey:@"type"];
        [[MPApnsDAO sharedInstance] insertRecord:apnsObject];


        //TODO: jump to UI
        MPApnsObject *receivedObject = [[[MPApnsDAO sharedInstance] selectAll] lastObject];
        switch ([receivedObject.apns_type integerValue]) {
            case 1:
            {
                [[MPTabBarViewController sharedInstance] selectTab:0];
                [[MPTabBarViewController sharedInstance] setUpTabBar];
            }
                break;

            case 2:
            case 3:
            {
                [[MPTabBarViewController sharedInstance] selectTab:1];
                [[MPTabBarViewController sharedInstance] setUpTabBar];
                //TODO: hard code number badge
//                [[MPTabBarViewController sharedInstance] setBadgeValue:0];
                self.totalBadge -= self.couponBadge;
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:self.totalBadge];
            }
                break;

            default:
                break;
        }
    }else{
        //TODO: Get default notification
        [[ManagerDownload sharedInstance] getDefaultNotification:[Utility getDeviceID] withAppID:[Utility getAppID] delegate:self];
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {

    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[FBSession.activeSession handleDidBecomeActive];

    //TODO: Get default notification
//    [[ManagerDownload sharedInstance] getDefaultNotification:[Utility getDeviceID] withAppID:[Utility getAppID] delegate:self];

    //TODO: log history to server
    NSString *dateHis = [[NSUserDefaults standardUserDefaults] objectForKey:SET_DATE_SUBMIT_DEVICE_USER_DEFAULT];
    if (![dateHis isEqualToString:[Utility formatDateToString:[NSDate date]]]) {
        [[ManagerDownload sharedInstance] submitDeviceID:[Utility deviceID] withAppID:[Utility getAppID] withType:@"1" delegate:self];
    }
}
/*//deploygate用
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    //return [FBSession.activeSession handleOpenURL:url];
    //return YES;
    return [[DeployGateSDK sharedInstance] handleOpenUrl:url sourceApplication:sourceApplication annotation:annotation];
}
*/
- (void)applicationWillTerminate:(UIApplication *)application {

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
