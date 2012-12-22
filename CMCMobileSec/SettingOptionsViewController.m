//
//  SettingOptionsViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "SettingOptionsViewController.h"
#import "CMCMobileSecurityAppDelegate.h"

@interface SettingOptionsViewController ()

@end

@implementation SettingOptionsViewController
@synthesize toggleTrackingLocationSwitch;
@synthesize toggleRemoteLockSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_background.png"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UsersRegisterViewController *theInstance2 = [[UsersRegisterViewController alloc] init];
    [theInstance2 userLogin:email :password :sessionKey];
    
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeTheChange) name:@"theChange" object:nil];
}

- (void)makeTheChange
{
    self.account1.text = @"Email";
    self.account2.text = email;

}

-(void) viewWillAppear:(BOOL)animated {
    if (accountType == 1) {
        self.account1.text = @"Waiting for Confirmation Code";
        self.account2.text = @"Please enter confirmation code in email from CMC Mobile";
    }
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"theChange" object:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) trackingLocationSwitchValueChanged{
    if (toggleTrackingLocationSwitch.on) {
        NSLog(@"toggleTrackingLocationSwitch");
        [locationManager startUpdatingLocation];
        
    }else {
        [locationManager stopUpdatingLocation];
    }
}

-(IBAction) remoteLockSwitchValueChanged{
    if (toggleRemoteLockSwitch.on) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        }
        else
        {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        [imagePicker setDelegate:self];
        [self presentModalViewController:imagePicker animated:YES];

    }else {
        
    }
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //[self.imageView setImage:image];
    //save image
    
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    if (section == 0) {
        if (row == 0) {
            if (accountType == 0) {
                UsersRegisterViewController *userRegister = [self.storyboard instantiateViewControllerWithIdentifier:@"user_register"];
                [self.navigationController pushViewController:userRegister animated:YES];
            } else if (accountType == 1) {
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Account validation" message:@"Please enter the account validation code in CMC Mobile Security email" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField * alertTextField = [alert textFieldAtIndex:0];
//                alertTextField.keyboardType = UIKeyboardTypeNumberPad;
                [alert show];
    
                
            }
        }
    }
    if (section == 2) {
        if (row == 0) {
            BlackListViewController *fileSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"BlackList"];
            [self.navigationController pushViewController:fileSelection animated:YES];
        }
        if (row == 1) {
            KeywordFilterViewController *fileSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"KeywordFilter"];
            [self.navigationController pushViewController:fileSelection animated:YES];
        }
    }
    if (section == 3) {
        if (row == 2) {
            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* detailString = [[alertView textFieldAtIndex:0] text];
    NSLog(@"String is: %@", detailString); //Put it on the debugger
    if ([detailString length] <= 0 || buttonIndex == 0){
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        //validation account
        
        UsersRegisterViewController *userRegister = [[UsersRegisterViewController alloc] init];
        
        NSString* email = @"bolobala333@gmail.com";
       // NSString* activatekey = @"FB9B3104";
        
        [userRegister activateAccount:email :detailString :sessionKey];
        
        NSLog(@"validation account");
    }
    
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                     degrees, minutes, seconds];
    NSLog(@"lat=%@", lat);
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                       degrees, minutes, seconds];
    NSLog(@"longt=%@", longt);
    
    NSString* vector = [NSString stringWithFormat:@"(%@,%@)", lat, longt];
    
    NSLog(@"vector=%@", vector);
    UsersRegisterViewController *theInstance = [[UsersRegisterViewController alloc] init];
    [theInstance locationReport:vector :sessionKey];
}

- (void)viewDidUnload {
    [self setAccount1:nil];
    [self setAccount2:nil];
    [super viewDidUnload];
}
@end
