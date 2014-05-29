//
//  STSession.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STSession.h"
#import "JNSimpleDataStore.h"

#define kSTMaxLoginRetryCount 3

@interface STSession ()

@property (nonatomic) NSUInteger loginRetryCount;

@end

@implementation STSession

#pragma mark - Singleton

+ (STSession*)sharedInstance
{
    static STSession *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        _sharedInstance.loginRetryCount = 0;
    });
    
    return _sharedInstance;
}

#pragma mark -

- (BOOL)isLoggedIn
{
    return [PFUser currentUser] && [[PFUser currentUser] isAuthenticated];
}

- (void)login:(id<STSessionDelegate>)delegate
{
	// Basic User information and your friends are part of the standard permissions
	// so there is no reason to ask for additional permissions
	[PFFacebookUtils logInWithPermissions:@[@"user_friends"] block:^(PFUser *user, NSError *error) {
		// Was login successful ?
		if (!user) {
            
			if (!error) {
                JNLog(@"The user cancelled the Facebook login.");
                
                if ([delegate respondsToSelector:@selector(didLogin:)]) {
                    [delegate didLogin:NO];
                }
                
            } else {
                
                [JNLogger logExceptionWithName:THIS_METHOD reason:@"facebook login" error:error];
                
                // workaround for "Error validating access token: The user has not authorized application 1453821264861331" bug
                NSDictionary *userInfo = error.userInfo;
                NSDictionary *parsedJSONResponse = userInfo[FBErrorParsedJSONResponseKey];
                NSDictionary *errorJSON = parsedJSONResponse[@"body"][@"error"];
                if (errorJSON) {
                    
                    NSNumber *code = errorJSON[@"code"];
                    NSNumber *subCode = errorJSON[@"error_subcode"];
                    if ([code isEqualToNumber:@(190)] && [subCode isEqualToNumber:@(458)]) {
                        
                        JNLog(@"   ---> SDK bug, will retry login <---   ");
                        if (self.loginRetryCount < kSTMaxLoginRetryCount) {
                            
                            [self login:delegate];
                            self.loginRetryCount++;
                            
                            return;
                        }
                    }
                }
                
                // check for declined permission
                if ([error.userInfo[@"com.facebook.sdk:ErrorLoginFailedReason"]
                     isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"]) {
                    
                    JNLog(@"did not allow facebook permission");
                    
                    if ([delegate respondsToSelector:@selector(didNotAllowPermission)]) {
                        
                        [delegate didNotAllowPermission];
                    }
                } else {
                    
                    [[STLogger sharedInstance] sendLogWithSuffix:@"fberror"];
                    
                    if ([delegate respondsToSelector:@selector(didNotLogin)]) {
                        
                        [delegate didNotLogin];
                    }
                }
            }
            
		} else {
            
			if (user.isNew) {
				JNLog(@"User signed up and logged in through Facebook!");
			} else {
				JNLog(@"User logged in through Facebook!");
			}
            
			[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
                    // Store the Facebook Id
                    [[PFUser currentUser] setObject:me.objectID forKey:@"fbId"];
                    [[PFUser currentUser] setObject:me.name forKey:@"fbName"];
                    [[PFUser currentUser] setObject:me.first_name forKey:@"fbFirstName"];
                    [[PFUser currentUser] setObject:me.last_name forKey:@"fbLastName"];
                    
                    [[PFUser currentUser] saveInBackground];
                }
                
                // Callback - login successful
                if ([delegate respondsToSelector:@selector(didLogin:)]) {
                    [delegate didLogin:YES];
                }
            }];
		}
        
        // reset login retry count
        self.loginRetryCount = 0;
	}];
}

#pragma mark - Key Value store

- (void)setValue:(id)value forKey:(NSString*)key
{
    [JNSimpleDataStore setValue:value forKey:key];
}

- (id)getValueForKey:(NSString*)key
{
    return [JNSimpleDataStore getValueForKey:key];
}

@end
