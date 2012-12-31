//
//  SettingOptionsViewController.m
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import "SettingOptionsViewController.h"
#import "CMCMobileSecurityAppDelegate.h"
#import "ServerConnection.h"

@interface SettingOptionsViewController ()

@end

@implementation SettingOptionsViewController
@synthesize toggleTrackingLocationSwitch;
@synthesize toggleRemoteLockSwitch;
@synthesize toggleKeepConnectSwitch;
@synthesize blackListSwitch;
@synthesize keyWordSwitch;
@synthesize remoteBackupSwitch;
@synthesize autoBackupSwitch;
@synthesize remoteClearSwitch;
@synthesize remoteRestoreSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

   // cell.backgroundColor = [UIColor lightGrayColor];
    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstpage_background_realtime_menu.png"]];
    boxBackView.alpha = 0.45;
    [cell setBackgroundView:boxBackView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_background.png"]];
    [self.tableView setBackgroundView:boxBackView];
    
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_baricon.png"]]];
    self.navigationItem.leftBarButtonItem= item;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (accountType == 2) {
        ServerConnection *theInstance = [[ServerConnection alloc] init];
        [theInstance userLogin:email :password :sessionKey];
        self.account1.text = @"Email";
        self.account2.text = email;
    }
    if (accountType == 1) {
        self.account1.text = @"Waiting for Confirmation Code";
        self.account2.text = @"Please enter confirmation code in email from CMC Mobile";
    }
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeTheChange) name:@"loginSuccess" object:nil];
    
    if ([blackListSwitchValue isEqualToString:@"ON"]) {
        [blackListSwitch setOn:YES];
    }
    if ([keyWordSwitchValue isEqualToString:@"ON"]) {
        [keyWordSwitch setOn:YES];
    }
    if ([keepConnectSwitchValue isEqualToString:@"ON"]) {
        [toggleKeepConnectSwitch setOn:YES];
    }
    
    if ([remoteTrackSwitchValue isEqualToString:@"ON"]) {
        [toggleTrackingLocationSwitch setOn:YES];
    }
    
    if ([remoteClearSwitchValue isEqualToString:@"ON"]) {
        [toggleRemoteLockSwitch setOn:YES];
    }
    if ([backupDataSwitchValue isEqualToString:@"ON"]) {
        [autoBackupSwitch setOn:YES];
    }
    if ([remoteBackupSwitchValue isEqualToString:@"ON"]) {
        [remoteBackupSwitch setOn:YES];
    }
    if ([remoteClearSwitchValue isEqualToString:@"ON"]) {
        [remoteClearSwitch setOn:YES];
    }
    if ([remoteRestoreSwitchValue isEqualToString:@"ON"]) {
        [remoteRestoreSwitch setOn:YES];
    }
    
}

- (void)makeTheChange
{
    self.account1.text = @"Email";
    self.account2.text = email;

}

-(void) viewWillAppear:(BOOL)animated {
    NSLog(@"accountType=%d", accountType);
    if (accountType == 1) {
        self.account1.text = @"Waiting for Confirmation Code";
        self.account2.text = @"Please enter confirmation code in email from CMC Mobile";
    }
    if (accountType == 2) {
        self.account1.text = @"Email";
        self.account2.text = email;
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
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"remoteTrackSwitchValue"];
        [settings synchronize];
        remoteTrackSwitchValue = @"ON";
        
        //NSLog(@"toggleTrackingLocationSwitch");
        //[locationManager startUpdatingLocation];
        
    }else {
        //send notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stopTrackingLocation" object:nil];
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"remoteTrackSwitchValue"];
        [settings synchronize];
        remoteTrackSwitchValue = @"OFF";
        
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
        
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"remoteLockSwitchValue"];
        [settings synchronize];
        remoteLockSwitchValue = @"ON";

    }else {
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"remoteLockSwitchValue"];
        [settings synchronize];
        remoteLockSwitchValue = @"OFF";
        
    }
}

- (IBAction)autoBackupSwitchValueChanged:(id)sender {
    if (autoBackupSwitch.on) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"backupDataSwitchValue"];
        [settings synchronize];
        backupDataSwitchValue = @"ON";
        
        
    } else {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"backupDataSwitchValue"];
        [settings synchronize];
        backupDataSwitchValue = @"OFF";
    }
    
}

- (IBAction)remoteBackupSwitchValueChanged:(id)sender {
    
    if (remoteBackupSwitch.on) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"remoteBackupSwitchValue"];
        [settings synchronize];
        remoteBackupSwitchValue = @"ON";
        
        
    } else {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"remoteBackupSwitchValue"];
        [settings synchronize];
        remoteBackupSwitchValue = @"OFF";
    }
}

- (IBAction)remoteClearDataSwitchValueChanged:(id)sender {
    
    if (remoteClearSwitch.on) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"remoteClearSwitchValue"];
        [settings synchronize];
        remoteClearSwitchValue = @"ON";
        
        
    } else {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"remoteClearSwitchValue"];
        [settings synchronize];
        remoteClearSwitchValue = @"OFF";
    }
    
}

- (IBAction)remoteRestoreDataSwitchValueChanged:(id)sender {
    
    if (remoteRestoreSwitch.on) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"remoteRestoreSwitchValue"];
        [settings synchronize];
        remoteRestoreSwitchValue = @"ON";
        
        
    } else {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"remoteRestoreSwitchValue"];
        [settings synchronize];
        remoteRestoreSwitchValue = @"OFF";
    }
}

-(IBAction) keepConnectwitchValueChanged {
    if (toggleKeepConnectSwitch.on) {
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"keepConnectSwitchValue"];
        [settings synchronize];
        keepConnectSwitchValue = @"ON";
        
    } else {
        
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"keepConnectSwitchValue"];
        [settings synchronize];
        keepConnectSwitchValue = @"OFF";
        
    }
    NSLog(@"keepConnectSwitchValue=%@",keepConnectSwitchValue);
}

- (IBAction)blackListValueChanged:(id)sender {
    
    if (blackListSwitch.on) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"blackListSwitchValue"];
        [settings synchronize];
        blackListSwitchValue = @"ON";
        
        
    } else {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"blackListSwitchValue"];
        [settings synchronize];
        blackListSwitchValue = @"OFF";
    }
    
}

- (IBAction)keywordFilterValueChanged:(id)sender {
    
    if (keyWordSwitch.on) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"keyWordSwitchValue"];
        [settings synchronize];
        keyWordSwitchValue = @"ON";
        
        
    } else {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"OFF" forKey : @"keyWordSwitchValue"];
        [settings synchronize];
        keyWordSwitchValue = @"OFF";
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
            
            if ([blackListSwitchValue isEqualToString:@"ON"]) {
                BlackListViewController *fileSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"BlackList"];
                [self.navigationController pushViewController:fileSelection animated:YES];
            }
            
        }
        if (row == 1) {
            
            if ([keyWordSwitchValue isEqualToString:@"ON"]) {
                KeywordFilterViewController *fileSelection = [self.storyboard instantiateViewControllerWithIdentifier:@"KeywordFilter"];
                [self.navigationController pushViewController:fileSelection animated:YES];
            }
            
            
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
        
        ServerConnection *userRegister = [[ServerConnection alloc] init];
        [userRegister activateAccount:email :detailString :sessionKey];
        
        NSLog(@"validation account");
    }
    
}

- (void)viewDidUnload {
    [self setAccount1:nil];
    [self setAccount2:nil];
    [self setAutoBackupSwitch:nil];
    [self setRemoteBackupSwitch:nil];
    [self setRemoteClearSwitch:nil];
    [self setRemoteRestoreSwitch:nil];
    [self setKeyWordSwitch:nil];
    [super viewDidUnload];
}
@end
