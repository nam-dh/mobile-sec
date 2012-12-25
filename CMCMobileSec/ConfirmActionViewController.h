//
//  ConfirmActionViewController.h
//  CMCMobileSec
//
//  Created by Duc Tran on 12/25/12.
//  Copyright (c) 2012 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanOptionsViewController.h"
#import "CMCMobileSecurityAppDelegate.h"


@interface ConfirmActionViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
- (IBAction)startScan:(id)sender;
@property(nonatomic, retain)NSMutableArray *fileListToScan;

@end
