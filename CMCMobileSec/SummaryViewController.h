//
//  SummaryViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//#import "ScanOptionsViewController.h"
#import "LocalizeHelper.h"
#import "FileSelectionViewController.h"
#import "ScanHistoryViewController.h"

@interface SummaryViewController : UITableViewController<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *sysStorageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromNumber;
@property (weak, nonatomic) IBOutlet UILabel *smsContent;
@property (weak, nonatomic) IBOutlet UILabel *totalReceived;
@property (weak, nonatomic) IBOutlet UILabel *demandScan;
@property (weak, nonatomic) IBOutlet UILabel *detailDemandScan;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *clearLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintButtonLabel;

@property (weak, nonatomic) IBOutlet UIButton *systemStorageButton;

@property (weak, nonatomic) IBOutlet UILabel *storageTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *receivedHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *spamHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *recentHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *blockLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfScanned;
@property (weak, nonatomic) IBOutlet UILabel *numberOfDetected;
@property (weak, nonatomic) IBOutlet UILabel *totalScanLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDetectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *scanStatus;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

- (IBAction)viewHistoryButton:(id)sender;

- (IBAction)scanOnDemandButton:(id)sender;


- (IBAction)systemStorageScan:(id)sender;
- (IBAction)stopScann:(id)sender;

- (NSString *) mostRecentNumber;
- (NSString *) getDBPath;


@property (strong, nonatomic) IBOutlet UIView *videoPreview;

@end
