//
//  STSession.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STSession.h"

@implementation STSession

+ (BOOL)isLoggedIn
{
    return [PFUser currentUser] && [[PFUser currentUser] isAuthenticated];
}

+ (void)login:(id<STSessionDelegate>)delegate
{
	// Basic User information and your friends are part of the standard permissions
	// so there is no reason to ask for additional permissions
	[PFFacebookUtils logInWithPermissions:@[@"user_friends"] block:^(PFUser *user, NSError *error) {
		// Was login successful ?
		if (!user) {
			if (!error) {
                NSLog(@"The user cancelled the Facebook login.");
                
                if ([delegate respondsToSelector:@selector(didLogin:)]) {
                    [delegate didLogin:NO];
                }
                
            } else {
                NSLog(@"An error occurred: %@", error.localizedDescription);
                
                if ([delegate respondsToSelector:@selector(didNotLogin)]) {
                    [delegate didNotLogin];
                }
            }
            
		} else {
			if (user.isNew) {
				NSLog(@"User signed up and logged in through Facebook!");
			} else {
				NSLog(@"User logged in through Facebook!");
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
	}];
}

@end
