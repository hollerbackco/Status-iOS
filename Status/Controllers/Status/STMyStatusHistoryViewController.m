//
//  STMyStatusHistoryViewController.m
//  Status
//
//  Created by Joe Nguyen on 2/06/2014.
//  Copyright (c) 2014 Status. All rights reserved.
//

#import "STMyStatusHistoryViewController.h"
#import "STStatusHistoryTableViewController.h"

#import "JNIcon.h"

@interface STMyStatusHistoryViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;

@property (nonatomic, strong) STStatusHistoryTableViewController *tableViewController;

- (IBAction)settingsAction:(id)sender;
- (IBAction)cameraAction:(id)sender;

@end

@implementation STMyStatusHistoryViewController

#pragma mark - 

- (void)performFetch
{
    if (!self.tableViewController) {
        self.tableViewController = [[STStatusHistoryTableViewController alloc] initWithNibName:@"STStatusHistoryTableViewController" bundle:nil];
    }
    
    [self.tableViewController performFetchWithCachePolicy:kPFCachePolicyCacheThenNetwork];
}

#pragma mark - Views

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.headerView applyBottomHalfGradientBackgroundWithTopColor:JNBlackColor bottomColor:JNClearColor];
    self.headerLabel.backgroundColor = JNClearColor;
    self.headerLabel.textColor = JNWhiteColor;
    [self.headerLabel applyDarkShadowLayer];
    
    self.footerView.backgroundColor = JNClearColor;
    
    FAKIonIcons *cameraIcon = [FAKIonIcons cameraIconWithSize:32.0];
    [cameraIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.cameraButton setAttributedTitle:cameraIcon.attributedString forState:UIControlStateNormal];
    [self.cameraButton applyDarkerShadowLayer];
    
    FAKIonIcons *gearIcon = [FAKIonIcons gearBIconWithSize:32.0];
    [gearIcon addAttribute:NSForegroundColorAttributeName value:JNWhiteColor];
    [self.settingsButton setAttributedTitle:gearIcon.attributedString forState:UIControlStateNormal];
    [self.settingsButton applyDarkerShadowLayer];
    
    [self setupTableView];
}

- (void)setupTableView
{
    if (!self.tableViewController) {
        self.tableViewController = [[STStatusHistoryTableViewController alloc] initWithNibName:@"STStatusHistoryTableViewController" bundle:nil];
    }
    
    [self addChildViewController:self.tableViewController];
    
    self.tableViewController.view.bounds = self.contentView.bounds;
    
    [self.contentView addSubview:self.tableViewController.view];
}

#pragma mark - Actions

- (IBAction)settingsAction:(id)sender
{
    
}

- (IBAction)cameraAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
