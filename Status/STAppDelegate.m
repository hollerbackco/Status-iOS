//
//  STAppDelegate.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STAppDelegate.h"

#import "STCreateStatusViewController.h"
#import "STLoginViewController.h"

@interface STAppDelegate ()

@property (nonatomic, strong) UINavigationController *statusNavigationController;
@property (nonatomic) BOOL shouldRestartCreateStatus;

@end

@implementation STAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Register our Parse Application.
    [Parse setApplicationId:@"OAawrd6K5rsKQWHGzh0cqtsVz8qnlMQvRewC8E8h" clientKey:@"ANovqbeOyoQ17I6RSGSVTps3FIrWIj9k1jHkMl4R"];
    
    // Initialize Parse's Facebook Utilities singleton. This uses the FacebookAppID we specified in our App bundle's plist.
    [PFFacebookUtils initializeFacebook];
    
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
    JNLogObject([PFUser currentUser]);
    
    STCreateStatusViewController *createStatusViewController = [[STCreateStatusViewController alloc] initWithNib];
    
    createStatusViewController.shouldLoadCamera = shouldLoadCamera;
    
    self.statusNavigationController = [[UINavigationController alloc] initWithRootViewController:createStatusViewController];
    
    self.window.rootViewController = self.statusNavigationController;
}

#pragma mark - App Enter / Exit

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    self.shouldRestartCreateStatus = YES;
    
    [self showCreateStatusAsRootViewController:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    if (self.shouldRestartCreateStatus) {
        self.shouldRestartCreateStatus = NO;
        
        [((STCreateStatusViewController*) self.statusNavigationController.topViewController) setupCamera];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - FB

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
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
