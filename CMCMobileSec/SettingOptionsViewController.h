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

#import <CoreLocation/CoreLocation.h>

@interface SettingOptionsViewController : UITableViewController <CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    CLLocationManager *locationManager;
    UISwitch *trackingLocationSwitch;
}
@property (weak, nonatomic) IBOutlet UILabel *account1;
@property (weak, nonatomic) IBOutlet UILabel *account2;

@property (weak, nonatomic) IBOutlet UITableViewCell *accCell;
@property (weak, nonatomic) IBOutlet UILabel *updateStatusLabel;
@property (nonatomic,retain) IBOutlet UISwitch *toggleTrackingLocationSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *toggleRemoteLockSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *toggleKeepConnectSwitch;

-(IBAction) trackingLocationSwitchValueChanged;
-(IBAction) remoteLockSwitchValueChanged;

-(IBAction) keepConnectwitchValueChanged;

@end
