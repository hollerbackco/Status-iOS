//
//  STLoginViewController.m
//  Status
//
//  Created by Joe Nguyen on 19/05/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STLoginViewController.h"
#import "STAppDelegate.h"

@interface STLoginViewController () <STSessionDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginSpinnerView;

- (IBAction)loginAction:(id)sender;

@end

@implementation STLoginViewController

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginSpinnerView.alpha = 0.0;
    [self.loginSpinnerView stopAnimating];
}

#pragma mark - Actions

- (IBAction)loginAction:(id)sender
{
    [UIView animateWithBlock:^{
        self.loginButton.alpha = 0.0;
        self.loginSpinnerView.alpha = 1.0;
    }];
    
    [self.loginSpinnerView startAnimating];
    
    [self performBlock:^{
        
        // Do the login
        [[STSession sharedInstance] login:self];
        
    } afterDelay:UINavigationControllerHideShowBarDuration];
}

#pragma mark - STSessionDelegate

- (void)didLogin:(BOOL)loggedIn
{
	// Did we login successfully ?
	if (loggedIn) {
        
        [self.loginButton setTitle:@"Logged in." forState:UIControlStateNormal];
        
        [UIView animateWithBlock:^{
            self.loginButton.alpha = 1.0;
            self.loginSpinnerView.alpha = 0.0;
        }];
        
        [self.loginSpinnerView stopAnimating];
        
        [((STAppDelegate*) [UIApplication sharedApplication].delegate) showCreateStatusAsRootViewController:YES];
        
	} else {
        
        [self didNotLogin];
	}
}

- (void)didNotLogin
{
    // Show error alert
    [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                message:@"Facebook Login failed. Please try again"
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
    
    [UIView animateWithBlock:^{
        self.loginButton.alpha = 1.0;
        self.loginSpinnerView.alpha = 0.0;
    }];
}

- (void)didNotAllowPermission
{
    // Show error alert
    [[[UIAlertView alloc] initWithTitle:@"Facebook Permission"
                                message:@"You have not allowed Status to use your Facebook account. To allow, go to Settings -> Facebook -> Turn on Status."
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
    
    [UIView animateWithBlock:^{
        self.loginButton.alpha = 1.0;
        self.loginSpinnerView.alpha = 0.0;
    }];
}

@end

