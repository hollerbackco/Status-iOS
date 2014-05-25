//
//  STAppDelegate.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "STAppDelegate.h"

#import "STCreateStatusViewController.h"
#import "STLoginViewController.h"
#import "STAppManager.h"

@interface STAppDelegate ()

@property (nonatomic, strong) UINavigationController *statusNavigationController;
@property (nonatomic) BOOL shouldRestartCreateStatus;

@end

@implementation STAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    JNLog();
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Register our Parse Application.
    [Parse setApplicationId:@"OAawrd6K5rsKQWHGzh0cqtsVz8qnlMQvRewC8E8h" clientKey:@"ANovqbeOyoQ17I6RSGSVTps3FIrWIj9k1jHkMl4R"];
    
    // Initialize Parse's Facebook Utilities singleton. This uses the FacebookAppID we specified in our App bundle's plist.
    [PFFacebookUtils initializeFacebook];
    
    [Crashlytics startWithAPIKey:@"1ed19e0f6100e773f794bf928ee1ef0b85ed4d6e"];
    
    // configure logger
    [[STLogger sharedInstance] configureFileLogger];
    
    if ([STSession isLoggedIn]) {
        
        [self showCreateStatusAsRootViewController:YES];
        
    } else {
        STLoginViewController *loginViewController = [[STLoginViewController alloc] initWithNib];
        self.window.rootViewController = loginViewController;
    }
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)showCreateStatusAsRootViewController:(BOOL)shouldLoadCamera
{
    STCreateStatusViewController *createStatusViewController = [[STCreateStatusViewController alloc] initWithNib];
    
    createStatusViewController.shouldLoadCamera = shouldLoadCamera;
    
    self.statusNavigationController = [[UINavigationController alloc] initWithRootViewController:createStatusViewController];
    
    self.window.rootViewController = self.statusNavigationController;
}

#pragma mark - App Enter / Exit

- (void)applicationWillResignActive:(UIApplication *)application
{
    JNLog();
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    JNLog();
    
    self.shouldRestartCreateStatus = YES;
    
    [self showCreateStatusAsRootViewController:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    JNLog();
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    JNLog();
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    if (self.shouldRestartCreateStatus) {
        self.shouldRestartCreateStatus = NO;
        
        [((STCreateStatusViewController*) self.statusNavigationController.topViewController) setupCamera];
    }
    
    [STAppManager checkForUpdates];
    
    [STAppManager updateAppVersion];
    
    [STLogger sendDailyLog];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    JNLog();
}

#pragma mark - FB

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    JNLog();
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    JNLog();
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

@end
