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
#import "STOrientationManager.h"

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
    self.window.rootViewController = createStatusViewController;
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
        
        [[STSession sharedInstance] setValue:@(NO) forKey:kSTSessionStoreHasCreatedStatus];
        
    } else {
        
        self.shouldRestartCreateStatus = NO;
    }
    
    // end device orientation observing
    [[STOrientationManager sharedInstance] endGeneratingDeviceOrientationNotifications];
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
        
        if ([self.window.rootViewController isKindOfClass:[STCreateStatusViewController class]]) {
            [((STCreateStatusViewController*) self.window.rootViewController) setupCamera];
        }
    }
    
    [STAppManager checkForUpdates];
    
    [STAppManager updateAppVersion];
    
    [STLogger sendDailyLog];
    
    // store the current user if not exist
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        JNLogObject(currentUser.objectId);
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        JNLogObject(currentInstallation.objectId);
        if (!currentInstallation[@"user"]) {
            currentInstallation[@"user"] = currentUser;
        }
        [currentInstallation saveInBackground];
    }
    
    // start device orientation observing
    [[STOrientationManager sharedInstance] beginGeneratingDeviceOrientationNotificationsCompleted:nil];
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
