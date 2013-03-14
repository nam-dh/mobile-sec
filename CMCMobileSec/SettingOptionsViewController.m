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
#import "ServerResponePraser.h"
#import "ServerCmdPraser.h"
#import "NSData+Base64.h"

#import "AddressBookConnect.h"

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
@synthesize flagButton;
@synthesize blackListLabel;
@synthesize subBlackListLabel;
@synthesize keywordFilterLabel;
@synthesize subKeywordFilterLabel;
@synthesize autoConnectLabel;
@synthesize subAutoConnectLabel;
@synthesize lockLabel;
@synthesize subLockLabel;
@synthesize reportLabel;
@synthesize subReportLabel;
@synthesize autoBackupLabel;
@synthesize subAutoBackupLabel;
@synthesize allowBackupLabel;
@synthesize subAllowBackupLabel;
@synthesize clearLabel;
@synthesize subClearLabel;
@synthesize restoreLabel;
@synthesize subRestoreLabel;
@synthesize subLanguageLabel;

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

    UIImageView *boxBackView55 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg32055.png"]];
    UIImageView *boxBackView75 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg32075.png"]];
    if ((indexPath.section < 2) && (indexPath.section == 4))
        [cell setBackgroundView:boxBackView55];
    else
        [cell setBackgroundView:boxBackView75];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
	tableView.sectionHeaderHeight = headerView.frame.size.height;
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, headerView.frame.size.width - 20, 22)] ;
	label.text = [self tableView:tableView titleForHeaderInSection:section];
    if (section == 0) {
        label.text = LocalizedString(@"set_menu_header_acc");
    } else if (section == 1) {
        label.text = LocalizedString(@"set_menu_header_update");
    } else if ( section == 2) {
        label.text = LocalizedString(@"set_menu_header_filter");
    } else if (section == 3){
        label.text = LocalizedString(@"set_menu_header_antitheft");
    } else if (section == 4) {
        label.text = LocalizedString(@"language");
    }
	label.font = [UIFont boldSystemFontOfSize:15.5];
	label.shadowOffset = CGSizeMake(0, 1);
	//label.shadowColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
    
	label.textColor = [UIColor whiteColor];
    
	[headerView addSubview:label];
	return headerView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];


    UIImageView *boxBackView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_background.png"]];
    [self.tableView setBackgroundView:boxBackView];
    
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cmc_bar.png"]]];
    self.navigationItem.leftBarButtonItem= item;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLanguage) name:@"reloadLanguage" object:nil];
    
    if ([language isEqualToString:@"ENG"]) {
        [flagButton setImage:[UIImage imageNamed:@"setting_laguageicon_english.png"] forState:UIControlStateNormal];
        
    } else {
        [flagButton setImage:[UIImage imageNamed:@"setting_laguageicon_vietnamese.png"] forState:UIControlStateNormal];
        language = @"VIE";
        
    }
    [self reloadLanguage];        
    
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeTheChange) name:@"loginSuccess" object:nil];
    //add observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeToValidate) name:@"registerSuccess" object:nil];
    
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
    
    if ([remoteLockSwitchValue isEqualToString:@"ON"]) {
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




- (void) reloadLanguage{
    if([language isEqualToString:@"ENG"]){
        LocalizationSetLanguage(@"en");
    } else{
        LocalizationSetLanguage(@"vi");
    }
    [self configureView];
    [[self tableView] reloadData];
}

- (void) configureView{
    self.title = LocalizedString(@"set_settings");
    self.account1.text = LocalizedString(@"set_acc_title_unregistered");
    
    self.account2.lineBreakMode = UILineBreakModeWordWrap;
    self.account2.numberOfLines = 0;
    self.account2.text = LocalizedString(@"set_acc_sub_unregistered");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
    NSString* password = [defaults objectForKey:@"password"];
    NSString* email = [defaults objectForKey:@"email"];
    
    if (accountType == 2) {
        ServerConnection *theInstance = [[ServerConnection alloc] init];
        [theInstance userLogin:email :password :sessionKey];
        self.account1.text = @"Email";
        self.account2.text = email;
    }
    if (accountType == 1) {
        self.account1.text = LocalizedString(@"set_acc_title_waiting");
        self.account2.text = LocalizedString(@"set_acc_sub_waiting");
    }
    
    self.blackListLabel.text = LocalizedString(@"ftr_blacklist");
    
    self.subBlackListLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subBlackListLabel.numberOfLines = 0;
    self.subBlackListLabel.text = LocalizedString(@"set_filter_sub_blacklist");
    
    self.keywordFilterLabel.text = LocalizedString(@"set_filter_title_keyword");
    
    self.subKeywordFilterLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subKeywordFilterLabel.numberOfLines = 0;
    self.subKeywordFilterLabel.text = LocalizedString(@"set_filter_sub_keyword");
    
    self.autoConnectLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.autoConnectLabel.numberOfLines = 0;
    self.autoConnectLabel.text = LocalizedString(@"set_antitheft_title_autoconnect");
    
    self.subAutoConnectLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subAutoConnectLabel.numberOfLines = 0;
    self.subAutoConnectLabel.text = LocalizedString(@"set_antitheft_sub_autoconnect");
    
    self.lockLabel.text = LocalizedString(@"set_antitheft_title_lock");
    
    self.subLockLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subLockLabel.numberOfLines = 0;
    self.subLockLabel.text = LocalizedString(@"set_antitheft_sub_lock");
    
    self.reportLabel.text = LocalizedString(@"set_antitheft_title_report");
    self.subReportLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subReportLabel.numberOfLines = 0;
    self.subReportLabel.text = LocalizedString(@"set_antitheft_sub_report");
    
    self.autoBackupLabel.text = LocalizedString(@"set_antitheft_title_autobackup");
    self.subAutoBackupLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subAutoBackupLabel.numberOfLines = 0;
    self.subAutoBackupLabel.text = LocalizedString(@"set_antitheft_sub_autobackup");
    
    self.allowBackupLabel.text = LocalizedString(@"set_antitheft_title_backup");
    self.subAllowBackupLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subAllowBackupLabel.numberOfLines = 0;
    self.subAllowBackupLabel.text = LocalizedString(@"set_antitheft_sub_backup");
    
    self.clearLabel.text = LocalizedString(@"set_antitheft_title_clear");
    self.subClearLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subClearLabel.numberOfLines = 0;
    self.subClearLabel.text = LocalizedString(@"set_antitheft_sub_clear");
    
    self.restoreLabel.text = LocalizedString(@"set_antitheft_title_restore");
    self.subRestoreLabel.lineBreakMode = UILineBreakModeWordWrap;
    self.subRestoreLabel.numberOfLines = 0;
    self.subRestoreLabel.text = LocalizedString(@"set_antitheft_sub_restore");
    
    self.subLanguageLabel.text = LocalizedString(@"detail_language");
    
}

- (void)makeTheChange
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* email = [defaults objectForKey:@"email"];
    NSLog(@"validate success");
    self.account1.text = @"Email";
    self.account2.text = email;

}

- (void)changeToValidate
{
    NSLog(@"register success");
    self.account1.text = LocalizedString(@"set_acc_title_waiting");
    self.account2.text = LocalizedString(@"set_acc_sub_waiting");
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    NSLog(@"accountType=%d", accountType);
    if (accountType == 1) {
        self.account1.text = LocalizedString(@"set_acc_title_waiting");
        self.account2.text = LocalizedString(@"set_acc_sub_waiting");
    }
    if (accountType == 2) {
        self.account1.text = @"Email";
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* email = [defaults objectForKey:@"email"];
        self.account2.text = email;
    }
}

- (void)didReceiveMemoryWarning
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"theChange" object:nil];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeLanguage:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([language isEqualToString:@"ENG"]) {
        [flagButton setImage:[UIImage imageNamed:@"setting_laguageicon_vietnamese.png"] forState:UIControlStateNormal];
        language = @"VIE";
        [defaults setObject:@"VIE" forKey:@"language"];
    } else {
        [flagButton setImage:[UIImage imageNamed:@"setting_laguageicon_english.png"] forState:UIControlStateNormal];
        language = @"ENG";
        [defaults setObject:@"ENG" forKey:@"language"];
    }
    [defaults synchronize];
    //send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLanguage" object:nil];
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

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //[self.imageView setImage:image];
    //save image
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)autoBackupSwitchValueChanged:(id)sender {
    if (autoBackupSwitch.on) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setObject : @"ON" forKey : @"backupDataSwitchValue"];
        [settings synchronize];
        backupDataSwitchValue = @"ON";
        
        NSString* password = [settings objectForKey:@"password"];
        NSString* email = [settings objectForKey:@"email"];
        Boolean login = [[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"];
        
        if ((accountType == 2) && (login== false)){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
            ServerConnection *theInstance = [[ServerConnection alloc] init];
            [theInstance userLogin:email :password :sessionKey];
        }
        
        if (login) {
            
            NSString *type = @"cmd";
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
            
            ServerConnection *theInstance = [[ServerConnection alloc] init];
            [theInstance downloadFile:sessionKey :type];
            
        }
        
        
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
        
        //get address book test
     //   [AddressBookConnect getAllContactData];

        
        
        
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
    if (section == 1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update" message:@"Searching for latest version" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        
        if(alert != nil) {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            indicator.center = CGPointMake(alert.bounds.size.width/2, alert.bounds.size.height-45);
            [indicator startAnimating];
            [alert addSubview:indicator];
            
            [self performSelector:@selector(changeText:) withObject:alert  afterDelay:3];
            [self performSelector:@selector(stopIndicator:) withObject:indicator  afterDelay:3];
            

//
           // [indicator stopAnimating];
           // [alert dismissWithClickedButtonIndex:0 animated:YES];
          //  [indicator release];
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

-(void) changeText :(UIAlertView*) alert{
    NSString *newMessage = @"No update is avaiable!";
    [alert setMessage:newMessage];
}

-(void) stopIndicator :(UIActivityIndicatorView*) indicator{
    [indicator stopAnimating];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* detailString = [[alertView textFieldAtIndex:0] text];
    NSLog(@"String is: %@", detailString); //Put it on the debugger
    if ([detailString length] <= 0 || buttonIndex == 0){
        return; //If cancel or 0 length string the string doesn't matter
    }
    if (buttonIndex == 1) {
        //validation account
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString* sessionKey = [defaults objectForKey:@"sessionKey"];
        NSString* email = [defaults objectForKey:@"email"];
        
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
    [self setFlagButton:nil];
    [self setBlackListLabel:nil];
    [self setSubBlackListLabel:nil];
    [self setBlackListLabel:nil];
    [self setKeywordFilterLabel:nil];
    [self setSubKeywordFilterLabel:nil];
    [self setAutoConnectLabel:nil];
    [self setSubAutoConnectLabel:nil];
    [self setLockLabel:nil];
    [self setSubLockLabel:nil];
    [self setReportLabel:nil];
    [self setSubReportLabel:nil];
    [self setAutoBackupLabel:nil];
    [self setSubAutoBackupLabel:nil];
    [self setAllowBackupLabel:nil];
    [self setSubAllowBackupLabel:nil];
    [self setClearLabel:nil];
    [self setSubClearLabel:nil];
    [self setRestoreLabel:nil];
    [self setSubRestoreLabel:nil];
    [self setSubLanguageLabel:nil];
    [super viewDidUnload];
}
@end
