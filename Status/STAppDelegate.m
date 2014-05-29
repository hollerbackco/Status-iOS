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
#import "STPushManager.h"

@interface STAppDelegate ()

@property (nonatomic, strong) UINavigationController *statusNavigationController;
@property (nonatomic) BOOL shouldRestartCreateStatus;

@end

@implementation STAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    JNLog();
    
    // Register our Parse Application.
    [Parse setApplicationId:kSTParseAppId clientKey:kSTParseClientKey];
    
    // Initialize Parse's Facebook Utilities singleton. This uses the FacebookAppID we specified in our App bundle's plist.
    [PFFacebookUtils initializeFacebook];
    
    [Crashlytics startWithAPIKey:@"1ed19e0f6100e773f794bf928ee1ef0b85ed4d6e"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    // configure logger
    [[STLogger sharedInstance] configureFileLogger];
    
    if ([[STSession sharedInstance] isLoggedIn]) {
        
        [self showCreateStatusAsRootViewController:YES];
        
    } else {
        STLoginViewController *loginViewController = [[STLoginViewController alloc] initWithNib];
        self.window.rootViewController = loginViewController;
    }
    
    [self.window makeKeyAndVisible];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    return YES;
}

- (void)showCreateStatusAsRootViewController:(BOOL)shouldLoadCamera
{
    JNLog();
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
    
    if ([[STSession sharedInstance] isLoggedIn]) {
        
        self.shouldRestartCreateStatus = YES;
        
        [self showCreateStatusAsRootViewController:NO];
        
    } else {
        
        self.shouldRestartCreateStatus = NO;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    JNLog();
    
    [STPushManager sharedInstance].willEnterFromPush = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    JNLog();
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    if ([STPushManager sharedInstance].willEnterFromPush) {
        
        [STPushManager sharedInstance].willEnterFromPush = NO;
    }
    
    if (self.shouldRestartCreateStatus) {
        self.shouldRestartCreateStatus = NO;
        
        [((STCreateStatusViewController*) self.statusNavigationController.topViewController) setupCamera];
    }
    
    [STAppManager checkForUpdates];
    
    [STAppManager updateAppVersion];
    
    [STLogger sendDailyLog];
    
    // store the current user if not exist
    JNLogObject([PFUser currentUser]);
    if ([PFUser currentUser]) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        JNLogObject(currentInstallation[@"user"]);
        if (!currentInstallation[@"user"]) {
            currentInstallation[@"user"] = [PFUser currentUser];
        }
        [currentInstallation saveInBackground];
    }
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
    JNLog();
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
    JNLogObject([PFUser currentUser]);
    if ([PFUser currentUser]) {
        currentInstallation[@"user"] = [PFUser currentUser];
    }
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
    JNLog();
    [self application:application handleRemotePush:userInfo];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    JNLog();
    [self application:application handleRemotePush:userInfo];
}

- (void)application:(UIApplication *)application handleRemotePush:(NSDictionary*)userInfo
{
    JNLogObject(userInfo);
    
    [JNAppManager printAppState:application];
    
    [[STPushManager sharedInstance] handlePush:userInfo];
    
    [[STSession sharedInstance] setValue:@(YES) forKey:kSTSessionStoreHasNewComments];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSTSessionStoreHasNewComments object:nil userInfo:nil];
}

@end
