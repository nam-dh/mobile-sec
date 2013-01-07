//
//  SettingOptionsViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlackListViewController.h"
#import "KeywordFilterViewController.h"
#import "UsersRegisterViewController.h"
#import "LocalizeHelper.h"

@interface SettingOptionsViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UISwitch *trackingLocationSwitch;
}
@property (weak, nonatomic) IBOutlet UILabel *account1;
@property (weak, nonatomic) IBOutlet UILabel *account2;

@property (weak, nonatomic) IBOutlet UITableViewCell *accCell;
@property (weak, nonatomic) IBOutlet UILabel *updateStatusLabel;

@property (weak, nonatomic) IBOutlet UILabel *blackListLabel;
@property (weak, nonatomic) IBOutlet UILabel *subBlackListLabel;
@property (weak, nonatomic) IBOutlet UILabel *keywordFilterLabel;
@property (weak, nonatomic) IBOutlet UILabel *subKeywordFilterLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoConnectLabel;
@property (weak, nonatomic) IBOutlet UILabel *subAutoConnectLabel;
@property (weak, nonatomic) IBOutlet UILabel *lockLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLockLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportLabel;
@property (weak, nonatomic) IBOutlet UILabel *subReportLabel;
@property (weak, nonatomic) IBOutlet UILabel *autoBackupLabel;
@property (weak, nonatomic) IBOutlet UILabel *subAutoBackupLabel;
@property (weak, nonatomic) IBOutlet UILabel *allowBackupLabel;
@property (weak, nonatomic) IBOutlet UILabel *subAllowBackupLabel;
@property (weak, nonatomic) IBOutlet UILabel *clearLabel;
@property (weak, nonatomic) IBOutlet UILabel *subClearLabel;
@property (weak, nonatomic) IBOutlet UILabel *restoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *subRestoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLanguageLabel;

@property (nonatomic,retain) IBOutlet UISwitch *toggleTrackingLocationSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *toggleRemoteLockSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *toggleKeepConnectSwitch;
@property (retain, nonatomic) IBOutlet UISwitch *autoBackupSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *remoteBackupSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *remoteClearSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *remoteRestoreSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *blackListSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *keyWordSwitch;
@property (weak, nonatomic) IBOutlet UIButton *flagButton;
- (IBAction)changeLanguage:(id)sender;

-(IBAction) trackingLocationSwitchValueChanged;
-(IBAction) remoteLockSwitchValueChanged;
- (IBAction)autoBackupSwitchValueChanged:(id)sender;
- (IBAction)remoteBackupSwitchValueChanged:(id)sender;
- (IBAction)remoteClearDataSwitchValueChanged:(id)sender;
- (IBAction)remoteRestoreDataSwitchValueChanged:(id)sender;

-(IBAction) keepConnectwitchValueChanged;
- (IBAction)blackListValueChanged:(id)sender;
- (IBAction)keywordFilterValueChanged:(id)sender;


@end
