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
        self.loginButton.alpha = 1.0;
    }];
    
    [self.loginSpinnerView startAnimating];
    
    // Do the login
    [STSession login:self];
}

#pragma mark - STSessionDelegate

- (void)didLogin:(BOOL)loggedIn
{
    [self.loginButton setTitle:@"Logged in." forState:UIControlStateNormal];
    
    [UIView animateWithBlock:^{
        self.loginButton.alpha = 0.0;
    }];
    
    [self.loginSpinnerView stopAnimating];
    
	// Did we login successfully ?
	if (loggedIn) {
        
        [((STAppDelegate*) [UIApplication sharedApplication].delegate) showCreateStatusAsRootViewController];
        
	} else {
		// Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:@"Facebook Login failed. Please try again"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
	}
}

@end

