//
//  ConfirmActionViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 12/25/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "ConfirmActionViewController.h"

@interface ConfirmActionViewController ()

@end

@implementation ConfirmActionViewController
@synthesize fileListToScan;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [fileListToScan count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"confirm item";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [fileListToScan objectAtIndex:indexPath.row];
    return cell;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startScan:(id)sender {
    NSLog(@"start scanning...");

    ScanOptionsViewController *scanOptions = [self.storyboard instantiateViewControllerWithIdentifier:@"scan_view"];
    gItemToScan = fileListToScan;
//    [self.navigationController pushViewController:scanOptions animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    //send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scanOnDemand" object:nil];
}
@end
