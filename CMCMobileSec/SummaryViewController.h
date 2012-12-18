//
//  SummaryViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 11/28/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *sysStorageLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromNumber;
@property (weak, nonatomic) IBOutlet UILabel *smsContent;
@property (weak, nonatomic) IBOutlet UILabel *totalReceived;
@property (weak, nonatomic) IBOutlet UILabel *extStorageLabel;

@end
