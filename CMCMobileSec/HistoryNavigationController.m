//
//  HistoryNavigationViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 12/26/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "HistoryNavigationController.h"

@interface HistoryNavigationController ()

@end

@implementation HistoryNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    NSLog(@"History Navigation");

	// Do any additional setup after loading the view.

    self.title = @"History";
    
    // Create the refresh, fixed-space (optional), and profile buttons.
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    
    //    // Optional: if you want to add space between the refresh & profile buttons
        UIBarButtonItem *fixedSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSpaceBarButtonItem.width = 12;
    
    UIBarButtonItem *profileBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStylePlain target:self action:@selector(goToProfile)];
    profileBarButtonItem.style = UIBarButtonItemStyleBordered;
    NSArray * items = @[profileBarButtonItem, fixedSpaceBarButtonItem,  refreshBarButtonItem];
    

//    [navigationItem setRightBarButtonItems:items animated:NO];
       [[self navigationItem] setRightBarButtonItems:items animated:NO];

        self.navigationItem.title = @"History";
    [super viewDidLoad];
}



- (void) refresh {
    
}

- (void) goToProfile {
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
